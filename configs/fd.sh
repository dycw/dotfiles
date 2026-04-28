#!/usr/bin/env sh

set -eu
if [ "${-#*i}" = "$-" ]; then
	return
fi
if ! command -v fd >/dev/null 2>&1 && ! command -v fdfind >/dev/null 2>&1; then
	return
fi

fd() {
	if command -v fd >/dev/null 2>&1; then
		command fd "$@"
	else
		command fdfind "$@"
	fi
}

fdd() {
	fd --hidden --type=directory "$@"
}

fdf() {
	fd --hidden --type=file "$@"
}
