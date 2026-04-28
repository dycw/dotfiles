#!/bin/sh

set -eu

# shellcheck disable=SC1090,SC1091
. "$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)/common.sh"

run_shfmt() {
	mode=--write
	if [ -n "${CI:-}" ]; then
		mode=--diff
	fi
	shfmt "${mode}" "$@"
}

run_default() {
	tmp=$(make_temp_file shfmt)
	track_temp_file "${tmp}"
	write_tracked_files "${tmp}" '*.sh'
	tracked_files_are_empty "${tmp}" && exit 0
	if [ -n "${CI:-}" ]; then
		xargs -0 shfmt --diff <"${tmp}"
	else
		xargs -0 shfmt --write <"${tmp}"
	fi
}

if [ "$#" -gt 0 ]; then
	run_shfmt "$@"
else
	run_default
fi
