#!/usr/bin/env bash

if ! command -v elm >/dev/null 2>&1; then
	file="$(git rev-parse --show-toplevel)/installers/github-bin.sh"
	if [ -f "$file" ]; then
		VERSION=0.19.1
		tmp_dir="$(mktemp -d)"
		cd "$tmp_dir" || exit
		wget --output-document=elm.gz "https://github.com/elm/compiler/releases/download/$VERSION/binary-for-linux-64-bit.gz"
		gunzip elm.gz
		chmod u+x elm
		sudo mv elm /usr/local/bin
	else
		echo "$file not found"
	fi
fi
