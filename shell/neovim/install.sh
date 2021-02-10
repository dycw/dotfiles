#!/usr/bin/env bash

if ! command -v nvim >/dev/null 2>&1; then
	file="$(
		cd "$(dirname "$(readlink --canonicalize-existing "${BASH_SOURCE[0]}")")" || exit
		find "$(git rev-parse --show-toplevel)" -path \*/brew/brew-install.sh -type f
	)"
	if [ -f "$file" ]; then
		# shellcheck source=/dev/null
		source "$file" nvim
	else
		echo "brew-install.sh not found"
	fi
fi
