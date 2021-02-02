#!/usr/bin/env bash

if ! dpkg -s lyx >/dev/null 2>&1; then
	printf "lyx not installed; installing...\n"
	sudo add-apt-repository --yes ppa:lyx-devel/release
	sudo apt-get update
	sudo apt-get --yes install lyx
	printf "lyx installed\n"
fi
