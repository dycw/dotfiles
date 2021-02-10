#!/usr/bin/env bash

if ! command -v kmon >/dev/null 2>&1; then
	sudo apt-get update
	sudo apt-get --yes install libssl-dev libxcb-shape0-dev libxcb-xfixes0-dev
	file="$(
		cd "$(dirname "$(readlink --canonicalize-existing "${BASH_SOURCE[0]}")")" || exit
		find "$(git rev-parse --show-toplevel)" -path \*/rust/cargo-install.sh -type f
	)"
	if [ -f "$file" ]; then
		# shellcheck source=/dev/null
		source "$file" kmon
	else
		echo "cargo-install.sh not found"
	fi
fi
