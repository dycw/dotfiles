#!/usr/bin/env bash

if ! command -v tex >/dev/null 2>&1; then
	sudo apt-get update
	sudo apt-get --yes install texlive-xetex
fi
