# shellcheck shell=sh
if command -v rsync >/dev/null 2>&1; then
	__rsync_default() {
		rsync -avzh --partial "$@"
	}

	__rsync_loop() {
		command_name=$1
		command_label=$2
		shift 2
		loop_interval=
		remaining=$#

		while [ "${remaining}" -gt 0 ]; do
			arg=$1
			shift
			remaining=$((remaining - 1))
			case "${arg}" in
			--loop)
				loop_interval=2
				if [ "${remaining}" -gt 0 ]; then
					case "$1" in
					'' | *[!0-9]*) ;;
					*)
						loop_interval=$1
						shift
						remaining=$((remaining - 1))
						;;
					esac
				fi
				;;
			--loop=*)
				loop_interval=${arg#--loop=}
				case "${loop_interval}" in
				'' | *[!0-9]*)
					echo "'${command_label}' invalid --loop interval: ${loop_interval}" >&2
					return 1
					;;
				esac
				;;
			*)
				set -- "$@" "${arg}"
				;;
			esac
		done

		if [ -n "${loop_interval}" ]; then
			while :; do
				"${command_name}" "$@"
				printf 'Sleeping for %ss...\n' "${loop_interval}"
				sleep "${loop_interval}"
			done
		fi

		"${command_name}" "$@"
	}

	__rsync_normalize_remote() {
		case "$1" in
		*:*)
			remote_prefix=${1%%:*}
			case "${remote_prefix}" in
			*/* | *@* | "") rsync_normalized_arg=$1 ;;
			*)
				if [ -n "${rsync_user}" ]; then
					rsync_normalized_arg=${rsync_user}@$1
				else
					rsync_normalized_arg=$1
				fi
				;;
			esac
			;;
		*) rsync_normalized_arg=$1 ;;
		esac
	}

	rrsync_once() {
		if [ "$#" -lt 2 ]; then
			echo "'rrsync' expected [2..) arguments SOURCE ... TARGET; got $#" >&2
			return 1
		fi

		rsync_user=
		for rsync_arg; do
			case "${rsync_arg}" in
			*@*:*)
				rsync_user=${rsync_arg%%:*}
				rsync_user=${rsync_user%%@*}
				break
				;;
			esac
		done

		rsync_target=
		for rsync_arg; do
			__rsync_normalize_remote "${rsync_arg}"
			rsync_target=${rsync_normalized_arg}
		done

		rsync_tmp=$(mktemp -d) || return 1
		rsync_status=0
		rsync_single_source=0
		[ "$#" -eq 2 ] && rsync_single_source=1

		if [ "$#" -gt 2 ]; then
			case "${rsync_target}" in
			*/) ;;
			*)
				echo "'rrsync' with multiple sources requires directory target ending in '/': ${rsync_target}" >&2
				rm -rf -- "${rsync_tmp}"
				return 1
				;;
			esac
		fi

		rsync_final_source=${rsync_tmp}/
		while [ "$#" -gt 1 ]; do
			__rsync_normalize_remote "$1"
			rsync_source=${rsync_normalized_arg}
			shift
			case "${rsync_source}" in
			*/)
				rsync_path=${rsync_source%/}
				rsync_name=${rsync_path##*/}
				rsync_name=${rsync_name##*:}
				if [ -z "${rsync_name}" ]; then
					echo "'rrsync' invalid directory source: ${rsync_source}" >&2
					rsync_status=1
					break
				fi
				if command mkdir -p -- "${rsync_tmp}/${rsync_name}" &&
					__rsync_default "${rsync_source}" "${rsync_tmp}/${rsync_name}/"; then
					:
				else
					rsync_status=$?
					break
				fi
				;;
			*)
				rsync_name=${rsync_source##*/}
				rsync_name=${rsync_name##*:}
				__rsync_default "${rsync_source}" "${rsync_tmp}/" || {
					rsync_status=$?
					break
				}
				if [ "${rsync_single_source}" -eq 1 ]; then
					rsync_final_source=${rsync_tmp}/${rsync_name}
				fi
				;;
			esac
		done

		if [ "${rsync_status}" -eq 0 ]; then
			__rsync_default "${rsync_final_source}" "${rsync_target}"
			rsync_status=$?
		fi
		rm -rf -- "${rsync_tmp}"
		return "${rsync_status}"
	}

	wrsync_once() {
		if [ "$#" -lt 2 ]; then
			echo "'wrsync' expected SOURCE ... TARGET; got $#" >&2
			return 1
		fi
		__rsync_default "$@"
	}

	rrsync() {
		__rsync_loop rrsync_once rrsync "$@"
	}

	wrsync() {
		__rsync_loop wrsync_once wrsync "$@"
	}
fi
