#!/usr/bin/env sh

set -eu

###############################################################################

if command -v bump-my-version >/dev/null 2>&1; then
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] 'bump-my-version' is already installed"
	exit
fi

case "$1" in
debian | macbook)
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing 'bump-my-version'..."
	script_dir=$(dirname -- "$(realpath -- "$0")")
	configs="$(dirname -- "${script_dir}")"
	sh "${configs}/uv/install.sh" debian
	uv tool install bump-my-version
	;;
macmini)
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing 'bump-my-version'..."
	brew install bump-my-version
	;;
*) ;;
esac
