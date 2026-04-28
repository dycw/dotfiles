#!/usr/bin/env sh
# shellcheck disable=SC1090,SC1091

set -eu

case "$0" in
/*) self_path=$0 ;;
*) self_path=$(pwd -P)/$0 ;;
esac
self_dir=$(CDPATH='' cd -- "$(dirname -- "$self_path")" && pwd -P)

#### parse arguments ##########################################################

dotfiles_default="${HOME}/dotfiles"
dotfiles=''
repo=''
local_user=''
target=''
port=''

# QRT CA certificate — required to reach gitea.ai on machines that have not
# yet had it installed through another channel.
qrt_ca_cert='-----BEGIN CERTIFICATE-----
MIIFMjCCAxqgAwIBAgIUKlvB97/9+APifZ3R9xcG7gLH2/wwDQYJKoZIhvcNAQEL
BQAwHzEdMBsGA1UEAwwUSW50ZXJuYWwgUGlsb3QgQ0EgdjIwHhcNMjYwMzE4MTYy
OTM2WhcNMzYwMzE1MTYyOTM2WjAfMR0wGwYDVQQDDBRJbnRlcm5hbCBQaWxvdCBD
QSB2MjCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAIxKuxl9OLSW6d21
J3UdRswgLOYd9Snvo7/trqgwyTEUxlxBpl9gAIu5UXYCEbFmjIgsOY5m27NPXDiW
IE5ay1JsSiZ8sBfD7f9ILG1YTGHk6hIBOZfieslWUH5QTK5tDeNqdNH76jDLrPuS
/j4jXx0D+/IJeky1qznTeHB+ecbtA/tvO6CiSm2Idda2MTb90/2AfcxqcLHdCmDd
qtOLoWn6aPW1BN79AjfXa+nLJN+d94e1y979zSjksy+9ky2iH9LhzrZzfgOyqilW
NW7EmkXdHds1byXxEn00rasDPuQXfyn9GOuqTt8HMf5eau6vV/fqnbb9m7SDjgkG
7Uld2fngaulNwRPAGDM4xe79k3EbGD5/CdFZHrPvIreKWZyDUdlklzpbEZi4K15r
1UsVAuNHR4OqANBJ1q3UZmuo0E9rRGCk68AlX9R2F7rBa5kLXmyQ05jYOEHPXznO
LFDUKpFC86acx6zbGyYRPstouZhJ1pBG2Xj/lCUIy8KTFsLhjVMK1egCzBzfR+8A
j41s/N8QMmSFt7WPYjzj/2T41VUlzlHdY1C/oL24pV6SR3lKqZZBconkx/MJYz4E
e6txn3XrKasVG69iBFq0H9Ek248wASQRUbZciuWRveiOCjKcIu/c1UCjtPzTzndA
yxoi6mFWaAQ3zGb5c8QLWBDVYtlxAgMBAAGjZjBkMB0GA1UdDgQWBBT4K3VSavzZ
In44WmweM+wC4e8uUDAfBgNVHSMEGDAWgBT4K3VSavzZIn44WmweM+wC4e8uUDAS
BgNVHRMBAf8ECDAGAQH/AgEAMA4GA1UdDwEB/wQEAwIBBjANBgkqhkiG9w0BAQsF
AAOCAgEAJxuVT0B9Usn32RSOx6ZIt6gxTblzjmELsz3kmRSz1flWOXe8/ViZwX6y
LisDldm7X/KyhTpGlrS0lNLwpofzq8t9ZacMpbgsA7EDLXCLH49NEn6ueDDKR9oS
ArtXjgoxUNFCEdKXrjYuy1TlbOQjRZ85nxnXaLQNTZ9tQm52+HF8GZELQJNJpcwU
bm4Wj/G9uPYleX8ysDhUjZXqOSICK4a5PgKJbPWKbH80unTtqMFS/hmci7lnQEDs
YCmTwT5CO8tpfkMnuE5v+USByX1umGLo0zhed47lcE2rsUUA6RW5V145ZD2JNhw+
7qkxH9/z3eortsMp4/yXcPuaQ05kCDyB8Q4Mn24ZkFeY9jxzR5YCxocWZv1gDmhw
vN967AIwNf3aSQGcIopf0+ZJEJa2+uKss2ztBcyYAP/X41/ove4/k01yfkGjC1yC
l0sGnayL40VdAJ48fXenDnHtNBCmJgasu38jQ6+AWfUQmuNiWOTwjFjEcv4/UVGy
+ipt+0a72yYaIZIXIpQX4jQASF7GYudk9vPhHfGGMI98EEf5XiSmm3ZQJqwkQ9Cu
gDdLZMns+Ui+KogGMTO/tAMdyZnesUbdWblVdVtiMKpQXl1C5URviUor/uVXZLoj
9FekOtbtBPn78XN+oHPzHcZi5WA3Z+jA3PTG9qFszunDBiA7pwg=
-----END CERTIFICATE-----'

log() {
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

fail() {
	log "$*" >&2
	exit 1
}

ensure_sudo() {
	if [ "$(id -u)" -eq 0 ]; then
		return
	fi
	if ! sudo -n true 2>/dev/null; then
		log "Requesting sudo access..."
		sudo -v
	fi
	# Refresh credentials every 60 s for the lifetime of the script.
	while true; do
		sudo -n true 2>/dev/null || true
		sleep 60
		kill -0 "$$" 2>/dev/null || exit 0
	done &
}

resolve_dotfiles() {
	if [ -f "$0" ]; then
		if [ -d "${self_dir}/.git" ] && [ -f "${self_dir}/scripts/_setup/install.sh" ]; then
			dotfiles=${self_dir}
			return
		fi
	fi
	dotfiles=${dotfiles_default}
}

ensure_git() {
	if git --version >/dev/null 2>&1; then
		return
	fi

	log "Installing 'git'..."
	case "$(uname)" in
	Linux)
		if [ ! -r /etc/os-release ]; then
			fail "'/etc/os-release' is not readable; exiting..."
		fi
		. /etc/os-release
		if [ "${ID:-}" != debian ]; then
			fail "Unsupported Linux distribution '${ID:-unknown}'; exiting..."
		fi
		if [ "$(id -u)" -eq 0 ]; then
			apt-get update
			apt-get install -y git
		else
			sudo apt-get update
			sudo apt-get install -y git
		fi
		;;
	Darwin)
		if ! command -v brew >/dev/null 2>&1; then
			log "Installing 'brew'..."
			NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		fi
		if [ -x /opt/homebrew/bin/brew ]; then
			export PATH="/opt/homebrew/bin${PATH:+:${PATH}}"
		elif [ -x /usr/local/bin/brew ]; then
			export PATH="/usr/local/bin${PATH:+:${PATH}}"
		fi
		brew install git
		;;
	*)
		fail "Unsupported OS '$(uname)'; exiting..."
		;;
	esac
}

determine_repo() {
	if [ -n "${DOTFILES_REPO:-}" ]; then
		repo="${DOTFILES_REPO}"
		return
	fi

	# If Gitea is already reachable, prefer it.
	if curl -fsSL --max-time 5 "https://gitea.ai/" >/dev/null 2>&1; then
		repo='https://gitea.ai/derek/dotfiles.git'
		return
	fi

	# Install the QRT CA certificate so that gitea.ai becomes reachable.
	log "Installing QRT CA certificate..."
	tmp_cert=$(mktemp "${TMPDIR:-/tmp}/qrt-ca.XXXXXX.crt")
	printf '%s\n' "${qrt_ca_cert}" >"${tmp_cert}"
	case "$(uname)" in
	Darwin)
		sudo security add-trusted-cert -d -r trustRoot \
			-k /Library/Keychains/System.keychain "${tmp_cert}"
		;;
	Linux)
		if [ "$(id -u)" -eq 0 ]; then
			cp "${tmp_cert}" /usr/local/share/ca-certificates/qrt-ca.crt
			update-ca-certificates
		else
			sudo cp "${tmp_cert}" /usr/local/share/ca-certificates/qrt-ca.crt
			sudo update-ca-certificates
		fi
		;;
	esac
	rm -f -- "${tmp_cert}"

	# Re-test after cert installation.
	if curl -fsSL --max-time 5 "https://gitea.ai/" >/dev/null 2>&1; then
		repo='https://gitea.ai/derek/dotfiles.git'
	else
		repo='https://github.com/dycw/dotfiles.git'
	fi
}

show_usage_and_exit() {
	cat <<'EOF' >&2

Usage:
  setup.sh
  setup.sh --user username
  setup.sh --ssh user@host [--port 222]

Notes:
  - No args: setup current user locally.
  - --user: runs the setup as another local user.
  - --ssh: runs the setup remotely over SSH.
EOF
	exit 1
}

while [ $# -gt 0 ]; do
	case "$1" in
	--user=*)
		local_user=${1#--user=}
		if [ -z "${local_user}" ]; then
			echo "[$(date '+%Y-%m-%d %H:%M:%S')] Empty '--user'; exiting..." >&2
			show_usage_and_exit
		fi
		shift
		;;
	--user)
		if [ $# -le 1 ]; then
			echo "[$(date '+%Y-%m-%d %H:%M:%S')] '--user' requires an argument; exiting..." >&2
			show_usage_and_exit
		fi
		local_user=$2
		shift 2
		;;
	--ssh=*)
		target=${1#--ssh=}
		if [ -z "${target}" ]; then
			echo "[$(date '+%Y-%m-%d %H:%M:%S')] Empty '--ssh'; exiting..." >&2
			show_usage_and_exit
		fi
		shift
		;;
	--ssh)
		if [ $# -le 1 ]; then
			echo "[$(date '+%Y-%m-%d %H:%M:%S')] '--ssh' requires an argument; exiting..." >&2
			show_usage_and_exit
		fi
		target=$2
		shift 2
		;;
	--port=*)
		port=${1#--port=}
		if [ -z "${port}" ]; then
			echo "[$(date '+%Y-%m-%d %H:%M:%S')] Empty '--port'; exiting..." >&2
			show_usage_and_exit
		fi
		shift
		;;
	--port)
		if [ $# -le 1 ]; then
			echo "[$(date '+%Y-%m-%d %H:%M:%S')] '--port' requires an argument; exiting..." >&2
			show_usage_and_exit
		fi
		port=$2
		shift 2
		;;
	-h | --help)
		show_usage_and_exit
		;;
	*)
		echo "[$(date '+%Y-%m-%d %H:%M:%S')] Unsupported argument '$1'; exiting..." >&2
		show_usage_and_exit
		;;
	esac
done

if [ -n "${local_user}" ] && [ -n "${target}" ]; then
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Mutually exclusive arguments '--user' and '--ssh' were given; exiting..." >&2
	show_usage_and_exit
fi

#### run local self ###########################################################

run_local_self() {
	log "Setting up '$(hostname)'..."

	ensure_sudo
	resolve_dotfiles
	ensure_git
	determine_repo

	if [ -d "${dotfiles}" ]; then
		log "Updating repo..."
		git -C "${dotfiles}" fetch origin
		git -C "${dotfiles}" reset --hard origin/master
		git -C "${dotfiles}" submodule update --init --recursive
	else
		log "Cloning repo..."
		git clone --recurse-submodules "${repo}" "${dotfiles}"
	fi

	sh "${dotfiles}/scripts/_setup/install.sh"
	sh "${dotfiles}/scripts/_setup/setup.sh"
}

#### run local other ##########################################################

run_local_other() {
	user="$1"
	log "Setting up '${user}' on '$(hostname)'..."

	tmp=$(mktemp "${TMPDIR:-/tmp}/setup.XXXXXX")
	trap 'rm -f -- "${tmp}"' EXIT HUP INT TERM
	cp -- "${self_path}" "${tmp}"
	chmod 0755 "${tmp}"
	su - "${user}" -c "sh '${tmp}'"
}

#### run remote ###############################################################

run_remote() {
	target=$1
	port=${2:-22}
	log "Setting up '${target}'..."

	tmp=$(
		ssh -p "${port}" "${target}" /bin/sh -s <<'EOF'
set -eu
mktemp "${TMPDIR:-/tmp}/setup.XXXXXX"
EOF
	)
	tmp=$(printf '%s' "${tmp}") # trailing slash
	ssh -p "${port}" "${target}" "cat > '${tmp}'" <"${self_path}"
	ssh -p "${port}" "${target}" /bin/sh -s "${tmp}" <<'EOF'
set -eu
chmod 0755 "$1"
sh "$1"
rm -f -- "$1"
EOF
}

#### main #####################################################################

if [ -n "${local_user}" ]; then
	run_local_other "${local_user}"
elif [ -n "${target}" ]; then
	run_remote "${target}" "${port}"
else
	run_local_self
fi
