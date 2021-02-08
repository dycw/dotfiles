#!/usr/bin/env bash

if ! command -v cargo >/dev/null 2>&1; then
	sudo apt-get update
	sudo apt-get --yes install build-essential
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi
