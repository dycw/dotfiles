#!/usr/bin/env sh
# shellcheck disable=SC1090,SC1091

set -eu

#### parse arguments ##########################################################

repo='https://github.com/dycw/dotfiles.git'
dotfiles='dotfiles'
local_user=''
ssh_user_hostname=''
ssh_port=''

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
		ssh_user_hostname=${1#--ssh=}
		if [ -z "${ssh_user_hostname}" ]; then
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
		ssh_user_hostname=$2
		shift 2
		;;
	--port=*)
		ssh_port=${1#--port=}
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
		ssh_port=$2
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

if [ -n "${local_user}" ] && [ -n "${ssh_user_hostname}" ]; then
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Mutually exclusive arguments '--user' and '--ssh' were given; exiting..." >&2
	show_usage_and_exit
fi

#### main #####################################################################

if [ -n "${local_user}" ]; then
	run_local_other "${local_user}"
elif [ -n "${ssh_user_hostname}" ]; then
	run_remote "${ssh_user_hostname}" "${ssh_port}"
else
	run_local_self
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

#### run local self ###########################################################

run_local_other() {
	user="$1"
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Setting up '${user}' on '$(hostname)'..."

	script_self=$(realpath -- "$0")
	tmp_self=$(mktemp -t set-up.XXXXXX)
	trap 'rm -f -- "${tmp_self}"' EXIT HUP INT TERM
	cp -- "${script_self}" "${tmp_self}"
	chmod 0755 "${tmp_self}"
	su - "${user}" -c "sh -- '${tmp_self}'"
}

# Runs on the target machine *as the target user*.
# Assumes: HOME is set correctly for that user.
setup_body_sh='
set -eu
REPO_URL='"$(printf %s "$repo" | sed "s/'/'\\\\''/g")"'
DEST="$HOME/'"$dotfiles"'"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Bootstrapping on $(hostname) as $(id -un)..."
if command -v git >/dev/null 2>&1; then :; else
  echo "[ERROR] git not found on PATH" >&2
  exit 1
fi

if [ -d "$DEST/.git" ]; then
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] Updating repo at $DEST..."
  git -C "$DEST" fetch --all --prune
  git -C "$DEST" pull --ff-only
else
  if [ -e "$DEST" ] && [ ! -d "$DEST" ]; then
    echo "[ERROR] $DEST exists but is not a directory" >&2
    exit 1
  fi
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] Cloning $REPO_URL to $DEST..."
  mkdir -p "$(dirname "$DEST")"
  git clone --recurse-submodules "$REPO_URL" "$DEST"
fi

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Running set-up.sh..."
sh "$DEST/set-up.sh"
'

run_remote() {
	target=$1
	port=$2

	echo "[$(timestamp)] Mode: remote (ssh to '$target')"
	if ! command -v ssh >/dev/null 2>&1; then
		die "ssh not found"
	fi

	ssh_args=''
	if [ -n "$port" ]; then
		ssh_args="-p $port"
	fi

	# Send a script over stdin; remote runs /bin/sh -s
	# Note: assumes remote has git and can reach GitHub.
	# If you need to become root or another user remotely, do it via SSH config / user@host.
	# shellcheck disable=SC2086
	ssh $ssh_args "$target" /bin/sh -s <<EOF
$setup_body_sh
EOF
}

# --- dispatch ----------------------------------------------------------------
if [ -n "$ssh_user_hostname" ]; then
	run_remote "$ssh_user_hostname" "$ssh_port"
elif [ -n "$local_user" ]; then
	run_local_other "$local_user"
else
	run_local_current_user
fi
