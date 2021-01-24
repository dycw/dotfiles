#!/usr/bin/env bash

if ! dpkg -s lyx >/dev/null 2>&1; then
	timed_log "lyx not installed; installing...\n"
	sudo add-apt-repository --yes ppa:lyx-devel/release
	sudo apt-get update
	sudo apt-get --yes install lyx
	timed_log "lyx installed\n"
fi
