#!/usr/bin/env sh

set -eu

###############################################################################

if command -v pgcli >/dev/null 2>&1; then
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] 'pgcli' is already installed"
	exit
fi

case "$1" in
debian)
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing 'pgcli'..."
	script_dir=$(dirname -- "$(realpath -- "$0")")
	configs="$(dirname -- "${script_dir}")"
	sh "${configs}/uv/install.sh" debian
	uv tool install pgcli
	;;
macmini)
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing 'pgcli'..."
	brew install pgcli
	;;
*) ;;
esac
