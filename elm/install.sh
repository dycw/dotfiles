#!/usr/bin/env bash

if ! command -v elm >/dev/null 2>&1; then
	VERSION=0.19.1
	name=binary-for-linux-64-bit
	gz_name="$name.gz"
	tmp_dir="$(mktemp -d -t elm-XXXXXX)"
	wget "https://github.com/elm/compiler/releases/download/$VERSION/$gz_name" -P "$tmp_dir"
	cd "$tmp_dir" || exit
	gunzip "$gz_name"
	chmod u+x "$name"
	sudo mv "$name" /usr/local/bin/elm
fi
