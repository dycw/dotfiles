#!/usr/bin/env sh

set -eu

###############################################################################

if command -v gyes >/dev/null 2>&1; then
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] 'coreutils' is already installed"
	exit
fi

case "$1" in
macmini)
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing 'coreutils'..."
	brew install coreutils
	;;
*) ;;
esac
