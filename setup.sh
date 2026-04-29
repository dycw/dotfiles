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
repo="${DOTFILES_REPO:-https://github.com/dycw/dotfiles.git}"
local_user=''
target=''
port=''

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
		if [ -d "${self_dir}/.git" ] && [ -f "${self_dir}/scripts/_setup/run.sh" ]; then
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

	resolve_dotfiles
	ensure_git

	if [ -d "${dotfiles}" ]; then
		log "Updating repo..."
		git -C "${dotfiles}" fetch origin
		git -C "${dotfiles}" reset --hard origin/master
		git -C "${dotfiles}" submodule update --init --recursive
	else
		log "Cloning repo..."
		git clone --recurse-submodules "${repo}" "${dotfiles}"
	fi

	sh "${dotfiles}/scripts/_setup/run.sh"
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
