#!/usr/bin/env bash

if ! apt-get-has pdfarranger; then
	timed_log "pdfarranger not installed; installing...\n"
	sudo add-apt-repository --yes ppa:linuxuprising/apps
	sudo apt-get --yes install pdfarranger
	timed_log "pdfarranger installed\n"
fi
