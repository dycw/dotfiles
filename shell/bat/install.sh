#!/usr/bin/env bash

if ! command -v bat >/dev/null 2>&1; then
	file="$(git rev-parse --show-toplevel)/rust/cargo-install.sh"
	if [ -f "$file" ]; then
		# shellcheck source=/dev/null
		source "$file" bat
	else
		echo "$file not found"
	fi
fi
