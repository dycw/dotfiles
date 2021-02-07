#!/usr/bin/env bash

if ! command -v tldr >/dev/null 2>&1; then
	VERSION=1.4.1
	name=tldr-linux-x86_64-musl
	tmp_dir="$(mktemp -d -t tldr-XXXXXX)"
	wget "https://github.com/dbrgn/tealdeer/releases/download/v$VERSION/$name" -P "$tmp_dir"
	cd "$tmp_dir" || exit
	chmod u+x "$name"
	sudo mv "$name" /usr/local/bin/tldr
fi
