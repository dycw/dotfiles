# shellcheck shell=bash disable=SC2124
if command -v rsync >/dev/null 2>&1; then
	rrsync() {
		if [ "$#" -lt 2 ]; then
			echo "'rrsync' expected [2..) arguments SOURCE ... TARGET; got $#" >&2
			return 1
		fi

		local target="${@:$#:1}"
		local tmp status src path name
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

		status=0
		while [ "$#" -gt 1 ]; do
			src=$1
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
				rsync -av "${src}" "${tmp}/" || {
					status=$?
					break
				}
				;;
			esac
		done

		if [ "${status}" -eq 0 ]; then
			rsync -av --no-times "${tmp}/" "${target}"
			status=$?
		fi
		rm -rf -- "${tmp}"
		return "${status}"
	}
fi
