#!/bin/sh

set -eu

# shellcheck disable=SC1090,SC1091
. "$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)/common.sh"

run_shellcheck() {
	shellcheck --external-sources "$@"
}

run_default() {
	tmp=$(make_temp_file shellcheck)
	track_temp_file "${tmp}"
	write_tracked_files "${tmp}" '*.sh'
	tracked_files_are_empty "${tmp}" && exit 0
	xargs -0 shellcheck --external-sources <"${tmp}"
}

if [ "$#" -gt 0 ]; then
	run_shellcheck "$@"
else
	run_default
fi
