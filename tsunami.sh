#!/usr/bin/env bash

# Default internal flags
__host="dw-mac.tailnet"
__rate="70M"
__speedup="9/10"
__slowdown="10/9"
__blocksize="1200"
__error="10%"
unset __all # means interactive mode unless set

# Usage
usage() {
    cat <<EOF
Usage: $0 [options]

Options:
  --host=HOST             Target host (default: $__host)
  --rate=RATE             Transfer rate limit (default: $__rate)
  --speedup=RATIO         Speedup ratio (default: $__speedup)
  --slowdown=RATIO        Slowdown ratio (default: $__slowdown)
  --blocksize=SIZE        Block size (default: $__blocksize)
  --error=PERCENT         Allowable error percentage (default: $__error)
  --all                   Download all files (equivalent to get '*')
  --help                  Show this message

If --all is not specified, fzf will be used to select files interactively.
EOF
    exit 1
}

# Parse CLI flags
while [ $# -gt 0 ]; do
    case "$1" in
    --host=*) __host="${1#*=}" ;;
    --rate=*) __rate="${1#*=}" ;;
    --speedup=*) __speedup="${1#*=}" ;;
    --slowdown=*) __slowdown="${1#*=}" ;;
    --blocksize=*) __blocksize="${1#*=}" ;;
    --error=*) __error="${1#*=}" ;;
    --all) __all=1 ;; # presence of var is the flag
    --help) usage ;;
    --*)
        echo "Unknown option: $1" >&2
        usage
        ;;
    *)
        echo "Unexpected positional argument: $1" >&2
        usage
        ;;
    esac
    shift
done

# 1. Remove carriage returns (very common with `script`)
__cleaned=$(tr -d '\r' </tmp/tsunami.log)

# 2. Extract filenames from numbered lines

__files=$(tr -d '\r' </tmp/tsunami.log | awk '
  /^[[:space:]]*[0-9]+\)/ {
    sub(/^[[:space:]]*[0-9]+\)[[:space:]]*/, "", $0)        # Remove " 1) " prefix
    sub(/[[:space:]]+[0-9]+ bytes$/, "", $0)               # Remove "    5 bytes" suffix
    print $0
  }
')
# __files=$(echo "$__cleaned" |
#     grep -E '^[[:space:]]*[0-9]+\)' |
#     sed -E 's/^[[:space:]]*[0-9]+\)[[:space:]]+(.+[^[:space:]])[[:space:]]+[0-9]+ bytes.*$/\1/')

# 2. Determine selection
if [ -n "$__all" ]; then
    __selected="*"
else
    __selected=$(echo "$__files" | fzf -m)
    if [ -z "$__selected" ]; then
        echo "No files selected."
        exit 0
    fi
fi

# 3. Build tsunami command
set -- connect "$__host" \
    set rate "$__rate" \
    set speedup "$__speedup" \
    set slowdown "$__slowdown" \
    set blocksize "$__blocksize" \
    set error "$__error"

# 4. Add get commands
if [ "$__selected" = "*" ]; then
    set -- "$@" get '*'
else
    while IFS= read -r __file; do
        set -- "$@" get "$__file"
    done <<EOF
$__selected
EOF
fi

set -- "$@" quit

# Debug: print the command to be run
printf 'Running command:\n'
printf 'tsunami'
for arg in "$@"; do
    printf ' %s' "$(printf '%s' "$arg" | sed "s/'/'\\\\''/g")"
done
printf '\n\n'

# 5. Run tsunami
tsunami "$@"
