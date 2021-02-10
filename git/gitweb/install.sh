#!/usr/bin/env bash

if ! command -v gitweb >/dev/null 2>&1; then
	sudo apt-get update
	sudo apt-get --yes install pkg-config
	file="$(
		cd "$(dirname "$(readlink --canonicalize-existing "${BASH_SOURCE[0]}")")" || exit
		find "$(git rev-parse --show-toplevel)" -path \*/rust/cargo-install.sh -type f
	)"
	if [ -f "$file" ]; then
		# shellcheck source=/dev/null
		source "$file" gitweb
	else
		echo "cargo-install.sh not found"
	fi
fi
