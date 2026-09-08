#!/usr/bin/env sh
# shellcheck disable=SC1090,SC1091,SC2154

set -eu

. "$(dirname -- "$0")/_lib.sh"

tmp=$(make_temp_dir)
trap 'cleanup_temp_dir "${tmp}"' EXIT HUP INT TERM

bin_dir="${tmp}/bin"
command_log="${tmp}/commands.log"
mkdir -p "${bin_dir}"

cat >"${bin_dir}/truncate" <<'EOF'
#!/bin/sh
for arg in "$@"; do
	printf 'truncate:%s\n' "${arg}" >>"${COMMAND_LOG}"
done
EOF

cat >"${bin_dir}/vim" <<'EOF'
#!/bin/sh
for arg in "$@"; do
	printf 'vim:%s\n' "${arg}" >>"${COMMAND_LOG}"
done
EOF

chmod +x "${bin_dir}/truncate" "${bin_dir}/vim"

COMMAND_LOG="${command_log}" PATH="${bin_dir}:${PATH}" sh -c \
	'. "${1}/configs/bash/bashrc.d/vim.sh"; trunc_vim "$2" "$3"' \
	sh "${test_root}" first-file 'second file'

expected_log='truncate:-s0
truncate:first-file
truncate:second file
vim:first-file
vim:second file'
actual_log=$(cat "${command_log}")
assert_eq "${actual_log}" "${expected_log}"

home_dir="${tmp}/home"
mkdir -p "${home_dir}/.bashrc.d"
ln -s "${test_root}/configs/bash/bashrc.d/vim.sh" "${home_dir}/.bashrc.d/vim.sh"
: >"${command_log}"
COMMAND_LOG="${command_log}" HOME="${home_dir}" PATH="${bin_dir}:${PATH}" \
	bash --noprofile --rcfile "${test_root}/configs/bash/bashrc" -ic 'trunc-vim alias-file' \
	>/dev/null 2>/dev/null

expected_log='truncate:-s0
truncate:alias-file
vim:alias-file'
actual_log=$(cat "${command_log}")
assert_eq "${actual_log}" "${expected_log}"
