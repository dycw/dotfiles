#!/usr/bin/env bash

if ! command -v tldr >/dev/null 2>&1; then
	file="$(git rev-parse --show-toplevel)/installers/github-bin.sh"
	if [ -f "$file" ]; then
		VERSION=1.4.1
		tmp_dir="$(mktemp -d)"
		url="https://github.com/imsnif/bandwhich/releases/download/$VERSION/bandwhich-v$VERSION-x86_64-unknown-linux-musl.tar.gz"
		# shellcheck source=/dev/null
		source "$file" "$tmp_dir" "$url"
		sudo mv "$tmp_dir/binary" /usr/local/bin/tldr
	else
		echo "$file not found"
	fi
fi
