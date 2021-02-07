#!/usr/bin/env bash

if ! command -v alacritty >/dev/null 2>&1; then
	sudo add-apt-repository ppa:aslatter/ppa
	sudo apt-get update
	sudo apt-get --yes install alacritty
fi
