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
	root=0 destination=''
	while [ "$#" -gt 0 ]; do
		case "$1" in
		-r | --root)
			root=1
			shift
			;;
		*)
			destination="$1"
			shift
			;;
		esac
	done
	if [ "${root}" -eq 1 ]; then
		ssh -o HostKeyAlgorithms=ssh-ed25519 -o StrictHostKeyChecking=yes \
			-t "${destination}" 'sudo -i'
	else
		ssh -o HostKeyAlgorithms=ssh-ed25519 -o StrictHostKeyChecking=yes \
			"${destination}"
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

ssh_auto() {
	if [ "$#" -lt 1 ]; then
		echo "'ssh-auto' expected [1..] arguments DESTINATION; got $#" >&2
		return 1
	fi
	root='' destination=''
	while [ "$#" -gt 0 ]; do
		case "$1" in
		-r | --root)
			root='--root'
			shift
			;;
		*)
			destination="$1"
			shift
			;;
		esac
	done
	if ! __ssh_strict ${root:+"${root}"} "${destination}"; then
		host="${destination##*@}"
		ssh-keygen -R "${host}"
		__ssh_keyscan "${host}"
		__ssh_strict ${root:+"${root}"} "${destination}"
	fi
}

#### shortcuts #################################################################

ssh_agent_cluster() { ssh_auto nonroot@agent-cluster.qrt; }
ssh_dw_macbookneo() { ssh_auto derekwan@dw-macbookneo.tail.net; }
ssh_dw_macmini() { ssh_auto derekwan@dw-macmini.tail.net; }
ssh_dw_swift() { ssh_auto derek@dw-swift.tail.net; }
ssh_gitea() { ssh_auto nonroot@gitea-server.ai; }
ssh_jupyter() { ssh_auto nonroot@jupyter.internal; }
ssh_rh_macbook() { ssh_auto derekwan@rh-macbook.tail.net; }
ssh_rh_macmini() { ssh_auto derekwan@rh-macmini.tail.net; }
