#!/usr/bin/env bash

if ! command -v watchexec >/dev/null 2>&1; then
	file="$(git rev-parse --show-toplevel)/rust/cargo-install.sh"
	if [ -f "$file" ]; then
		# shellcheck source=/dev/null
		source "$file" watchexec
	else
		echo "$file not found"
	fi
fi
