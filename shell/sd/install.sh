#!/usr/bin/env bash

if ! command -v sd >/dev/null 2>&1; then
	file="$(git rev-parse --show-toplevel)/rust/cargo-install.sh"
	if [ -f "$file" ]; then
		# shellcheck source=/dev/null
		source "$file" sd
	else
		echo "$file not found"
	fi
fi
