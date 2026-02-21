#!/usr/bin/env sh

set -eu

###############################################################################

if command -v rename >/dev/null 2>&1; then
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] 'rename' is already installed"
	exit
fi

case "$1" in
debian)
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing 'rename'..."
	if [ "$(id -u)" -eq 0 ]; then
		apt-get install -y rename
	else
		sudo apt-get install -y rename
	fi
	;;
macmini)
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing 'rename'..."
	brew install rename
	;;
*) ;;
esac
