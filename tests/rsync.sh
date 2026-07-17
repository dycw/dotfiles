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
(
	sleep_calls=0
	sleep() {
		sleep_calls=$((sleep_calls + 1))
		if [ "${sleep_calls}" -ge 2 ]; then
			exit 0
		fi
		return 0
	}
	wrsync source target
)
if [ "$(wc -l <"${rsync_log}")" -lt 2 ]; then
	fail_test "wrsync should sync repeatedly by default"
fi
if ! grep -F -- '-avzh --partial source target' "${rsync_log}" >/dev/null; then
	fail_test "wrsync should use rsync -avzh --partial by default"
fi

if wrsync --loop=invalid source target 2>"${tmp}/error.log"; then
	fail_test "wrsync should reject a non-numeric loop interval"
fi
assert_file_contains "'wrsync' invalid --loop interval: invalid" "${tmp}/error.log"

(
	sleep_calls=0
	sleep() {
		sleep_calls=$((sleep_calls + 1))
		if [ "${sleep_calls}" -ge 2 ]; then
			exit 0
		fi
		return 0
	}
	rrsync source target
)
if [ "$(wc -l <"${rsync_log}")" -lt 6 ]; then
	fail_test "rrsync should sync repeatedly by default"
fi

if rrsync missing 2>"${tmp}/rrsync-error.log"; then
	fail_test "rrsync should require a source and target"
fi
assert_file_contains "'rrsync' expected" "${tmp}/rrsync-error.log"
