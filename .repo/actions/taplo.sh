#!/bin/sh

set -eu

# shellcheck disable=SC1090,SC1091
. "$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)/common.sh"

command -v taplo >/dev/null 2>&1 || brew install taplo

run_taplo() {
	check=
	if [ -n "${CI:-}" ]; then
		check=--check
	fi
	taplo format \
		--no-auto-config \
		${check:+$check} \
		--option indent_entries=true \
		--option indent_tables=true \
		--option reorder_keys=true \
		"$@"
}

run_default() {
	tmp=$(make_temp_file taplo)
	track_temp_file "${tmp}"
	write_tracked_files "${tmp}" '*.toml'
	tracked_files_are_empty "${tmp}" && exit 0
	if [ -n "${CI:-}" ]; then
		xargs -0 taplo format \
			--check \
			--no-auto-config \
			--option indent_entries=true \
			--option indent_tables=true \
			--option reorder_keys=true <"${tmp}"
	else
		xargs -0 taplo format \
			--no-auto-config \
			--option indent_entries=true \
			--option indent_tables=true \
			--option reorder_keys=true <"${tmp}"
	fi
}

if [ "$#" -gt 0 ]; then
	run_taplo "$@"
else
	run_default
fi
