#!/usr/bin/env bash

if ! command -v rmesg >/dev/null 2>&1; then
	file="$(git rev-parse --show-toplevel)/rust/cargo-install.sh"
	if [ -f "$file" ]; then
		# shellcheck source=/dev/null
		source "$file" rmesg
	else
		echo "$file not found"
	fi
fi
