#!/usr/bin/env sh

set -eu
if [ "${-#*i}" = "$-" ] || ! command -v batwatch >/dev/null 2>&1; then
	return
fi

bw() {
	batwatch -n0.5 "$@"
}
