#!/usr/bin/env bash

if ! command -v brew >/dev/null 2>&1; then
	sudo apt-get update
	sudo apt-get --yes install autoconf autoconf-archive automake bison build-essential cmake curl flex gettext git make ruby scons libbz2-dev libcurl4-openssl-dev libexpat-dev libncurses-dev libtool
	git clone https://github.com/Homebrew/linuxbrew.git ~/.linuxbrew
fi
