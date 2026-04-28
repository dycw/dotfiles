#!/bin/sh

set -eu

# shellcheck disable=SC1090,SC1091
. "$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)/common.sh"

run_prettier() {
	mode=--write
	if [ -n "${CI:-}" ]; then
		mode=--check
	fi
	prettier \
		--config-precedence=cli-override \
		--end-of-line=lf \
		--ignore-unknown \
		--log-level=silent \
		--no-config \
		--no-editorconfig \
		--prose-wrap=preserve \
		--tab-width=2 \
		--trailing-comma=all \
		"${mode}" \
		"$@"
}

run_default() {
	tmp=$(make_temp_file prettier)
	track_temp_file "${tmp}"
	write_tracked_files "${tmp}" '*.json' '*.md' '*.yaml' '*.yml'
	tracked_files_are_empty "${tmp}" && exit 0
	if [ -n "${CI:-}" ]; then
		xargs -0 prettier \
			--check \
			--config-precedence=cli-override \
			--end-of-line=lf \
			--ignore-unknown \
			--log-level=silent \
			--no-config \
			--no-editorconfig \
			--prose-wrap=preserve \
			--tab-width=2 \
			--trailing-comma=all <"${tmp}"
	else
		xargs -0 prettier \
			--write \
			--config-precedence=cli-override \
			--end-of-line=lf \
			--ignore-unknown \
			--log-level=silent \
			--no-config \
			--no-editorconfig \
			--prose-wrap=preserve \
			--tab-width=2 \
			--trailing-comma=all <"${tmp}"
	fi
}

if [ "$#" -gt 0 ]; then
	run_prettier "$@"
else
	run_default
fi
