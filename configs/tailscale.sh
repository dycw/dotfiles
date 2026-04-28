#!/usr/bin/env sh

set -eu

if [ -d /Applications/Tailscale.app/Contents/MacOS ]; then
	export PATH="/Applications/Tailscale.app/Contents/MacOS${PATH:+:${PATH}}"
fi

if [ "${-#*i}" = "$-" ]; then
	return
fi

export TAILSCALE_AUTH_KEY="${XDG_CONFIG_HOME:-${HOME}/.config}/tailscale/auth-key.txt"

ssh_dw_mac() { ssh-auto derekwan@dw-mac.tail.net; }
ssh_dw_swift() { ssh-auto derek@dw-swift.tail.net; }
ssh_rh_mac() { ssh-auto derekwan@rh-mac.tail.net; }

_tailscale_status_cmd() {
	if command -v tailscale >/dev/null 2>&1; then
		tailscale "$@"
	elif command -v Tailscale >/dev/null 2>&1; then
		Tailscale "$@"
	elif command -v docker >/dev/null 2>&1; then
		docker exec --interactive tailscale tailscale "$@"
	else
		echo "'tailscale' expected 'tailscale', 'Tailscale' or 'docker' to be available; got neither" >&2
		return 1
	fi
}

ts() { _tailscale_status_cmd status; }
ts_exit_node() { _tailscale_status_cmd set --exit-node=qrt-nanode; }
ts_no_exit_node() { _tailscale_status_cmd set --exit-node=; }
wts() {
	if command -v tailscale >/dev/null 2>&1; then
		watch --color --differences --interval=1 -- tailscale status
	elif command -v Tailscale >/dev/null 2>&1; then
		watch --color --differences --interval=1 -- Tailscale status
	elif command -v docker >/dev/null 2>&1; then
		docker exec --interactive tailscale watch --color --differences --interval=1 -- tailscale status
	else
		echo "'wts' expected 'tailscale', 'Tailscale' or 'docker' to be available; got neither" >&2
		return 1
	fi
}
