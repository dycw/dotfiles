#!/usr/bin/env sh

set -eu

###############################################################################

if command -v nvim >/dev/null 2>&1; then
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] 'neovim' is already installed"
	exit
fi

case "$1" in
debian)
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing 'neovim'..."
	if [ "$(id -u)" -eq 0 ]; then
		uvx --from dycw-installer[cli]@latest set-up-neovim
	else
		uvx --from dycw-installer[cli]@latest set-up-neovim --sudo
	fi
	;;
macmini | macbook)
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing 'neovim'..."
	uvx --from dycw-installer[cli]@latest set-up-neovim
	;;
*) ;;
esac
