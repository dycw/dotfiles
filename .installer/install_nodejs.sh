#!/usr/bin/env bash

if ! dpkg -s nodejs >/dev/null 2>&1; then
	printf "nodejs not installed; installing...\n"
	curl -sL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
	sudo apt-get --yes install nodejs
	printf "nodejs installed\n"
fi
