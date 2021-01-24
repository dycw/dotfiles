#!/usr/bin/env bash

if ! dpkg -s pdfarranger >/dev/null 2>&1; then
	timed_log "pdfarranger not installed; installing...\n"
	sudo add-apt-repository --yes ppa:linuxuprising/apps
	sudo apt-get --yes install pdfarranger
	timed_log "pdfarranger installed\n"
fi
