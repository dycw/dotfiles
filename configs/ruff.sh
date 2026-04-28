#!/usr/bin/env sh

set -eu
if [ "${-#*i}" = "$-" ] || ! command -v ruff >/dev/null 2>&1; then
	return
fi

rw() {
	ruff check -w "$@"
}
