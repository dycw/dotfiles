#!/usr/bin/env bash

if ! command -v gitui >/dev/null 2>&1; then
	file="$(git rev-parse --show-toplevel)/installers/cargo.sh"
	if [ -f "$file" ]; then
		# shellcheck source=/dev/null
		source "$file" gitui
	else
		echo "$file not found"
	fi
fi
