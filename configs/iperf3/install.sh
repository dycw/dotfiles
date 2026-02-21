#!/usr/bin/env sh

set -eu

###############################################################################

if command -v iperf3 >/dev/null 2>&1; then
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] 'iperf3' is already installed"
	exit
fi

case "$1" in
debian)
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing 'iperf3'..."
	if [ "$(id -u)" -eq 0 ]; then
		DEBIAN_FRONTEND=noninteractive apt install -y iperf3
	else
		DEBIAN_FRONTEND=noninteractive sudo apt install -y iperf3
	fi
	;;
macmini)
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing 'iperf3'..."
	brew install iperf3
	;;
*) ;;
esac
