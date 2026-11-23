#!/usr/bin/env sh
# shellcheck disable=SC1090,SC1091,SC2154

set -eu

. "$(dirname -- "$0")/_lib.sh"

tmp=$(make_temp_dir)
trap 'cleanup_temp_dir "${tmp}"' EXIT HUP INT TERM

fake_bin="${tmp}/fake bin"
restic_log="${tmp}/restic.log"
mkdir -p "${fake_bin}"
cat >"${fake_bin}/restic" <<'EOF'
#!/bin/sh
set -eu
printf '%s|%s\n' "$1" "${TEST_RESTIC_CONFIG:-missing}" >>"${TEST_RESTIC_LOG}"
EOF
chmod +x "${fake_bin}/restic"

backup_home="${tmp}/backup home"
backups_dir="${backup_home}/dotfiles/backups"
restic_dir="${backups_dir}/restic"
mkdir -p "${restic_dir}" "${backup_home}/Pictures"
cp -- "${test_root}/backups/restic/backup" "${restic_dir}/backup"
cp -- "${test_root}/backups/lib.sh" "${backups_dir}/lib.sh"
chmod +x "${restic_dir}/backup"
printf "export TEST_RESTIC_CONFIG='backup-config'\n" >"${restic_dir}/.env"
if ! env \
	HOME="${backup_home}" \
	PATH="${fake_bin}:${PATH}" \
	TEST_RESTIC_LOG="${restic_log}" \
	"${restic_dir}/backup" >"${tmp}/backup.out" 2>"${tmp}/backup.err"; then
	fail_test 'Restic backup should load its sibling environment file'
fi
assert_file_contains 'backup|backup-config' "${restic_log}"
assert_file_contains 'forget|backup-config' "${restic_log}"
assert_file_exists "${restic_dir}/.env"
restic_call_count=$(wc -l <"${restic_log}")
if env \
	HOME="${backup_home}" \
	PATH="${fake_bin}:${PATH}" \
	TEST_RESTIC_LOG="${restic_log}" \
	"${restic_dir}/backup" --unexpected >"${tmp}/arguments.out" 2>"${tmp}/arguments.err"; then
	fail_test 'Restic backup should reject command-line arguments'
fi
assert_file_contains 'This command does not accept arguments' "${tmp}/arguments.err"
assert_eq "$(wc -l <"${restic_log}")" "${restic_call_count}"

snapshots_home="${tmp}/snapshots home"
snapshots_backups_dir="${snapshots_home}/dotfiles/backups"
snapshots_dir="${snapshots_backups_dir}/restic"
mkdir -p "${snapshots_dir}"
cp -- "${test_root}/backups/restic/snapshots" "${snapshots_dir}/snapshots"
cp -- "${test_root}/backups/lib.sh" "${snapshots_backups_dir}/lib.sh"
chmod +x "${snapshots_dir}/snapshots"
printf "export TEST_RESTIC_CONFIG='snapshots-config'\n" >"${snapshots_dir}/.env"
if ! env \
	HOME="${snapshots_home}" \
	PATH="${fake_bin}:${PATH}" \
	TEST_RESTIC_LOG="${restic_log}" \
	"${snapshots_dir}/snapshots" >"${tmp}/snapshots.out" 2>"${tmp}/snapshots.err"; then
	fail_test 'Restic snapshots should load its sibling environment file'
fi
assert_file_contains 'snapshots|snapshots-config' "${restic_log}"
assert_file_exists "${snapshots_dir}/.env"

missing_home="${tmp}/missing config home"
missing_backups_dir="${missing_home}/dotfiles/backups"
missing_dir="${missing_backups_dir}/restic"
mkdir -p "${missing_dir}" "${missing_home}/Pictures"
cp -- "${test_root}/backups/restic/backup" "${missing_dir}/backup"
cp -- "${test_root}/backups/lib.sh" "${missing_backups_dir}/lib.sh"
chmod +x "${missing_dir}/backup"
restic_call_count=$(wc -l <"${restic_log}")
if env \
	HOME="${missing_home}" \
	PATH="${fake_bin}:${PATH}" \
	TEST_RESTIC_LOG="${restic_log}" \
	"${missing_dir}/backup" >"${tmp}/missing.out" 2>"${tmp}/missing.err"; then
	fail_test 'Restic backup should require its sibling environment file'
fi
assert_file_contains "Unable to find environment file '${missing_dir}/.env'" "${tmp}/missing.err"
assert_eq "$(wc -l <"${restic_log}")" "${restic_call_count}"
