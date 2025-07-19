#!/usr/bin/env bash

# Default flags
host="dw-mac.tailnet"
rate="70M"
speedup="9/10"
slowdown="10/9"
blocksize="1200"
error="10%"

# Usage helper
usage() {
    echo "Usage: $0 [file1 file2 ...]"
    echo "If no files given, interactive fzf selection is used."
    exit 1
}

# Validate args: allow zero or more filenames (you can modify to exactly 0 or 1 arg)
if [ "$#" -gt 1 ]; then
    usage
fi

# 1. Capture tsunami directory listing (using your existing method)
script -q /tmp/tsunami.log tsunami connect "$host" dir quit
cleaned=$(tr -d '\r' </tmp/tsunami.log)
files=$(echo "$cleaned" | grep -E '^[[:space:]]*[0-9]+\)' |
    sed -E 's/^[[:space:]]*[0-9]+\)[[:space:]]+(.+[^[:space:]])[[:space:]]+[0-9]+ bytes$/\1/')

# 2. Determine selection
if [ "$#" -eq 1 ]; then
    # Use positional argument as the selected file (single)
    selected="$1"
else
    # Use fzf for multi-select
    selected=$(echo "$files" | fzf -m)
fi

if [ -z "$selected" ]; then
    echo "No files selected."
    exit 0
fi

# 3. Build tsunami command

set -- connect "$host" set rate "$rate" set speedup "$speedup" set slowdown "$slowdown" set blocksize "$blocksize" set error "$error"

# Add 'get' commands for each selected file
# (split lines safely)
echo "$selected" | while IFS= read -r file; do
    set -- "$@" get "$file"
done

# Append quit
set -- "$@" quit

# 4. Run tsunami with all flags and file commands
tsunami "$@"
