#!/usr/bin/env sh
# shellcheck disable=SC1090,SC1091,SC2154

set -eu

. "$(dirname -- "$0")/_lib.sh"

tmp=$(make_temp_dir)
trap 'cleanup_temp_dir "${tmp}"' EXIT HUP INT TERM

rsync_log=${tmp}/rsync.log
rsync() {
	printf '%s\n' "$*" >>"${rsync_log}"
}

. "${test_root}/configs/bash/bashrc.d/rsync.sh"
wrsync source target
if ! grep -F -- '-avzh --partial source target' "${rsync_log}" >/dev/null; then
	fail_test "wrsync should use rsync -avzh --partial by default"
fi

if wrsync --loop=invalid source target 2>"${tmp}/error.log"; then
	fail_test "wrsync should reject a non-numeric loop interval"
fi
assert_file_contains "'wrsync' invalid --loop interval: invalid" "${tmp}/error.log"

if rrsync missing 2>"${tmp}/rrsync-error.log"; then
	fail_test "rrsync should require a source and target"
fi
assert_file_contains "'rrsync' expected" "${tmp}/rrsync-error.log"
