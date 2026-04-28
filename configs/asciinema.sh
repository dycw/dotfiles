#!/usr/bin/env sh

set -eu
if [ "${-#*i}" = "$-" ] || ! command -v asciinema >/dev/null 2>&1; then
	return
fi

asciinema_record() {
	if [ -d "${HOME}/Dropbox/Screenshots" ]; then
		dir="${HOME}/Dropbox/Screenshots"
	else
		dir=$(pwd)
	fi
	now=$(date -u +"%Y-%m-%dT%H-%M-%S-UTC")
	path_tmp="${dir}/${now}.asciinema"
	asciinema record "${path_tmp}"
	if command -v agg >/dev/null 2>&1; then
		agg "${path_tmp}" "${dir}/${now}.gif"
		rm -f -- "${path_tmp}"
	fi
}
