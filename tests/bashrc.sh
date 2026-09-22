#!/usr/bin/env sh
# shellcheck disable=SC1091,SC2154

set -eu

. "$(dirname -- "$0")/_lib.sh"

tmp=$(make_temp_dir)
trap 'cleanup_temp_dir "${tmp}"' EXIT HUP INT TERM

home_dir="${tmp}/home"
mkdir -p "${home_dir}/.bashrc.d" "${home_dir}/.ssh"
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

export HOME="${home_dir}"

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
if [ -n "${SSH_EXIT_SEQUENCE:-}" ]; then
	count=0
	[ -f "${SSH_RECONNECT_STATE}" ] && count=$(cat "${SSH_RECONNECT_STATE}")
	count=$((count + 1))
	printf '%s\n' "${count}" >"${SSH_RECONNECT_STATE}"
	status=$(printf '%s' "${SSH_EXIT_SEQUENCE}" | cut -d, -f "${count}")
	if [ -n "${SSH_ERROR:-}" ]; then
		error=${SSH_ERROR}
	else
		error=$(printf '%s' "${SSH_ERROR_SEQUENCE:-}" | cut -d, -f "${count}")
	fi
	[ -n "${error}" ] && printf '%s\n' "${error}" >&2
	exit "${status:-255}"
fi
exit 0
EOF
cat >"${bin_dir}/ssh-keygen" <<'EOF'
#!/bin/sh
printf '%s\n' "$*" >>"${SSH_KEYGEN_LOG}"
case "$1" in
-F)
	case " ${SSH_KNOWN_HOSTS:-} " in
	*" $2 "*) exit 0 ;;
	*) exit 1 ;;
	esac
	;;
esac
EOF
cat >"${bin_dir}/ssh-keyscan" <<'EOF'
#!/bin/sh
printf '%s\n' 'gitea-server.ai ssh-ed25519 replacement-key'
EOF
chmod +x "${bin_dir}/ssh" "${bin_dir}/ssh-keygen" "${bin_dir}/ssh-keyscan"
ssh_log="${tmp}/ssh.log"
ssh_keygen_log="${tmp}/ssh-keygen.log"

SSH_LOG="${ssh_log}" SSH_KEYGEN_LOG="${ssh_keygen_log}" PATH="${bin_dir}:${PATH}" sh -c '. "${1}/configs/bash/bashrc.d/ssh.sh"; ssh_auto root@pve7.internal' sh "${test_root}"
retry_args=$(tr -d '\n' <"${ssh_log}")
assert_eq "${retry_args}" '-o HostKeyAlgorithms=ssh-ed25519 -o StrictHostKeyChecking=yes -o ServerAliveInterval=10 -o ServerAliveCountMax=1000000 root@pve7.internal'
retry_keygen_args=$(tr -d '\n' <"${ssh_keygen_log}")
assert_eq "${retry_keygen_args}" '-R pve7.internal'

: >"${ssh_log}"
: >"${ssh_keygen_log}"
SSH_LOG="${ssh_log}" SSH_KEYGEN_LOG="${ssh_keygen_log}" PATH="${bin_dir}:${PATH}" sh -c '. "${1}/configs/bash/bashrc.d/ssh.sh"; ssh_auto --root root@pve7.qrt' sh "${test_root}"
root_retry_args=$(tr -d '\n' <"${ssh_log}")
assert_eq "${root_retry_args}" '-o HostKeyAlgorithms=ssh-ed25519 -o StrictHostKeyChecking=yes -o ServerAliveInterval=10 -o ServerAliveCountMax=1000000 -t root@pve7.qrt sudo -i'
assert_eq "$(tr -d '\n' <"${ssh_keygen_log}")" '-R pve7.qrt'

: >"${ssh_log}"
: >"${ssh_keygen_log}"
SSH_LOG="${ssh_log}" SSH_KEYGEN_LOG="${ssh_keygen_log}" PATH="${bin_dir}:${PATH}" sh -c '. "${1}/configs/bash/bashrc.d/ssh.sh"; ssh_auto nonroot@gitea-server.ai' sh "${test_root}"
gitea_args=$(tr -d '\n' <"${ssh_log}")
assert_eq "${gitea_args}" '-o HostKeyAlgorithms=ssh-ed25519 -o StrictHostKeyChecking=yes -o ServerAliveInterval=10 -o ServerAliveCountMax=1000000 nonroot@gitea-server.ai'
assert_eq "$(tr -d '\n' <"${ssh_keygen_log}")" '-R gitea-server.ai'

: >"${ssh_log}"
: >"${ssh_keygen_log}"
SSH_KNOWN_HOSTS=workspace-abc.qrt SSH_LOG="${ssh_log}" SSH_KEYGEN_LOG="${ssh_keygen_log}" PATH="${bin_dir}:${PATH}" sh -c '. "${1}/configs/bash/bashrc.d/ssh.sh"; ssh_auto -t nonroot@workspace-abc.qrt "tmux attach-session -t agents"' sh "${test_root}"
known_host_args=$(tr -d '\n' <"${ssh_log}")
assert_eq "${known_host_args}" '-o HostKeyAlgorithms=ssh-ed25519 -o StrictHostKeyChecking=yes -o ServerAliveInterval=10 -o ServerAliveCountMax=1000000 -t nonroot@workspace-abc.qrt tmux attach-session -t agents'
assert_eq "$(tr -d '\n' <"${ssh_keygen_log}")" '-R workspace-abc.qrt'

: >"${ssh_log}"
: >"${ssh_keygen_log}"
SSH_LOG="${ssh_log}" SSH_KEYGEN_LOG="${ssh_keygen_log}" PATH="${bin_dir}:${PATH}" sh -c '. "${1}/configs/bash/bashrc.d/ssh.sh"; ssh_auto user@example.com' sh "${test_root}"
external_host_args=$(tr -d '\n' <"${ssh_log}")
assert_eq "${external_host_args}" '-o HostKeyAlgorithms=ssh-ed25519 -o StrictHostKeyChecking=yes -o ServerAliveInterval=10 -o ServerAliveCountMax=1000000 user@example.com'
assert_eq "$(tr -d '\n' <"${ssh_keygen_log}")" '-R example.com'

: >"${ssh_log}"
: >"${ssh_keygen_log}"
SSH_LOG="${ssh_log}" SSH_KEYGEN_LOG="${ssh_keygen_log}" PATH="${bin_dir}:${PATH}" sh -c '. "${1}/configs/bash/bashrc.d/ssh.sh"; ssh_auto nonroot@postgres-prod.qrt' sh "${test_root}"
connected_args=$(tr -d '\n' <"${ssh_log}")
assert_eq "${connected_args}" '-o HostKeyAlgorithms=ssh-ed25519 -o StrictHostKeyChecking=yes -o ServerAliveInterval=10 -o ServerAliveCountMax=1000000 nonroot@postgres-prod.qrt'
assert_eq "$(tr -d '\n' <"${ssh_keygen_log}")" '-R postgres-prod.qrt'

: >"${ssh_log}"
: >"${ssh_keygen_log}"
reconnect_state="${tmp}/ssh-reconnect-state"
SSH_KNOWN_HOSTS=workspace-abc.qrt SSH_EXIT_SEQUENCE='255,255,0' SSH_ERROR='Timeout, server workspace-abc.qrt not responding.' SSH_RECONNECT_STATE="${reconnect_state}" SSH_LOG="${ssh_log}" SSH_KEYGEN_LOG="${ssh_keygen_log}" PATH="${bin_dir}:${PATH}" sh -c '. "${1}/configs/bash/bashrc.d/ssh.sh"; ssh_auto -t nonroot@workspace-abc.qrt "tmux attach-session -t agents"' sh "${test_root}"
reconnect_args=$(tr -d '\n' <"${ssh_log}")
assert_eq "${reconnect_args}" '-o HostKeyAlgorithms=ssh-ed25519 -o StrictHostKeyChecking=yes -o ServerAliveInterval=10 -o ServerAliveCountMax=1000000 -t nonroot@workspace-abc.qrt tmux attach-session -t agents-o HostKeyAlgorithms=ssh-ed25519 -o StrictHostKeyChecking=yes -o ServerAliveInterval=10 -o ServerAliveCountMax=1000000 -t nonroot@workspace-abc.qrt tmux attach-session -t agents-o HostKeyAlgorithms=ssh-ed25519 -o StrictHostKeyChecking=yes -o ServerAliveInterval=10 -o ServerAliveCountMax=1000000 -t nonroot@workspace-abc.qrt tmux attach-session -t agents'
assert_eq "$(cat "${reconnect_state}")" '3'
assert_eq "$(tr -d '\n' <"${ssh_keygen_log}")" '-R workspace-abc.qrt-R workspace-abc.qrt-R workspace-abc.qrt'

: >"${ssh_log}"
: >"${ssh_keygen_log}"
command_state="${tmp}/ssh-command-state"
if SSH_KNOWN_HOSTS=workspace-abc.qrt SSH_EXIT_SEQUENCE='255,0' SSH_RECONNECT_STATE="${command_state}" SSH_LOG="${ssh_log}" SSH_KEYGEN_LOG="${ssh_keygen_log}" PATH="${bin_dir}:${PATH}" sh -c '. "${1}/configs/bash/bashrc.d/ssh.sh"; ssh_auto nonroot@workspace-abc.qrt "true"' sh "${test_root}"; then
	fail_test 'ssh_auto should preserve the remote command exit status'
fi
assert_eq "$(cat "${command_state}")" '1'

: >"${ssh_log}"
: >"${ssh_keygen_log}"
normal_exit_state="${tmp}/ssh-normal-exit-state"
SSH_KNOWN_HOSTS=workspace-abc.qrt SSH_EXIT_SEQUENCE='0,0' SSH_RECONNECT_STATE="${normal_exit_state}" SSH_LOG="${ssh_log}" SSH_KEYGEN_LOG="${ssh_keygen_log}" PATH="${bin_dir}:${PATH}" sh -c '. "${1}/configs/bash/bashrc.d/ssh.sh"; ssh_auto -t nonroot@workspace-abc.qrt "tmux attach-session -t agents"' sh "${test_root}"
assert_eq "$(cat "${normal_exit_state}")" '1'

: >"${ssh_log}"
: >"${ssh_keygen_log}"
interrupted_state="${tmp}/ssh-interrupted-state"
if SSH_KNOWN_HOSTS=workspace-abc.qrt SSH_EXIT_SEQUENCE='130,0' SSH_RECONNECT_STATE="${interrupted_state}" SSH_LOG="${ssh_log}" SSH_KEYGEN_LOG="${ssh_keygen_log}" PATH="${bin_dir}:${PATH}" sh -c '. "${1}/configs/bash/bashrc.d/ssh.sh"; ssh_auto -t nonroot@workspace-abc.qrt "tmux attach-session -t agents"' sh "${test_root}"; then
	fail_test 'ssh_auto should stop after Ctrl-C'
else
	ssh_auto_status=$?
fi
assert_eq "${ssh_auto_status}" '130'
assert_eq "$(cat "${interrupted_state}")" '1'

: >"${ssh_log}"
: >"${ssh_keygen_log}"
permanent_state="${tmp}/ssh-permanent-state"
if SSH_KNOWN_HOSTS=workspace-abc.qrt SSH_EXIT_SEQUENCE='255,0' SSH_ERROR_SEQUENCE='Permission denied (publickey).' SSH_RECONNECT_STATE="${permanent_state}" SSH_LOG="${ssh_log}" SSH_KEYGEN_LOG="${ssh_keygen_log}" PATH="${bin_dir}:${PATH}" sh -c '. "${1}/configs/bash/bashrc.d/ssh.sh"; ssh_auto -t nonroot@workspace-abc.qrt "tmux attach-session -t agents"' sh "${test_root}"; then
	fail_test 'ssh_auto should not reconnect after an authentication failure'
fi
assert_eq "$(cat "${permanent_state}")" '1'
