# shellcheck shell=sh
if command -v rsync >/dev/null 2>&1; then

	__rrsync_rsync() {
		rsync -avzh --partial "$@"
	}

	__rrsync_is_number() {
		case "$1" in
		'' | *[!0-9]*) return 1 ;;
		esac
		return 0
	}

	__rrsync_loop() {
		__rrsync_loop_interval=2
		__rrsync_loop_enabled=0
		__rrsync_remaining=$#

		# Rotate ordinary arguments to preserve their order while removing loop options.
		while [ "${__rrsync_remaining}" -gt 0 ]; do
			__rrsync_arg=$1
			shift
			__rrsync_remaining=$((__rrsync_remaining - 1))

			case "${__rrsync_arg}" in
			--loop)
				__rrsync_loop_enabled=1
				__rrsync_loop_interval=2
				if [ "${__rrsync_remaining}" -gt 0 ] && __rrsync_is_number "$1"; then
					__rrsync_loop_interval=$1
					shift
					__rrsync_remaining=$((__rrsync_remaining - 1))
				fi
				;;
			--loop=*)
				__rrsync_loop_enabled=1
				__rrsync_loop_interval=${__rrsync_arg#--loop=}
				if ! __rrsync_is_number "${__rrsync_loop_interval}"; then
					echo "'rrsync' invalid --loop interval: ${__rrsync_loop_interval}" >&2
					return 1
				fi
				;;
			*) set -- "$@" "${__rrsync_arg}" ;;
			esac
		done

		if [ "${__rrsync_loop_enabled}" -eq 0 ]; then
			__rrsync_once "$@" || return $?
			return 0
		fi

		while :; do
			__rrsync_once "$@" || return $?
			printf 'Sleeping for %ss...\n' "${__rrsync_loop_interval}"
			sleep "${__rrsync_loop_interval}" || return $?
		done
	}

	__rrsync_infer_user() {
		__rrsync_user=
		for __rrsync_arg; do
			case "${__rrsync_arg}" in
			*@*:*)
				__rrsync_user=${__rrsync_arg%%:*}
				__rrsync_user=${__rrsync_user%%@*}
				return 0
				;;
			esac
		done
	}

	__rrsync_normalize_remote() {
		case "$1" in
		*:*) ;;
		*)
			__rrsync_normalized_arg=$1
			return 0
			;;
		esac

		__rrsync_remote_prefix=${1%%:*}
		case "${__rrsync_remote_prefix}" in
		*/* | *@* | "")
			__rrsync_normalized_arg=$1
			return 0
			;;
		esac

		if [ -n "${__rrsync_user}" ]; then
			__rrsync_normalized_arg=${__rrsync_user}@$1
		else
			__rrsync_normalized_arg=$1
		fi
	}

	__rrsync_normalize_target() {
		__rrsync_target=
		for __rrsync_arg; do
			__rrsync_normalize_remote "${__rrsync_arg}"
			__rrsync_target=${__rrsync_normalized_arg}
		done
	}

	__rrsync_source_name() {
		__rrsync_name_path=${1%/}
		__rrsync_source_name=${__rrsync_name_path##*/}
		__rrsync_source_name=${__rrsync_source_name##*:}
		case "${__rrsync_source_name}" in
		'' | ..)
			printf "'rrsync' invalid staging source name: %s\n" "$1" >&2
			return 1
			;;
		esac
	}

	__rrsync_stage_directory() {
		__rrsync_source_name "$1" || return $?
		__rrsync_rsync "$1" "${__rrsync_tmp}/"
	}

	__rrsync_stage_file() {
		__rrsync_source_name "$1" || return $?
		__rrsync_rsync "$1" "${__rrsync_tmp}/" || return $?
		if [ "${__rrsync_single_source}" -eq 1 ]; then
			__rrsync_final_source=${__rrsync_tmp}/${__rrsync_source_name}
		fi
	}

	__rrsync_stage_source() {
		case "$1" in
		*/) __rrsync_stage_directory "$1" ;;
		*) __rrsync_stage_file "$1" ;;
		esac
	}

	__rrsync_stage_sources() {
		while [ "$#" -gt 1 ]; do
			__rrsync_normalize_remote "$1"
			__rrsync_source=${__rrsync_normalized_arg}
			shift
			__rrsync_stage_source "${__rrsync_source}" || return $?
		done
	}

	__rrsync_cleanup() {
		__rrsync_cleanup_status=$1
		trap - EXIT HUP INT TERM
		rm -rf -- "${__rrsync_tmp}" || {
			__rrsync_cleanup_error=$?
			if [ "${__rrsync_cleanup_status}" -eq 0 ]; then
				__rrsync_cleanup_status=${__rrsync_cleanup_error}
			fi
		}
		exit "${__rrsync_cleanup_status}"
	}

	__rrsync_transfer_staged() {
		__rrsync_stage_sources "$@" || return $?
		__rrsync_rsync "${__rrsync_final_source}" "${__rrsync_target}"
	}

	__rrsync_once() (
		if [ "$#" -lt 2 ]; then
			echo "'rrsync' expected [2..) arguments SOURCE ... TARGET; got $#" >&2
			exit 1
		fi

		__rrsync_infer_user "$@"
		__rrsync_normalize_target "$@"

		__rrsync_tmp=$(mktemp -d) || exit 1
		trap '__rrsync_cleanup "$?"' EXIT
		trap 'exit 129' HUP
		trap 'exit 130' INT
		trap 'exit 143' TERM

		__rrsync_final_source=${__rrsync_tmp}/
		__rrsync_single_source=0
		[ "$#" -eq 2 ] && __rrsync_single_source=1

		__rrsync_transfer_staged "$@"
	)

	rrsync() {
		__rrsync_loop "$@"
	}

fi
