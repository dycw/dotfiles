#!/usr/bin/env bash

if ! command -v cargo >/dev/null 2>&1; then
	file="$(git rev-parse --show-toplevel)/rust/install.sh"
	if [ -f "$file" ]; then
		# shellcheck source=/dev/null
		source "$file"
	else
		echo "$file not found"
	fi
fi

if ! command -v "$1" >/dev/null 2>&1; then
	cargo install "$1"
fi
