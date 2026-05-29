# shellcheck shell=bash
__ssh_keyscan() {
	if [ "$#" -lt 1 ]; then
		echo "'__ssh_keyscan' expected [1..] arguments HOST [PORT]; got $#" >&2
		return 1
	fi
	local host="$1"
	shift
	local port='' args="-t ed25519"
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
	local tmp
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
	local root=0 destination=''
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

add-known-host() {
	if [ "$#" -eq 0 ]; then
		echo "'add-known-host' expected [1..2] arguments HOST [PORT]; got $#" >&2
		return 1
	fi
	local host="$1"
	if [ "$#" -ge 2 ]; then
		ssh-keygen -R "[${host}]:$2"
		__ssh_keyscan "${host}" -p "$2"
	else
		ssh-keygen -R "${host}"
		__ssh_keyscan "${host}"
	fi
}

edit-authorized-keys() { "${EDITOR}" "${HOME}/.ssh/authorized_keys"; }
edit-known-hosts() { "${EDITOR}" "${HOME}/.ssh/known_hosts"; }
edit-ssh-config() { "${EDITOR}" "${HOME}/.ssh/config"; }

generate-ssh-key() {
	local filename="id_ed25519"
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

ssh-auto() {
	if [ "$#" -lt 1 ]; then
		echo "'ssh-auto' expected [1..] arguments DESTINATION; got $#" >&2
		return 1
	fi
	local root='' destination=''
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
		local host="${destination##*@}"
		ssh-keygen -R "${host}"
		__ssh_keyscan "${host}"
		__ssh_strict ${root:+"${root}"} "${destination}"
	fi
}

ssh-dw-macmini() { ssh-auto derekwan@dw-macmini.tail.net; }
ssh-dw-macbookneo() { ssh-auto derekwan@dw-macbookneo.tail.net; }
ssh-dw-swift() { ssh-auto derek@dw-swift.tail.net; }
ssh-gitea() { ssh-auto nonroot@gitea-server.ai; }
ssh-rh-macmini() { ssh-auto derekwan@rh-macmini.tail.net; }
ssh-rh-macbook() { ssh-auto derekwan@rh-macbook.tail.net; }
