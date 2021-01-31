#!/usr/bin/env bash

if ! dpkg -s atom >/dev/null 2>&1; then
	timed_log "atom not installed; installing...\n"
	wget -qO - https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add -
	sudo sh -c 'echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list'
	sudo apt-get update
	sudo apt-get --yes install atom
	timed_log "atom installed\n"
fi
