#!/usr/bin/env bash

if ! command -v spt >/dev/null 2>&1; then
	sudo apt-get --yes install libssl-dev
	file="$(git rev-parse --show-toplevel)/installers/cargo.sh"
	if [ -f "$file" ]; then
		# shellcheck source=/dev/null
		source "$file" spotify-tui
	else
		echo "$file not found"
	fi
fi
