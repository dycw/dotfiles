#!/usr/bin/env bash

if ! command -v exa >/dev/null 2>&1; then
	VERSION=0.9.0
	name=exa-linux-x86_64
	name_zip="$name-$VERSION.zip"
	tmp_dir="$(mktemp -d -t exa-XXXXXX)"
	wget "https://github.com/ogham/exa/releases/download/v$VERSION/$name_zip" -P "$tmp_dir"
	cd "$tmp_dir" || exit
	unzip "$name_zip"
	sudo mv "$name" /usr/local/bin/exa
fi
