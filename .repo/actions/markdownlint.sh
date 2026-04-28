#!/bin/sh

set -eu

# shellcheck disable=SC1090,SC1091
. "$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)/common.sh"

run_markdownlint() {
	if [ -n "${CI:-}" ]; then
		markdownlint "$@"
	else
		markdownlint --fix "$@"
	fi
}

run_default() {
	tmp=$(make_temp_file markdownlint)
	track_temp_file "${tmp}"
	write_tracked_files "${tmp}" '*.md'
	tracked_files_are_empty "${tmp}" && exit 0
	if [ -n "${CI:-}" ]; then
		xargs -0 markdownlint <"${tmp}"
	else
		xargs -0 markdownlint --fix <"${tmp}"
	fi
}

if [ "$#" -gt 0 ]; then
	run_markdownlint "$@"
else
	run_default
fi
