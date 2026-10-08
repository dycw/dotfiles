#!/usr/bin/env sh
# shellcheck disable=SC1090,SC1091,SC2154

set -eu

. "$(dirname -- "$0")/_lib.sh"

tmp=$(make_temp_dir)
trap 'cleanup_temp_dir "${tmp}"' EXIT HUP INT TERM

bin_dir="${tmp}/bin"
fdfind_log="${tmp}/fdfind.log"
mkdir -p "${bin_dir}"

cat >"${bin_dir}/fdfind" <<'EOF'
#!/bin/sh
printf '%s\n' "$*" >>"${FDFIND_LOG}"
EOF

cat >"${bin_dir}/fzf" <<'EOF'
#!/bin/sh
exit 0
EOF
chmod +x "${bin_dir}/fdfind" "${bin_dir}/fzf"

PATH="${bin_dir}:/usr/bin:/bin"
FDFIND_LOG=${fdfind_log}
TEST_ROOT=${test_root}
export PATH FDFIND_LOG TEST_ROOT

bash --noprofile --norc <<'BASH'
set -eu

fail_test() {
	printf 'test failure: %s\n' "$*" >&2
	exit 1
}
assert_eq() {
	actual=$1
	expected=$2
	[ "${actual}" = "${expected}" ] || fail_test "expected '${expected}', got '${actual}'"
}

. "${TEST_ROOT}/configs/bash/bashrc.d/fd.sh"
. "${TEST_ROOT}/configs/bash/bashrc.d/fzf.sh"

[ "$(type -t fd)" = function ]
assert_eq "${FZF_DEFAULT_COMMAND}" "fdfind --hidden --type=file --follow --exclude .git"
assert_eq "${FZF_CTRL_T_COMMAND}" "fdfind --hidden --type=file --follow --exclude .git"
assert_eq "${FZF_ALT_C_COMMAND}" "fdfind --hidden --type=directory --follow --exclude .git"

fd --hidden --type=file --follow --exclude .git
assert_eq "$(cat "${FDFIND_LOG}")" "--hidden --type=file --follow --exclude .git"
: >"${FDFIND_LOG}"

bash --noprofile --norc -c "${FZF_DEFAULT_COMMAND}"
bash --noprofile --norc -c "${FZF_CTRL_T_COMMAND}"
bash --noprofile --norc -c "${FZF_ALT_C_COMMAND}"
assert_eq "$(cat "${FDFIND_LOG}")" "$(printf '%s\n' \
	'--hidden --type=file --follow --exclude .git' \
	'--hidden --type=file --follow --exclude .git' \
	'--hidden --type=directory --follow --exclude .git')"
BASH
