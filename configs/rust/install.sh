#!/usr/bin/env sh

set -eu

###############################################################################

if command -v cargo >/dev/null 2>&1; then
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] 'rust' is already installed"
	exit
fi

case "$1" in
debian)
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing 'rust'..."
	curl -LsSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
	;;
macmini | macbook)
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing 'rust'..."
	brew install rust
	;;
esac
