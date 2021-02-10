#!/usr/bin/env bash

file="$(
	cd "$(dirname "$(readlink --canonicalize-existing "${BASH_SOURCE[0]}")")" || exit
	find "$(git rev-parse --show-toplevel)" -path \*/brew/install.sh -type f
)"
if [ -f "$file" ]; then
	# shellcheck source=/dev/null
	source "$file"
fi

if ! command -v "$1" >/dev/null 2>&1; then
	brew install "$1"
fi
