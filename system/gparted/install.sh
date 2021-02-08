#!/usr/bin/env bash

if ! command -v gparted >/dev/null 2>&1; then
	sudo apt-get update
	sudo apt-get --yes install gparted
fi
