#!/usr/bin/env bash

if ! command -v pdfarranger >/dev/null 2>&1; then
	sudo add-apt-repository --yes ppa:linuxuprising/apps
	sudo apt-get update
	sudo apt-get --yes install pdfarranger
fi
