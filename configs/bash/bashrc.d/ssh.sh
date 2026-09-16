# shellcheck shell=sh

#### private helpers ###########################################################

__ssh_keyscan() {
	if [ "$#" -lt 1 ]; then
		echo "'__ssh_keyscan' expected [1..] arguments HOST [PORT]; got $#" >&2
		return 1
	fi
	host="$1"
	shift
	port='' args="-t ed25519"
	while [ "$#" -gt 0 ]; do
		case "$1" in
		-p)
			port="$2"
			shift 2
			;;
		*) break ;;
		esac
	done
	[ -n "${port}" ] && args="${args} -p ${port}"
	tmp=$(mktemp)
	# shellcheck disable=SC2086
	if ssh-keyscan ${args} -q "${host}" >>~/.ssh/known_hosts 2>"${tmp}"; then
		rm -f -- "${tmp}"
		return
	fi
	if grep -q "illegal option -- q" "${tmp}"; then
		# shellcheck disable=SC2086
		ssh-keyscan ${args} "${host}" >>~/.ssh/known_hosts
	else
		cat "${tmp}" >&2
		rm -f -- "${tmp}"
		return 1
	fi
	rm -f -- "${tmp}"
}

__ssh_strict() {
	root=0 tty='' destination=''
	while [ "$#" -gt 0 ]; do
		case "$1" in
		-r | --root)
			root=1
			shift
			;;
		-t)
			tty='-t'
			shift
			;;
		*) break ;;
		esac
	done
	[ "$#" -gt 0 ] || return 1
	destination="$1"
	shift
	if [ "${root}" -eq 1 ]; then
		ssh -o HostKeyAlgorithms=ssh-ed25519 -o StrictHostKeyChecking=yes \
			-o ServerAliveInterval=10 -o ServerAliveCountMax=1000000 \
			-t "${destination}" 'sudo -i'
	else
		ssh -o HostKeyAlgorithms=ssh-ed25519 -o StrictHostKeyChecking=yes \
			-o ServerAliveInterval=10 -o ServerAliveCountMax=1000000 \
			${tty:+"${tty}"} "${destination}" "$@"
	fi
}

__ssh_accept_new() {
	root=0 tty='' destination=''
	while [ "$#" -gt 0 ]; do
		case "$1" in
		-r | --root)
			root=1
			shift
			;;
		-t)
			tty='-t'
			shift
			;;
		*) break ;;
		esac
	done
	[ "$#" -gt 0 ] || return 1
	destination="$1"
	shift
	if [ "${root}" -eq 1 ]; then
		ssh -o HostKeyAlgorithms=ssh-ed25519 -o StrictHostKeyChecking=accept-new \
			-o ServerAliveInterval=10 -o ServerAliveCountMax=1000000 \
			-t "${destination}" 'sudo -i'
	else
		ssh -o HostKeyAlgorithms=ssh-ed25519 -o StrictHostKeyChecking=accept-new \
			-o ServerAliveInterval=10 -o ServerAliveCountMax=1000000 \
			${tty:+"${tty}"} "${destination}" "$@"
	fi
}

#### public utilities ##########################################################

add_known_host() {
	if [ "$#" -eq 0 ]; then
		echo "'add-known-host' expected [1..2] arguments HOST [PORT]; got $#" >&2
		return 1
	fi
	host="$1"
	if [ "$#" -ge 2 ]; then
		ssh-keygen -R "[${host}]:$2"
		__ssh_keyscan "${host}" -p "$2"
	else
		ssh-keygen -R "${host}"
		__ssh_keyscan "${host}"
	fi
}

edit_authorized_keys() { "${EDITOR}" "${HOME}/.ssh/authorized_keys"; }
edit_known_hosts() { "${EDITOR}" "${HOME}/.ssh/known_hosts"; }
edit_ssh_config() { "${EDITOR}" "${HOME}/.ssh/config"; }

generate_ssh_key() {
	filename="id_ed25519"
	while [ "$#" -gt 0 ]; do
		case "$1" in
		-f | --filename)
			filename="$2"
			shift 2
			;;
		*) break ;;
		esac
	done
	ssh-keygen -C '' -f "${filename}" -P '' -t ed25519
}

#### ssh_auto ##################################################################

__tailscale_ip() {
	if [ "$#" -ne 1 ]; then
		echo "'__tailscale_ip' expected HOST; got $#" >&2
		return 1
	fi
	host=$1
	ts_bin=${_ts_bin:-}
	if [ -z "${ts_bin}" ]; then
		command -v tailscale >/dev/null 2>&1 && ts_bin=tailscale
		command -v Tailscale >/dev/null 2>&1 && ts_bin=Tailscale
	fi
	if [ -z "${ts_bin}" ]; then
		echo "Tailscale CLI not found" >&2
		return 1
	fi
	if ! command -v jq >/dev/null 2>&1; then
		echo "jq is required to resolve Tailscale SSH aliases" >&2
		return 1
	fi
	"${ts_bin}" status --json | jq -er --arg host "${host}" '
		.Peer[]
		| select((.HostName // "" | ascii_downcase) == ($host | ascii_downcase))
		| .TailscaleIPs[0] // empty
	'
}

ssh_tailscale() {
	if [ "$#" -ne 2 ]; then
		echo "'ssh_tailscale' expected USER HOST; got $#" >&2
		return 1
	fi
	user=$1
	host=$2
	ip=$(__tailscale_ip "${host}") || return
	ssh_auto "${user}@${ip}"
}

__ssh_auto_once() {
	if [ "$#" -lt 1 ]; then
		echo "'ssh-auto' expected [1..] arguments [OPTIONS] DESTINATION [COMMAND...]; got $#" >&2
		return 1
	fi
	root='' tty='' destination=''
	while [ "$#" -gt 0 ]; do
		case "$1" in
		-r | --root)
			root='--root'
			shift
			;;
		-t)
			tty='-t'
			shift
			;;
		*)
			destination="$1"
			shift
			break
			;;
		esac
	done
	if [ -z "${destination}" ]; then
		echo "'ssh-auto' expected DESTINATION after options" >&2
		return 1
	fi
	root_flag=${root}
	tty_flag=${tty}
	if __ssh_strict ${root_flag:+"${root_flag}"} ${tty_flag:+"${tty_flag}"} "${destination}" "$@"; then
		return
	else
		strict_status=$?
	fi

	host="${destination##*@}"
	case "${host}" in
	*.internal | *.qrt) ;;
	*) return 1 ;;
	esac
	if ssh-keygen -F "${host}" >/dev/null 2>&1; then
		return "${strict_status}"
	fi
	__ssh_accept_new ${root_flag:+"${root_flag}"} ${tty_flag:+"${tty_flag}"} "${destination}" "$@"
}

__ssh_auto_is_interactive() {
	root=0 tty=0
	while [ "$#" -gt 0 ]; do
		case "$1" in
		-r | --root)
			root=1
			shift
			;;
		-t)
			tty=1
			shift
			;;
		*) break ;;
		esac
	done
	[ "$#" -gt 0 ] || return 1
	shift
	[ "${root}" -eq 1 ] || [ "${tty}" -eq 1 ] || [ "$#" -eq 0 ]
}

__ssh_auto_can_retry() {
	status=$1
	error_file=$2
	[ "${status}" -eq 255 ] || return 1
	if grep -Eqi \
		'host key verification failed|remote host identification has changed|permission denied|too many authentication failures|no supported authentication methods available' \
		"${error_file}"; then
		return 1
	fi
	return 0
}

ssh_auto() (
	if ! __ssh_auto_is_interactive "$@"; then
		if __ssh_auto_once "$@"; then
			exit 0
		else
			status=$?
			exit "${status}"
		fi
	fi

	reconnect_tmp=$(mktemp -d "${TMPDIR:-/tmp}/ssh-auto.XXXXXX") || exit 1
	error_file="${reconnect_tmp}/stderr"
	error_pipe="${reconnect_tmp}/stderr.pipe"
	: >"${error_file}"
	if ! mkfifo "${error_pipe}"; then
		rm -rf -- "${reconnect_tmp}"
		exit 1
	fi
	tee_pid=0
	__ssh_auto_cleanup() {
		if [ "${tee_pid}" -ne 0 ]; then
			kill "${tee_pid}" 2>/dev/null || :
			wait "${tee_pid}" 2>/dev/null || :
		fi
		rm -rf -- "${reconnect_tmp}"
	}
	trap '__ssh_auto_cleanup; exit 130' HUP INT TERM
	while :; do
		: >"${error_file}"
		tee "${error_file}" <"${error_pipe}" >&2 &
		tee_pid=$!
		if __ssh_auto_once "$@" 2>"${error_pipe}"; then
			status=0
		else
			status=$?
		fi
		wait "${tee_pid}" || :
		tee_pid=0
		if ! __ssh_auto_can_retry "${status}" "${error_file}"; then
			__ssh_auto_cleanup
			exit "${status}"
		fi
		printf 'SSH connection ended; reconnecting in one second. Press Ctrl-C to stop.\n' >&2
		sleep 1
	done
)

#### shortcuts #################################################################

ssh_dw_macbookneo() { ssh_tailscale derekwan DW-MacBookNeo; }
ssh_dw_macmini() { ssh_tailscale derekwan DW-MacMini; }
ssh_dw_swift() { ssh_tailscale derek DW-Swift; }
