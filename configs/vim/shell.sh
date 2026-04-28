#!/usr/bin/env sh

set -eu
if [ "${-#*i}" = "$-" ] || ! command -v vim >/dev/null 2>&1; then
	return
fi

v() {
	vim "$@"
}
