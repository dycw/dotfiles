# shellcheck shell=bash
if command -v tailscale >/dev/null 2>&1; then
	ts() {
		local out
		out=$(tailscale status 2>&1) && printf '%s\n' "${out}" && return
		sleep 3
		tailscale status
	}
	ts_up() {
		tailscale up --accept-dns --accept-routes \
			--auth-key "${TAILSCALE_AUTH_KEY:?}" \
			--hostname "${TAILSCALE_HOSTNAME:-$(hostname -s)}" \
			--login-server "${TAILSCALE_LOGIN_SERVER:?}" \
			--reset "$@"
	}
	ts_down() { tailscale down; }
	ts_restart() { ts_down && ts_up "$@"; }
	ts_exit_node() { tailscale set --exit-node=qrt-nanode; }
	ts_no_exit_node() { tailscale set --exit-node=; }
	wts() { watch --color --differences --interval=1 -- tailscale status; }
fi
