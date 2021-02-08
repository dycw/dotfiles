#!/usr/bin/env bash

if ! command -v googler >/dev/null 2>&1; then
	file="$(find "$(git rev-parse --show-toplevel)" -path \*/brew/brew-install.sh -type f)"
	if [ -f "$file" ]; then
		# shellcheck source=/dev/null
		source "$file" googler
	else
		echo "brew-install.sh not found"
	fi
fi
