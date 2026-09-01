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
_completion_helper() { printf 'completion\n'; }
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

if HOME="${home_dir}" bash --noprofile --rcfile "${test_root}/configs/bash/bashrc" -ic 'alias -completion-helper' >"${tmp}/completion-alias.log" 2>&1; then
	fail_test "bashrc should not create dashed aliases for underscore-prefixed helpers"
fi

if HOME="${home_dir}" bash --noprofile --rcfile "${test_root}/configs/bash/bashrc" -ic 'alias __private-helper' >"${tmp}/private-alias.log" 2>&1; then
	fail_test "bashrc should not create dashed aliases for private helpers"
fi

bin_dir="${tmp}/bin"
mkdir -p "${bin_dir}"
cat >"${bin_dir}/tailscale" <<'EOF'
#!/bin/sh
cat <<'JSON'
{"Peer":[{"HostName":"DW-MacMini","TailscaleIPs":["100.64.0.6"]},{"HostName":"DW-Swift","TailscaleIPs":["100.64.0.13"]}]}
JSON
EOF
chmod +x "${bin_dir}/tailscale"
resolved_ip=$(PATH="${bin_dir}:${PATH}" sh -c '. "${1}/configs/bash/bashrc.d/ssh.sh"; __tailscale_ip dw-macmini' sh "${test_root}")
assert_eq "${resolved_ip}" '100.64.0.6'

cat >"${bin_dir}/ssh" <<'EOF'
#!/bin/sh
printf '%s\n' "$*" >>"${SSH_LOG}"
case "$*" in
*StrictHostKeyChecking=yes*) exit 1 ;;
esac
EOF
cat >"${bin_dir}/ssh-keygen" <<'EOF'
#!/bin/sh
printf '%s\n' "$*" >>"${SSH_KEYGEN_LOG}"
EOF
chmod +x "${bin_dir}/ssh" "${bin_dir}/ssh-keygen"
ssh_log="${tmp}/ssh.log"
ssh_keygen_log="${tmp}/ssh-keygen.log"
SSH_LOG="${ssh_log}" SSH_KEYGEN_LOG="${ssh_keygen_log}" PATH="${bin_dir}:${PATH}" sh -c '. "${1}/configs/bash/bashrc.d/ssh.sh"; ssh_auto root@pve7.internal' sh "${test_root}"
retry_args=$(tr -d '\n' <"${ssh_log}")
assert_eq "${retry_args}" '-o HostKeyAlgorithms=ssh-ed25519 -o StrictHostKeyChecking=yes root@pve7.internal-o HostKeyAlgorithms=ssh-ed25519 -o StrictHostKeyChecking=accept-new root@pve7.internal'
retry_keygen_args=$(tr -d '\n' <"${ssh_keygen_log}")
assert_eq "${retry_keygen_args}" '-R pve7.internal'

: >"${ssh_log}"
: >"${ssh_keygen_log}"
SSH_LOG="${ssh_log}" SSH_KEYGEN_LOG="${ssh_keygen_log}" PATH="${bin_dir}:${PATH}" sh -c '. "${1}/configs/bash/bashrc.d/ssh.sh"; ssh_auto --root root@pve7.qrt' sh "${test_root}"
root_retry_args=$(tr -d '\n' <"${ssh_log}")
assert_eq "${root_retry_args}" '-o HostKeyAlgorithms=ssh-ed25519 -o StrictHostKeyChecking=yes -t root@pve7.qrt sudo -i-o HostKeyAlgorithms=ssh-ed25519 -o StrictHostKeyChecking=accept-new -t root@pve7.qrt sudo -i'
