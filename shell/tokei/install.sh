#!/usr/bin/env bash

if ! command -v tokei >/dev/null 2>&1; then
	file="$(git rev-parse --show-toplevel)/installers/cargo.sh"
	if [ -f "$file" ]; then
		# shellcheck source=/dev/null
		source "$file" tokei
	else
		echo "$file not found"
	fi
fi
