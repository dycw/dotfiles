#!/usr/bin/env bash

if ! command -v bandwhich >/dev/null 2>&1; then
	VERSION=0.20.0
	file="$(git rev-parse --show-toplevel)/installers/github-tar-gz.sh"
	if [ -f "$file" ]; then
		tmp_dir="$(mktemp -d)"
		url="https://github.com/imsnif/bandwhich/releases/download/$VERSION/bandwhich-v$VERSION-x86_64-unknown-linux-musl.tar.gz"
		# shellcheck source=/dev/null
		source "$file" "$tmp_dir" "$url"
		sudo mv "$tmp_dir/bandwhich" /usr/local/bin/bandwhich
	else
		echo "$file not found"
	fi
fi
