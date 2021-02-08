#!/usr/bin/env bash

if ! command -v tmux >/dev/null 2>&1; then
	sudo apt-get update
	sudo apt-get --yes install tmux
fi
