#!/usr/bin/env sh
# shellcheck source=/dev/null
# shellcheck disable=SC2120,SC2033

# age
if command -v age >/dev/null 2>&1; then
	encrypt() {
		[ $# -le 1 ] || [ $# -ge 4 ] && echo_date "'encrypt' accepts [2..3] arguments; got $#" && return 1
		if [ -f "$1" ]; then
			__encrypt_mode='file'
		elif [ "${1#age}" != "$1" ]; then
			__encrypt_mode='key'
		else
			echo_date "'$1' is neither a file nor a public key" && return 1
		fi
		! [ -f "$2" ] && echo_date "'$2' does not exist" && return 1
		if [ $# -eq 3 ]; then
			__encrypt_output="$3"
		else
			__encrypt_output="$2.enc"
		fi
		if [ "${__encrypt_mode}" = 'file' ]; then
			age --encrypt --recipients-file="$1" --output="${__encrypt_output}" "$2"
		elif [ "${__encrypt_mode}" = 'key' ]; then
			age --encrypt --recipient="$1" --output="${__encrypt_output}" "$2"
		else
			echo_date "'encrypt' impossible case; got '${__encrypt_mode}'" && return 1
		fi
	}
	decrypt() {
		[ $# -le 1 ] || [ $# -ge 4 ] && echo_date "'decrypt' accepts [2..3] arguments; got $#" && return 1
		! [ -f "$1" ] && echo_date "'$1' does not exist" && return 1
		! [ -f "$2" ] && echo_date "'$2' does not exist" && return 1
		if [ $# -eq 3 ]; then
			__decrypt_output="$3"
		elif [ "${2%.enc}" = "$2" ]; then
			__decrypt_output="$2.dec"
		else
			echo bye
			__decrypt_output="${2%.enc}"
			echo "${__decrypt_output}"
		fi
		age --decrypt --identity="$1" --output="${__decrypt_output}" "$2"
	}
fi

# aichat
if command -v aichat >/dev/null 2>&1; then
	a() {
		if [ $# -eq 0 ]; then
			aichat
		else
			aichat "$*"
		fi
	}
	ac() {
		if [ $# -eq 0 ]; then
			aichat --role='coding'
		else
			aichat --role='coding' "$*"
		fi
	}
	acs() {
		if [ $# -eq 0 ]; then
			echo_date "'acs' accepts [1..) arguments; got $#" && return 1
		elif [ $# -eq 1 ]; then
			aichat --role='coding' --session="$1"
		else
			__session="$1"
			shift
			aichat --role='coding' --session="${__session}" "$*"
		fi
	}
	as() {
		if [ $# -eq 0 ]; then
			echo_date "'as' accepts [1..) arguments; got $#" && return 1
		elif [ $# -eq 1 ]; then
			aichat --session="$1"
		else
			__session="$1"
			shift
			aichat --session="${__session}" "$*"
		fi
	}
fi

# bacon
if command -v bacon >/dev/null 2>&1; then
	bt() {
		if [ $# -eq 0 ]; then
			bacon nextest -- -- --nocapture
		elif [ $# -eq 1 ]; then
			bacon nextest -- "$1" -- --nocapture
		elif [ $# -eq 2 ]; then
			bacon nextest -- --test "$1" "$2" -- --nocapture
		else
			echo_date "'bt' accepts [0..2] arguments; got $#" && return 1
		fi
	}
fi

# bat
if command -v bat >/dev/null 2>&1; then
	tf() {
		[ $# -ne 1 ] && echo_date "'tf' accepts 1 argument; got $#" && return 1
		__tf_base "$1" --language=log
	}
	tfp() {
		[ $# -ne 1 ] && echo_date "'tfp' accepts 1 argument; got $#" && return 1
		__tf_base "$1"
	}
	__tf_base() {
		__tf_base_file="$1"
		shift
		tail -F --lines=100 "${__tf_base_file}" | bat --paging=never --style=plain "$@"
	}
fi

# docker
if command -v docker >/dev/null 2>&1; then
	dps() {
		[ $# -ne 0 ] && echo_date "'dps' accepts no arguments; got $#" && return 1
		docker ps
	}
fi

# find
clean_dirs() {
	if [ $# -eq 0 ]; then
		__clean_dirs_dir="$(pwd)"
	elif [ $# -eq 1 ]; then
		__clean_dirs_dir="$1"
	else
		echo_date "'clean_dirs' accepts [0..1] arguments; got $#" && return 1
	fi
	find "${__clean_dirs_dir}" -type d -delete
}

# tsunami
if command -v tsunami >/dev/null 2>&1; then
	tsunami_get() {
		unset __host __all
		__rate="70M"
		__speedup="9/10"
		__slowdown="10/9"
		__blocksize="1200"
		__error="10%"

		usage() {
			cat <<EOF
Usage: $0 [options] host

Options:
  --rate=RATE
  --speedup=RATIO
  --slowdown=RATIO
  --blocksize=SIZE
  --error=PERCENT
  --all
EOF
			return 1
		}

		while [ $# -gt 0 ]; do
			case "$1" in
			--rate=*) __rate="${1#*=}" ;;
			--speedup=*) __speedup="${1#*=}" ;;
			--slowdown=*) __slowdown="${1#*=}" ;;
			--blocksize=*) __blocksize="${1#*=}" ;;
			--error=*) __error="${1#*=}" ;;
			--all) __all=1 ;;
			--help) usage ;;
			--*)
				echo_date "ERROR: Unknown option '$1'"
				usage
				return 1
				;;
			*) break ;;
			esac
			shift
		done

		if [ "$#" -ne 1 ]; then
			echo_date "ERROR: 'tsunami_get' accepts 1 positiona argment"
			usage
			return 1
		fi
		__host=$1
		shift

		# build command
		set -- connect "$__host" \
			set rate "$__rate" \
			set speedup "$__speedup" \
			set slowdown "$__slowdown" \
			set blocksize "$__blocksize" \
			set error "$__error"

		# select files
		if [ -n "${__all}" ]; then
			set -- "$@" get '*'
		else
			if ! command -v fzf >/dev/null 2>&1; then
				echo_date "ERROR: 'fzf' not found" && return 1
			fi

			__tmp_file=$(mktemp)
			trap 'rm -f "${__tmp_file}"' EXIT
			script -q "${__tmp_file}" tsunami connect "${__host}" dir quit
			__files=$(tr -d '\r' <"${__tmp_file}" | awk '
            /^[[:space:]]*[0-9]+\)/ {
                sub(/^[[:space:]]*[0-9]+\)[[:space:]]*/, "", $0)
                sub(/[[:space:]]+[0-9]+ bytes$/, "", $0)
                print $0
            }')
			__selected=$(printf '%s\n' "${__files}" | fzf -m)
			if [ -z "${__selected}" ]; then
				echo_date "ERROR: no files selected" && return 1
			fi
			while IFS= read -r __file; do
				set -- "$@" get "${__file}"
			done <<EOF
${__selected}
EOF
		fi

		# execute
		tsunami "$@" quit
	}
fi
if command -v tsunamid >/dev/null 2>&1; then
	tsunami_serve() {
		if [ $# -eq 0 ]; then
			__dir="${HOME}/work/tsunami/out"
		elif [ $# -eq 1 ]; then
			__dir="$1"
		else
			echo_date "'tsunami_serve' accepts no arguments; got $#" && return 1
		fi
		if ! [ -d "${__dir}" ]; then
			echo_date "ERROR: '${__dir}' does not exist" && return 1
		fi
		(
			cd "${__dir}" || exit 1
			# shellcheck disable=SC2035
			tsunamid *
		)
	}
fi

# uv
if command -v uv >/dev/null 2>&1; then
	uvpyc() {
		if [ $# -eq 0 ]; then
			__uvpyc_dir="$(pwd)"
		elif [ $# -eq 1 ]; then
			__uvpyc_dir="$1"
		else
			echo_date "'uvpyc' accepts 1 argument; got $#" && return 1
		fi
		uv tool run pyclean "${__uvpyc_dir}"
		clean_dirs "${__uvpyc_dir}"
	}
fi
