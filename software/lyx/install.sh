#!/usr/bin/env bash

if ! command -v lyx >/dev/null 2>&1; then
	sudo add-apt-repository --yes ppa:lyx-devel/release
	sudo apt-get update
	sudo apt-get --yes install lyx
fi
