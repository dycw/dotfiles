# shellcheck shell=sh
if command -v rsync >/dev/null 2>&1; then
	rrsync() {
		if [ "$#" -lt 2 ]; then
			echo "'rrsync' expected [2..) arguments SOURCE ... TARGET; got $#" >&2
			return 1
		fi

		user=
		for arg; do
			case "${arg}" in
			*@*:*)
				prefix=${arg%%:*}
				user=${prefix%%@*}
				break
				;;
			esac
		done

		rrsync_arg() {
			case "$1" in
			*:*)
				prefix=${1%%:*}
				case "${prefix}" in
				*/* | *@* | "") rrsync_arg_result=$1 ;;
				*)
					if [ -n "${user}" ]; then
						rrsync_arg_result=${user}@$1
					else
						rrsync_arg_result=$1
					fi
					;;
				esac
				;;
			*) rrsync_arg_result=$1 ;;
			esac
		}

		target=
		for arg; do
			rrsync_arg "${arg}"
			target=${rrsync_arg_result}
		done

		tmp=$(mktemp -d) || return 1

		if [ "$#" -gt 2 ]; then
			case "${target}" in
			*/) ;;
			*)
				echo "'rrsync' with multiple sources requires directory target ending in '/': ${target}" >&2
				rm -rf -- "${tmp}"
				return 1
				;;
			esac
		fi

		single_source=0
		[ "$#" -eq 2 ] && single_source=1
		final_source=${tmp}/
		status=0
		while [ "$#" -gt 1 ]; do
			rrsync_arg "$1"
			src=${rrsync_arg_result}
			shift
			case "${src}" in
			*/)
				path=${src%/}
				name=${path##*/}
				name=${name##*:}
				if [ -z "${name}" ]; then
					echo "'rrsync' invalid directory source: ${src}" >&2
					status=1
					break
				fi
				if command mkdir -p -- "${tmp}/${name}" && rsync -av "${src}" "${tmp}/${name}/"; then
					:
				else
					status=$?
					break
				fi
				;;
			*)
				name=${src##*/}
				name=${name##*:}
				rsync -av "${src}" "${tmp}/" || {
					status=$?
					break
				}
				if [ "${single_source}" -eq 1 ]; then
					final_source=${tmp}/${name}
				fi
				;;
			esac
		done

		if [ "${status}" -eq 0 ]; then
			rsync -rDv "${final_source}" "${target}"
			status=$?
		fi
		rm -rf -- "${tmp}"
		return "${status}"
	}
fi
