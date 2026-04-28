#!/bin/sh
# shellcheck disable=SC2034

set -eu

action_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH='' cd -- "${action_dir}/../.." && pwd)
version_file="${repo_root}/VERSION"

log() {
	printf '%s\n' "$*" >&2
}

fail() {
	log "$*"
	exit 1
}

read_trimmed_file() {
	tr -d '\n' <"$1"
}

make_temp_file() {
	mktemp "${TMPDIR:-/tmp}/$1.XXXXXX"
}

track_temp_file() {
	temp_file_for_cleanup=$1
	trap 'rm -f -- "${temp_file_for_cleanup}"' EXIT HUP INT TERM
}

write_tracked_files() {
	out=$1
	shift
	git -C "${repo_root}" ls-files -z -- \
		"$@" \
		':(exclude)configs/fzf/fzf.fish/**' \
		':(exclude)configs/nvm/nvm.fish/**' \
		':(exclude)configs/tmux/.tmux/**' >"${out}"
}

tracked_files_are_empty() {
	[ ! -s "$1" ]
}
