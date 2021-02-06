#!/usr/bin/env bash

name=transmission
if ! command -v "$name-gtk" >/dev/null 2>&1; then
	sudo apt-get update
	sudo apt-get --yes "$name"
fi
