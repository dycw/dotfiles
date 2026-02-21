#!/usr/bin/env sh

set -eu

###############################################################################

if command -v bacon >/dev/null 2>&1; then
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] 'bacon' is already installed"
	exit
fi

case "$1" in
debian)
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing 'bacon'..."
	if [ "$(id -u)" -eq 0 ]; then
		apt-get install -y bacon
	else
		sudo apt-get install -y bacon
	fi
	;;
macmini)
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing 'bacon'..."
	brew install bacon
	;;
*) ;;
esac
