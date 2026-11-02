#!/usr/bin/env sh
# shellcheck disable=SC1090,SC1091,SC2154

set -eu

. "$(dirname -- "$0")/_lib.sh"

tmp=$(make_temp_dir)
trap 'cleanup_temp_dir "${tmp}"' EXIT HUP INT TERM

script_dir="${tmp}/dotfiles/restic"
bin="${tmp}/bin"
HOME="${tmp}/home with spaces"
ICLOUD_HOME="${tmp}/iCloud files"
RESTIC_LOG="${tmp}/restic.log"
mkdir -p "${script_dir}" "${bin}" "${HOME}/Pictures" "${HOME}/personal" "${HOME}/work" "${ICLOUD_HOME}"
cp -- "${test_root}/restic/backup" "${script_dir}/backup"
: >"${script_dir}/.env"

cat >"${bin}/restic" <<'EOF'
#!/bin/sh
operation=$1
shift
case "${operation}" in
backup)
	printf 'backup' >>"${RESTIC_LOG}"
	for argument in "$@"; do printf '|%s' "${argument}" >>"${RESTIC_LOG}"; done
	printf '\n' >>"${RESTIC_LOG}"
	;;
forget)
	printf 'forget\n' >>"${RESTIC_LOG}"
	;;
*) exit 2 ;;
esac
EOF
chmod +x "${bin}/restic"

export HOME ICLOUD_HOME RESTIC_LOG
PATH="${bin}:${PATH}"
export PATH
sh "${script_dir}/backup"

assert_file_contains "|${ICLOUD_HOME}|${HOME}/Pictures|${HOME}/work" "${RESTIC_LOG}"
if grep -Fq "${HOME}/personal" "${RESTIC_LOG}"; then
	fail_test 'backup should no longer include ~/personal'
fi
assert_eq "$(grep -Fc 'backup|' "${RESTIC_LOG}")" '1'
assert_eq "$(grep -Fc 'forget' "${RESTIC_LOG}")" '1'

rm -rf -- "${HOME}/work"
: >"${RESTIC_LOG}"
sh "${script_dir}/backup"
assert_file_contains "|${ICLOUD_HOME}|${HOME}/Pictures" "${RESTIC_LOG}"
if grep -Fq "${HOME}/work" "${RESTIC_LOG}"; then
	fail_test 'backup should skip missing directories'
fi
assert_eq "$(grep -Fc 'backup|' "${RESTIC_LOG}")" '1'
assert_eq "$(grep -Fc 'forget' "${RESTIC_LOG}")" '1'
