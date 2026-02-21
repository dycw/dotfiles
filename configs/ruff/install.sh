#!/usr/bin/env sh

set -eu

###############################################################################

if command -v ruff >/dev/null 2>&1; then
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] 'ruff' is already installed"
	exit
fi

case "$1" in
debian | macbook)
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing 'ruff'..."
	script_dir=$(dirname -- "$(realpath -- "$0")")
	configs="$(dirname -- "${script_dir}")"
	sh "${configs}/uv/install.sh" debian
	uv tool install ruff
	;;
macmini)
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing 'ruff'..."
	brew install ruff
	;;
*) ;;
esac
