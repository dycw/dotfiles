#!/usr/bin/env sh
# shellcheck disable=SC1091,SC2154

set -eu

. "$(dirname -- "$0")/_lib.sh"

tmp=$(make_temp_dir)
trap 'cleanup_temp_dir "${tmp}"' EXIT HUP INT TERM

home_dir="${tmp}/home"
mkdir -p "${home_dir}"

stdout="${tmp}/stdout.log"
stderr="${tmp}/stderr.log"
HOME="${home_dir}" bash --noprofile --rcfile "${test_root}/configs/bash/bashrc" -ic exit >"${stdout}" 2>"${stderr}"

if grep -Fq '_f: command not found' "${stderr}"; then
	fail_test "bashrc should not invoke _f while sourcing completion files"
fi
