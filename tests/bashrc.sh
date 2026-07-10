#!/usr/bin/env sh
# shellcheck disable=SC1091,SC2154

set -eu

. "$(dirname -- "$0")/_lib.sh"

tmp=$(make_temp_dir)
trap 'cleanup_temp_dir "${tmp}"' EXIT HUP INT TERM

home_dir="${tmp}/home"
mkdir -p "${home_dir}/.bashrc.d"
cat >"${home_dir}/.bashrc.d/test-aliases.sh" <<'EOF'
edit_test_file() { printf 'snake:%s\n' "$1"; }
__private_helper() { printf 'private\n'; }
EOF

stdout="${tmp}/stdout.log"
stderr="${tmp}/stderr.log"
HOME="${home_dir}" bash --noprofile --rcfile "${test_root}/configs/bash/bashrc" -ic exit >"${stdout}" 2>"${stderr}"

if grep -Fq '_f: command not found' "${stderr}"; then
	fail_test "bashrc should not invoke _f while sourcing completion files"
fi

alias_output=$(HOME="${home_dir}" bash --noprofile --rcfile "${test_root}/configs/bash/bashrc" -ic 'edit-test-file ok' 2>"${tmp}/alias-stderr.log")
assert_eq "${alias_output}" 'snake:ok'

if HOME="${home_dir}" bash --noprofile --rcfile "${test_root}/configs/bash/bashrc" -ic 'alias __private-helper' >"${tmp}/private-alias.log" 2>&1; then
	fail_test "bashrc should not create dashed aliases for private helpers"
fi
