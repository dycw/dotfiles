#!/usr/bin/env sh
# shellcheck disable=SC1090,SC1091

set -eu

#### parse arguments ##########################################################

repo='https://github.com/dycw/dotfiles.git'
dotfiles='dotfiles'
local_user=''
target=''
port=''

show_usage_and_exit() {
	cat <<'EOF' >&2

Usage:
  entrypoint.sh
  entrypoint.sh --user username
  entrypoint.sh --ssh user@host [--port 222]

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
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Setting up '$(hostname)'..."

	if ! command -v git >/dev/null 2>&1; then
		echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing 'git'..."
		if [ "$(uname)" = Linux ] && [ -r /etc/os-release ]; then
			. /etc/os-release
			if [ "${ID:-}" = debian ]; then
				if [ "$(id -u)" -eq 0 ]; then
					apt install -y git
				else
					sudo apt install -y git
				fi
			fi
		else
			echo "Unsupported OS '$(uname)'; exiting..." >&2
			exit 1
		fi
	fi

	if ! [ -d "${HOME}/${dotfiles}" ]; then
		echo "[$(date '+%Y-%m-%d %H:%M:%S')] Cloning repo..."
		git clone --recurse-submodules "${repo}" "${HOME}/${dotfiles}"
	fi

	sh "${HOME}/${dotfiles}/scripts/_internal/install.sh"
	sh "${HOME}/${dotfiles}/scripts/_internal/set-up.sh"
}

#### run local other ##########################################################

run_local_other() {
	user="$1"
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Setting up '${user}' on '$(hostname)'..."

	self=$(realpath -- "$0")
	tmp=$(mktemp "${TMPDIR:-/tmp}/set-up.XXXXXX")
	trap 'rm -f -- "${tmp}"' EXIT HUP INT TERM
	cp -- "${self}" "${tmp}"
	chmod 0755 "${tmp}"
	su - "${user}" -c "sh '${tmp}'"
}

#### run remote ###############################################################

run_remote() {
	target=$1
	port=${2:-22}
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Setting up '${target}'..."

	self=$(realpath -- "$0")
	tmp=$(
		ssh -p "$port" "$target" /bin/sh -s <<'EOF'
set -eu
mktemp "${TMPDIR:-/tmp}/set-up.XXXXXX"
EOF
	)
	tmp=$(printf '%s' "${tmp}") # trailing slash
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Temporary file '${tmp}' on '${target}'"
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
