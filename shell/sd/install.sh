#!/usr/bin/env bash

if ! command -v sd >/dev/null 2>&1; then
	file="$(find "$(git rev-parse --show-toplevel)" -path \*/rust/cargo-install.sh -type f)"
	if [ -f "$file" ]; then
		# shellcheck source=/dev/null
		source "$file" sd
	else
		echo "cargo-install.sh not found"
	fi
fi
