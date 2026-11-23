#!/usr/bin/env sh
# shellcheck disable=SC1090,SC1091,SC2154

set -eu

. "$(dirname -- "$0")/_lib.sh"

tmp=$(make_temp_dir)
trap 'cleanup_temp_dir "${tmp}"' EXIT HUP INT TERM

home="${tmp}/home with spaces"
script_dir="${home}/dotfiles/backups"
fake_bin="${tmp}/fake bin"
cloud_root="${home}/Library/CloudStorage"
source_one='Documents/source one – sample'
source_two='Documents/source two – sample'
rsync_log="${tmp}/rsync.log"
destinations_log="${tmp}/destinations.log"
mktemp_log="${tmp}/mktemp.log"
mkdir -p \
	"${script_dir}" \
	"${fake_bin}" \
	"${home}/${source_one}" \
	"${home}/${source_two}" \
	"${cloud_root}/provider one" \
	"${cloud_root}/provider two" \
	"${cloud_root}/provider three" \
	"${cloud_root}/provider four"
cp -- "${test_root}/backups/rsync-cloud" "${script_dir}/rsync-cloud"
cp -- "${test_root}/backups/lib.sh" "${script_dir}/lib.sh"
chmod +x "${script_dir}/rsync-cloud"
printf 'first source\n' >"${home}/${source_one}/first sample.txt"
printf 'second source\n' >"${home}/${source_two}/second sample.txt"
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

cat >"${fake_bin}/rsync" <<'EOF'
#!/bin/sh
set -eu
printf '%s\n' '<call>' >>"${TEST_RSYNC_LOG}"
for argument do
	printf '%s\n' "${argument}" >>"${TEST_RSYNC_LOG}"
done
printf '%s\n' '</call>' >>"${TEST_RSYNC_LOG}"
[ "${TEST_RSYNC_FAIL:-0}" -eq 0 ] || exit 17
if [ "$#" -eq 4 ] && [ "$1" = -a ] && [ "$2" = -- ]; then
	source=$3
	destination=$4
	mkdir -p -- "${destination}"
	cp -R "${source}." "${destination}"
elif [ "$#" -eq 5 ] && [ "$1" = -a ] && [ "$2" = --delete ] && [ "$3" = -- ]; then
	source=$4
	destination=$5
	[ -f "${source}Documents/source one – sample/first sample.txt" ] || exit 11
	[ -f "${source}Documents/source two – sample/second sample.txt" ] || exit 12
	printf '%s\n' "${destination}" >>"${TEST_DESTINATIONS_LOG}"
else
	exit 13
fi
EOF
chmod +x "${fake_bin}/rsync"

run_cloud() {
	env \
		PATH="${fake_bin}:${PATH}" \
		HOME="${home}" \
		TEST_DESTINATIONS_LOG="${destinations_log}" \
		TEST_MKTEMP_LOG="${mktemp_log}" \
		TEST_RSYNC_LOG="${rsync_log}" \
		TEST_STAGING_ROOT="${test_stage_root}" \
		TEST_MKTEMP_FAIL="${TEST_MKTEMP_FAIL:-0}" \
		TEST_RSYNC_FAIL="${TEST_RSYNC_FAIL:-0}" \
		"${script_dir}/rsync-cloud" "$@"
}

sources_file="${script_dir}/rsync-cloud-sources"
cat >"${sources_file}" <<'EOF'
#!/bin/sh

~/Documents/source one – sample
EOF
printf '%s\n' "${home}/Documents/source two – sample" >>"${sources_file}"
test_stage_root="${tmp}/stage success"
: >"${rsync_log}"
: >"${destinations_log}"
: >"${mktemp_log}"
run_cloud >"${tmp}/success.out" 2>"${tmp}/success.err"
assert_file_contains 'mktemp -d /tmp/rsync-cloud.XXXXXX' "${mktemp_log}"
assert_eq "$(grep -Fc '<call>' "${rsync_log}")" '6'
assert_eq "$(grep -Fc -- '--delete' "${rsync_log}")" '4'
assert_file_contains "${cloud_root}/provider one/Backup/" "${destinations_log}"
assert_file_contains "${cloud_root}/provider two/Backup/" "${destinations_log}"
assert_file_contains "${cloud_root}/provider three/Backup/" "${destinations_log}"
assert_file_contains "${cloud_root}/provider four/Backup/" "${destinations_log}"
assert_file_contains '2 source directories, 4 cloud storage directories' "${tmp}/success.out"
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
if grep -F -- '--delete' "${rsync_log}" >/dev/null; then
	fail_test 'cloud synchronization ran with a missing source'
fi
[ ! -e "${test_stage_root}" ] || fail_test 'failed staging directory was not cleaned up'

: >"${rsync_log}"
: >"${destinations_log}"
test_stage_root="${tmp}/stage child failure"
cat >"${sources_file}" <<'EOF'
~/Documents/source one – sample
EOF
TEST_RSYNC_FAIL=1
export TEST_RSYNC_FAIL
if run_cloud >"${tmp}/child-failure.out" 2>"${tmp}/child-failure.err"; then
	fail_test 'rsync failures should fail the cloud backup'
fi
TEST_RSYNC_FAIL=0
export TEST_RSYNC_FAIL
[ ! -s "${destinations_log}" ] || fail_test 'cloud destinations were touched after a staging rsync failure'
[ ! -e "${test_stage_root}" ] || fail_test 'failed rsync staging directory was not cleaned up'

: >"${rsync_log}"
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
