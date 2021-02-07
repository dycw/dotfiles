#!/usr/bin/env bash

if ! command -v kmon >/dev/null 2>&1; then
	sudo apt-get update
	sudo apt-get --yes install libxcb-shape0-dev libxcb-xfixes0-dev
	file="$(git rev-parse --show-toplevel)/installers/cargo.sh"
	if [ -f "$file" ]; then
		# shellcheck source=/dev/null
		source "$file" kmon
	else
		echo "$file not found"
	fi
fi
