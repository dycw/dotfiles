#!/usr/bin/env bash

if ! command -v node >/dev/null 2>&1; then
	curl -sL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
	sudo apt-get update
	sudo apt-get --yes install nodejs
fi
