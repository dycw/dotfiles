#!/usr/bin/env bash

name=gparted
if ! command -v "$name" >/dev/null 2>&1; then
	sudo apt-get update
	sudo apt-get --yes install "$name"
fi
