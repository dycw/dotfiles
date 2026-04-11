#!/usr/bin/env sh

set -eu

###############################################################################

if command -v flock >/dev/null 2>&1; then
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] 'flock' is already installed"
	exit
fi

case "$1" in
macmini)
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing 'flock'..."
	brew install flock
	;;
*) ;;
esac
