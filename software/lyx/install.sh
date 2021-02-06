#!/usr/bin/env bash

name=lyx
if ! command -v "$name" >/dev/null 2>&1; then
	sudo add-apt-repository --yes ppa:lyx-devel/release
	sudo apt-get update
	sudo apt-get --yes install "$name"
fi
