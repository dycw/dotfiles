#!/usr/bin/env bash

if ! command -v delta >/dev/null 2>&1; then
	file="$(
		cd "$(dirname "$(readlink --canonicalize-existing "${BASH_SOURCE[0]}")")" || exit
		find "$(git rev-parse --show-toplevel)" -path \*/rust/cargo-install.sh -type f
	)"
	if [ -f "$file" ]; then
		# shellcheck source=/dev/null
		source "$file" git-delta
	else
		echo "cargo-install.sh not found"
	fi
fi
