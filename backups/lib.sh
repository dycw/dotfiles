#!/usr/bin/env sh
# shellcheck disable=SC1090

backup_log() {
	printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

backup_log_error() {
	backup_log "$@" >&2
}

backup_fail() {
	backup_log_error "$@"
	exit 1
}

backup_reject_args() {
	[ "$#" -eq 0 ] || backup_fail 'This command does not accept arguments'
}

backup_load_env() {
	backup_env_path=$1
	if [ ! -r "${backup_env_path}" ]; then
		backup_log_error "Unable to find environment file '${backup_env_path}'; exiting..."
		return 1
	fi

	backup_log "Sourcing '${backup_env_path}'..."
	. "${backup_env_path}"
}
