#!/usr/bin/env sh

set -eu

###############################################################################

if command -v npm >/dev/null 2>&1; then
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] 'npm' is already installed"
	exit
fi

case "$1" in
debian)
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing 'npm'..."
	if [ "$(id -u)" -eq 0 ]; then
		apt-get install -y npm
	else
		sudo apt-get install -y npm
	fi
	;;
macmini)
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing 'npm'..."
	brew install npm
	;;
macbook)
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing 'npm'..."
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
	;;
*) ;;
esac
