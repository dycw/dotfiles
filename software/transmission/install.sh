#!/usr/bin/env bash

if ! command -v transmission-gtk >/dev/null 2>&1; then
	sudo apt-get update
	sudo apt-get --yes transmission
fi
