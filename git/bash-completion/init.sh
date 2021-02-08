#!/usr/bin/env bash

file="$(find "$(git rev-parse --show-toplevel)" -path \*/rust/cargo-install.sh -type f)"
if [ -f "$file" ]; then
	# shellcheck source=/dev/null
	source "$file"
else
	echo "$file not found"
fi
