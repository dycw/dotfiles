#!/usr/bin/env bash

if ! command -v mdcat >/dev/null 2>&1; then
	file="$(git rev-parse --show-toplevel)/rust/cargo-install.sh"
	if [ -f "$file" ]; then
		# shellcheck source=/dev/null
		source "$file" mdcat
	else
		echo "$file not found"
	fi
fi
