#!/usr/bin/env sh

set -eu

###############################################################################

if command -v maturin >/dev/null 2>&1; then
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] 'maturin' is already installed"
	exit
fi

case "$1" in
macmini)
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing 'maturin'..."
	brew install maturin
	;;
*) ;;
esac
