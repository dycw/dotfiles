#!/usr/bin/env sh
# shellcheck disable=SC1090

set -eu

###############################################################################

repo='https://github.com/dycw/dotfiles.git'
dotfiles='dotfiles'  # under target user's $HOME
local_user=''        # username to run as (via su)
ssh_user_hostname='' # user@host
ssh_port=''          # empty => default

usage() {
	cat <<'EOF' >&2
Usage:
  entrypoint.sh
  entrypoint.sh --ssh user@host [--port 2222]
  entrypoint.sh --user username

Notes:
  - No args: setup current user locally.
  - --ssh: runs the setup remotely over SSH.
  - --user: runs the setup as another local user (typically run as root).
EOF
	exit 2
}

die() {
	printf '%s\n' "$*" >&2
	exit 1
}

#### parse arguments ##########################################################

while [ $# -gt 0 ]; do
	case "$1" in
	--user=*)
		local_user=${1#--user=}
		[ -n "$local_user" ] || die "Empty --user"
		shift
		;;
	--user)
		[ $# -ge 2 ] || usage
		local_user=$2
		shift 2
		;;
	--ssh=*)
		ssh_user_hostname=${1#--ssh=}
		[ -n "$ssh_user_hostname" ] || die "Empty --ssh target"
		shift
		;;
	--ssh)
		[ $# -ge 2 ] || usage
		ssh_user_hostname=$2
		shift 2
		;;
	--port=*)
		ssh_port=${1#--port=}
		[ -n "$ssh_port" ] || die "Empty --port"
		shift
		;;
	--port)
		[ $# -ge 2 ] || usage
		ssh_port=$2
		shift 2
		;;
	-h | --help)
		usage
		;;
	*)
		die "Unknown argument: $1"
		;;
	esac
done

# mutually exclusive: --ssh vs --user
if [ -n "$ssh_user_hostname" ] && [ -n "$local_user" ]; then
	die "Use either --ssh or --user, not both"
fi

# --- helpers -----------------------------------------------------------------
timestamp() { date '+%Y-%m-%d %H:%M:%S'; }

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

run_local_current_user() {
	echo "[$(timestamp)] Mode: local (current user)"
	# run in a clean sh instance to avoid relying on caller env
	sh -c "$setup_body_sh"
}

run_local_other_user() {
	u=$1
	echo "[$(timestamp)] Mode: local (as user '$u')"

	if ! command -v su >/dev/null 2>&1; then
		die "su not found; cannot switch to user '$u'"
	fi

	# Prefer login shell (-) so HOME is correct.
	# Use `sh -c` in the target account so the script runs with that user's env.
	su - "$u" -c "sh -c $(printf %s "$setup_body_sh" | sed "s/'/'\\\\''/g; s/^/'/; s/\$/'/")"
}

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
	run_local_other_user "$local_user"
else
	run_local_current_user
fi
