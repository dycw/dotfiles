# shellcheck shell=bash
_ts_bin=''
if command -v tailscale >/dev/null 2>&1; then
	_ts_bin=tailscale
elif command -v Tailscale >/dev/null 2>&1; then
	_ts_bin=Tailscale
fi
if [ -n "${_ts_bin}" ]; then
	ts() {
		local out
		out=$("${_ts_bin}" status 2>&1) && printf '%s\n' "${out}" && return
		sleep 3
		"${_ts_bin}" status
	}
	ts_up() {
		"${_ts_bin}" up --accept-dns --accept-routes \
			--auth-key "${TAILSCALE_AUTH_KEY:?}" \
			--hostname "${TAILSCALE_HOSTNAME:-$(hostname -s)}" \
			--login-server "${TAILSCALE_LOGIN_SERVER:?}" \
			--reset "$@"
	}
	ts_down() { "${_ts_bin}" down; }
	ts_restart() { ts_down && ts_up "$@"; }
	ts_exit_node() { "${_ts_bin}" set --exit-node=qrt-nanode; }
	ts_no_exit_node() { "${_ts_bin}" set --exit-node=; }
	wts() { watch --color --differences --interval=1 -- "${_ts_bin}" status; }
fi
