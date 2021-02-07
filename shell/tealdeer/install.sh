#!/usr/bin/env bash

if ! command -v tldr >/dev/null 2>&1; then
	file="$(git rev-parse --show-toplevel)/installers/github-bin.sh"
	if [ -f "$file" ]; then
		VERSION=1.4.1
		tmp_dir="$(mktemp -d)"
		cd "$tmp_dir" || exit
		wget --output-document=tldr "https://github.com/dbrgn/tealdeer/releases/download/v$VERSION/tldr-linux-x86_64-musl"
		sudo mv "$tmp_dir/tldr" /usr/local/bin
	else
		echo "$file not found"
	fi
fi
