#!/usr/bin/env sh
# shellcheck disable=SC1090,SC1091,SC2154

set -eu

. "$(dirname -- "$0")/_lib.sh"

tmp=$(make_temp_dir)
trap 'cleanup_temp_dir "${tmp}"' EXIT HUP INT TERM

home="${tmp}/home with spaces"
backups_dir="${home}/dotfiles/backups"
script_dir="${backups_dir}/rsync-cloud"
fake_bin="${tmp}/fake bin"
cloud_root="${home}/Library/CloudStorage"
source_one='Documents/source one – sample'
source_two='Documents/source two – sample'
source_three='Documents/absolute source – sample'
rsync_log="${tmp}/rsync.log"
destinations_log="${tmp}/destinations.log"
mktemp_log="${tmp}/mktemp.log"
sleep_log="${tmp}/sleep.log"
provider_fail_marker="${tmp}/provider-rsync-failed"
mkdir -p \
	"${script_dir}" \
	"${fake_bin}" \
	"${home}/${source_one}" \
	"${home}/${source_two}" \
	"${home}/${source_three}" \
	"${cloud_root}/provider one" \
	"${cloud_root}/provider two" \
	"${cloud_root}/provider three" \
	"${cloud_root}/provider four"
cp -- "${test_root}/backups/rsync-cloud/backup" "${script_dir}/backup"
cp -- "${test_root}/backups/lib.sh" "${backups_dir}/lib.sh"
chmod +x "${script_dir}/backup"
printf 'first source\n' >"${home}/${source_one}/first sample.txt"
printf 'second source\n' >"${home}/${source_two}/second sample.txt"
printf 'absolute source\n' >"${home}/${source_three}/absolute sample.txt"
printf 'not a provider directory\n' >"${cloud_root}/not-a-provider"

cat >"${fake_bin}/mktemp" <<'EOF'
#!/bin/sh
set -eu
printf 'mktemp %s\n' "$*" >>"${TEST_MKTEMP_LOG}"
[ "$#" -eq 2 ] && [ "$1" = -d ] || exit 2
[ "${TEST_MKTEMP_FAIL:-0}" -eq 0 ] || exit 18
mkdir -p -- "${TEST_STAGING_ROOT}"
printf '%s\n' "${TEST_STAGING_ROOT}"
EOF
chmod +x "${fake_bin}/mktemp"

cat >"${fake_bin}/df" <<'EOF'
#!/bin/sh
set -eu
[ "$#" -eq 2 ] && [ "$1" = -h ] || exit 2
printf '%s\n' 'Filesystem Size Used Avail Capacity Mounted on' '/dev/mock 100G 25G 75G 25% /tmp'
EOF
chmod +x "${fake_bin}/df"

cat >"${fake_bin}/du" <<'EOF'
#!/bin/sh
set -eu
[ "$#" -eq 2 ] && [ "$1" = -sh ] || exit 2
printf '12M\t%s\n' "$2"
EOF
chmod +x "${fake_bin}/du"

cat >"${fake_bin}/sleep" <<'EOF'
#!/bin/sh
set -eu
[ "$#" -eq 1 ] || exit 2
printf '%s\n' "$1" >>"${TEST_SLEEP_LOG}"
EOF
chmod +x "${fake_bin}/sleep"

cat >"${fake_bin}/rsync" <<'EOF'
#!/bin/sh
set -eu
printf '%s\n' '<call>' >>"${TEST_RSYNC_LOG}"
for argument do
	printf '%s\n' "${argument}" >>"${TEST_RSYNC_LOG}"
done
printf '%s\n' '</call>' >>"${TEST_RSYNC_LOG}"
[ "$#" -eq 5 ] && [ "$1" = -a ] && [ "$2" = --delete ] && [ "$3" = -- ] || exit 13
source=$4
destination=$5
case "${destination}" in
"${TEST_STAGING_ROOT}"/*) staging=1 ;;
*) staging=0 ;;
esac
call_count=$(grep -Fc '<call>' "${TEST_RSYNC_LOG}")
if [ "${call_count}" -le "${TEST_RSYNC_FAIL_COUNT}" ]; then
	if [ "${staging}" -eq 1 ]; then
		mkdir -p -- "${destination}"
		printf 'partial attempt\n' >"${destination}/partial attempt.txt"
	fi
	exit 17
fi
if [ "${staging}" -eq 1 ]; then
	rm -f -- "${destination}/partial attempt.txt"
	mkdir -p -- "${destination}"
	cp -R "${source}." "${destination}"
else
	[ -f "${source}Documents/source one – sample/first sample.txt" ] || exit 11
	[ -f "${source}Documents/source two – sample/second sample.txt" ] || exit 12
	[ -f "${source}Documents/absolute source – sample/absolute sample.txt" ] || exit 14
	[ ! -e "${source}Documents/source one – sample/partial attempt.txt" ] || exit 15
	if [ "${TEST_PROVIDER_FAIL_ONCE}" -eq 1 ] && [ ! -e "${TEST_PROVIDER_FAIL_MARKER}" ]; then
		: >"${TEST_PROVIDER_FAIL_MARKER}"
		exit 19
	fi
	printf '%s\n' "${destination}" >>"${TEST_DESTINATIONS_LOG}"
fi
EOF
chmod +x "${fake_bin}/rsync"

run_cloud() {
	env \
		PATH="${fake_bin}:${PATH}" \
		HOME="${home}" \
		TEST_DESTINATIONS_LOG="${destinations_log}" \
		TEST_MKTEMP_LOG="${mktemp_log}" \
		TEST_PROVIDER_FAIL_MARKER="${provider_fail_marker}" \
		TEST_PROVIDER_FAIL_ONCE="${TEST_PROVIDER_FAIL_ONCE:-0}" \
		TEST_RSYNC_FAIL_COUNT="${TEST_RSYNC_FAIL_COUNT:-0}" \
		TEST_RSYNC_LOG="${rsync_log}" \
		TEST_SLEEP_LOG="${sleep_log}" \
		TEST_STAGING_ROOT="${test_stage_root}" \
		TEST_MKTEMP_FAIL="${TEST_MKTEMP_FAIL:-0}" \
		"${script_dir}/backup" "$@"
}

sources_file="${script_dir}/sources"
cat >"${sources_file}" <<'EOF'
#!/bin/sh

~/Documents/source * – sample
EOF
printf '%s\n' "${home}/${source_three}" >>"${sources_file}"
test_stage_root="${tmp}/stage success"
: >"${rsync_log}"
: >"${destinations_log}"
: >"${mktemp_log}"
run_cloud >"${tmp}/success.out" 2>"${tmp}/success.err"
assert_file_contains 'mktemp -d /tmp/rsync-cloud.XXXXXX' "${mktemp_log}"
assert_eq "$(grep -Fc '<call>' "${rsync_log}")" '7'
assert_eq "$(grep -Fc -- '--delete' "${rsync_log}")" '7'
assert_file_contains "${cloud_root}/provider one/Backup/" "${destinations_log}"
assert_file_contains "${cloud_root}/provider two/Backup/" "${destinations_log}"
assert_file_contains "${cloud_root}/provider three/Backup/" "${destinations_log}"
assert_file_contains "${cloud_root}/provider four/Backup/" "${destinations_log}"
assert_file_contains 'Temporary filesystem capacity: 100G total, 25G used, 75G available' "${tmp}/success.out"
assert_eq "$(grep -Fc 'Temporary filesystem capacity:' "${tmp}/success.out")" '2'
assert_file_contains 'Staged source data size: 12M' "${tmp}/success.out"
assert_file_contains '3 source directories, 4 cloud storage directories' "${tmp}/success.out"
assert_file_exists "${cloud_root}/provider one/Backup"
[ ! -e "${test_stage_root}" ] || fail_test 'staging directory was not cleaned up'

: >"${rsync_log}"
: >"${destinations_log}"
test_stage_root="${tmp}/stage missing source"
cat >"${sources_file}" <<'EOF'
~/Documents/source one – sample
~/Documents/missing
EOF
if run_cloud >"${tmp}/missing.out" 2>"${tmp}/missing.err"; then
	fail_test 'missing source directories should stop synchronization'
fi
assert_file_contains 'Source directory does not exist' "${tmp}/missing.err"
[ ! -s "${destinations_log}" ] || fail_test 'cloud destinations were touched with a missing source'
[ ! -e "${test_stage_root}" ] || fail_test 'failed staging directory was not cleaned up'

: >"${rsync_log}"
: >"${destinations_log}"
test_stage_root="${tmp}/stage unmatched pattern"
cat >"${sources_file}" <<'EOF'
~/Documents/missing-*
EOF
if run_cloud >"${tmp}/unmatched-pattern.out" 2>"${tmp}/unmatched-pattern.err"; then
	fail_test 'unmatched source patterns should stop synchronization'
fi
assert_file_contains 'Source pattern did not match any paths' "${tmp}/unmatched-pattern.err"
[ ! -s "${destinations_log}" ] || fail_test 'cloud destinations were touched with an unmatched pattern'
if grep -F -- '--delete' "${rsync_log}" >/dev/null; then
	fail_test 'cloud synchronization ran with an unmatched source pattern'
fi
[ ! -e "${test_stage_root}" ] || fail_test 'unmatched-pattern staging directory was not cleaned up'

: >"${rsync_log}"
: >"${destinations_log}"
: >"${sleep_log}"
test_stage_root="${tmp}/stage retry"
cat >"${sources_file}" <<'EOF'
~/Documents/source * – sample
EOF
printf '%s\n' "${home}/${source_three}" >>"${sources_file}"
TEST_RSYNC_FAIL_COUNT=11
TEST_PROVIDER_FAIL_ONCE=1
export TEST_RSYNC_FAIL_COUNT TEST_PROVIDER_FAIL_ONCE
run_cloud >"${tmp}/retry.out" 2>"${tmp}/retry.err"
TEST_RSYNC_FAIL_COUNT=0
TEST_PROVIDER_FAIL_ONCE=0
export TEST_RSYNC_FAIL_COUNT TEST_PROVIDER_FAIL_ONCE
expected_retry_delays=$(printf '1\n2\n4\n8\n16\n32\n64\n128\n256\n300\n300\n1')
assert_eq "$(cat "${sleep_log}")" "${expected_retry_delays}"
assert_eq "$(grep -Fc '<call>' "${rsync_log}")" '19'
assert_eq "$(grep -Fc -- '--delete' "${rsync_log}")" '19'
assert_file_contains 'retrying in 1s' "${tmp}/retry.err"
assert_file_contains 'retrying in 300s' "${tmp}/retry.err"
assert_file_contains '3 source directories, 4 cloud storage directories' "${tmp}/retry.out"
assert_file_contains "${cloud_root}/provider four/Backup/" "${destinations_log}"
[ ! -e "${test_stage_root}" ] || fail_test 'retried staging directory was not cleaned up'

: >"${rsync_log}"
: >"${destinations_log}"
test_stage_root="${tmp}/stage creation failure"
TEST_MKTEMP_FAIL=1
export TEST_MKTEMP_FAIL
if run_cloud >"${tmp}/mktemp-failure.out" 2>"${tmp}/mktemp-failure.err"; then
	fail_test 'staging directory creation failures should stop synchronization'
fi
TEST_MKTEMP_FAIL=0
export TEST_MKTEMP_FAIL
assert_file_contains 'Could not create a staging directory' "${tmp}/mktemp-failure.err"
[ ! -s "${rsync_log}" ] || fail_test 'rsync ran without a staging directory'
[ ! -s "${destinations_log}" ] || fail_test 'cloud destinations were touched without a staging directory'

: >"${rsync_log}"
: >"${destinations_log}"
: >"${mktemp_log}"
if run_cloud unexpected-argument >"${tmp}/arguments.out" 2>"${tmp}/arguments.err"; then
	fail_test 'rsync-cloud should reject arguments'
else
	argument_status=$?
fi
assert_eq "${argument_status}" '1'
assert_file_contains 'This command does not accept arguments' "${tmp}/arguments.err"
[ ! -s "${rsync_log}" ] || fail_test 'rsync-cloud should reject arguments before running rsync'
[ ! -s "${destinations_log}" ] || fail_test 'rsync-cloud should reject arguments before syncing destinations'
[ ! -s "${mktemp_log}" ] || fail_test 'rsync-cloud should reject arguments before staging'
