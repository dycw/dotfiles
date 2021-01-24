#!/usr/bin/env bash

if ! dpkg -s nodejs >/dev/null 2>&1; then
	timed_log "nodejs not installed; installing...\n"
	curl -sL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
	sudo apt-get --yes install nodejs
	timed_log "nodejs installed\n"
fi
