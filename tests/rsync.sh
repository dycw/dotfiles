#!/usr/bin/env sh
# shellcheck disable=SC1090,SC1091,SC2154

set -eu

. "$(dirname -- "$0")/_lib.sh"

tmp=$(make_temp_dir)
trap 'cleanup_temp_dir "${tmp}"' EXIT HUP INT TERM

rsync_log=${tmp}/rsync.log
staging_log=${tmp}/staging.log
rsync_status=0

rsync() {
	printf '%s\n' "$*" >>"${rsync_log}"
	return "${rsync_status}"
}

mktemp() {
	staging_dir=$(command mktemp "$@") || return $?
	printf '%s\n' "${staging_dir}" >>"${staging_log}"
	printf '%s\n' "${staging_dir}"
}

assert_staging_cleaned() {
	staging_dir=$(tail -n 1 "${staging_log}")
	[ ! -e "${staging_dir}" ] || fail_test "staging directory was not cleaned: ${staging_dir}"
}

assert_final_sync() {
	expected_source_suffix=$1
	expected_target=$2
	actual=$(tail -n 1 "${rsync_log}")
	case "${actual}" in
	*"${expected_source_suffix} ${expected_target}") ;;
	*) fail_test "unexpected final rsync call: ${actual}" ;;
	esac
}

. "${test_root}/configs/bash/bashrc.d/rsync.sh"
sleep() {
	fail_test "rrsync should not sleep without --loop"
}
: >"${rsync_log}"
rrsync source target
assert_eq "$(wc -l <"${rsync_log}" | tr -d '[:space:]')" 2
assert_staging_cleaned

(
	sleep_calls=0

	sleep() {
		assert_eq "$1" 2
		sleep_calls=$((sleep_calls + 1))
		if [ "${sleep_calls}" -ge 2 ]; then
			exit 0
		fi
		return 0
	}

	rrsync source --loop target
)
assert_eq "$(wc -l <"${rsync_log}" | tr -d '[:space:]')" 6

: >"${rsync_log}"
(
	sleep() {
		assert_eq "$1" 3
		exit 0
	}

	rrsync --loop=3 source target
)
assert_eq "$(wc -l <"${rsync_log}" | tr -d '[:space:]')" 2

: >"${rsync_log}"
(
	sleep() {
		assert_eq "$1" 3
		exit 0
	}

	rrsync source --loop 3 target
)
assert_eq "$(wc -l <"${rsync_log}" | tr -d '[:space:]')" 2

: >"${rsync_log}"
rrsync foo bar
assert_final_sync /foo bar
rrsync foo/ bar
assert_final_sync / bar
rrsync foo bar/
assert_final_sync /foo bar/
rrsync foo/ bar/
assert_final_sync / bar/

if rrsync --loop=invalid source target 2>"${tmp}/rrsync-loop-error.log"; then
	fail_test "rrsync should reject a non-numeric loop interval"
fi
assert_file_contains "'rrsync' invalid --loop interval: invalid" "${tmp}/rrsync-loop-error.log"

if rrsync missing 2>"${tmp}/rrsync-error.log"; then
	fail_test "rrsync should require a source and target"
fi
assert_file_contains "'rrsync' expected" "${tmp}/rrsync-error.log"

: >"${rsync_log}"
rsync_status=23
if rrsync source target; then
	fail_test "rrsync should preserve rsync failures"
else
	assert_eq "$?" 23
fi
assert_staging_cleaned
rsync_status=0

: >"${rsync_log}"
for source in .. ../; do
	if rrsync "${source}" target 2>"${tmp}/source-name-error.log"; then
		fail_test "rrsync should reject source names that escape its staging directory"
	fi
done
assert_file_contains "'rrsync' invalid staging source name" "${tmp}/source-name-error.log"
assert_eq "$(wc -l <"${rsync_log}" | tr -d '[:space:]')" 0

: >"${rsync_log}"
rrsync first second target
assert_eq "$(wc -l <"${rsync_log}" | tr -d '[:space:]')" 3

: >"${rsync_log}"
rrsync source/ target
assert_eq "$(wc -l <"${rsync_log}" | tr -d '[:space:]')" 2
assert_file_contains 'source/ ' "${rsync_log}"

: >"${rsync_log}"
rrsync user@source:/file targethost:/path
assert_file_contains 'user@targethost:/path' "${rsync_log}"
