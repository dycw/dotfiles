#!/usr/bin/env sh
# shellcheck disable=SC1090,SC1091,SC2154

set -eu

. "$(dirname -- "$0")/_lib.sh"

tmp=$(make_temp_dir)
trap 'cleanup_temp_dir "${tmp}"' EXIT HUP INT TERM

home_dir="${tmp}/home"
xdg_dir="${tmp}/xdg"
mkdir -p "${home_dir}" "${xdg_dir}"

HOME="${home_dir}"
XDG_CONFIG_HOME="${xdg_dir}"
export HOME XDG_CONFIG_HOME

_SETUP_MAIN=0 . "${test_root}/setup.sh"

sample="${test_root}/README.md"
link_home "${sample}" .bashrc
link_config "${sample}" shell/readme.md
link_direct "${sample}" "${home_dir}/direct/README.md"

assert_symlink_target "${home_dir}/.bashrc" "${sample}"
assert_symlink_target "${xdg_dir}/shell/readme.md" "${sample}"
assert_symlink_target "${home_dir}/direct/README.md" "${sample}"

line_file="${tmp}/lines.txt"
ensure_line_in_file 'alpha' "${line_file}"
ensure_line_in_file 'alpha' "${line_file}"
assert_eq "$(wc -l <"${line_file}" | tr -d ' ')" '1'

configs="${test_root}/configs" setup_ssh
assert_file_exists "${home_dir}/.ssh/authorized_keys"
assert_file_exists "${home_dir}/.ssh/config"
assert_file_exists "${home_dir}/.ssh/config.d"
assert_file_contains 'Include ~/.ssh/config.d/*' "${home_dir}/.ssh/config"
