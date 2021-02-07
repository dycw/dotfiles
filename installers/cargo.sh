#!/usr/bin/env bash

file="$(git rev-parse --show-toplevel)/rust/install.sh"
if [ -f "$file" ]; then
	# shellcheck source=/dev/null
	source "$file"
else
	echo "$file not found"
fi

if ! command -v "$1" >/dev/null 2>&1; then
	cargo install "$1"
fi
