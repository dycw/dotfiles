#!/usr/bin/env sh

set -eu

###############################################################################

if command -v sudo >/dev/null 2>&1; then
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] 'sudo' is already installed"
	exit
fi

case "$1" in
debian)
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing 'sudo'..."
	if [ "$(id -u)" -eq 0 ]; then
		apt-get install -y sudo
	else
		sudo apt-get install -y sudo
		su - <<EOF
apt-get update
apt-get install -y sudo
usermod -aG sudo $(id -un)
EOF
	fi
	;;
*) ;;
esac
