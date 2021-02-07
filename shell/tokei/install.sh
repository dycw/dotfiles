#!/usr/bin/env bash

if ! command -v tokei >/dev/null 2>&1; then
	VERSION=12.1.2
	name=tokei-x86_64-unknown-linux-musl.tar.gz
	tmp_dir="$(mktemp -d -t tokei-XXXXXX)"
	wget "https://github.com/XAMPPRocky/tokei/releases/download/v$VERSION/$name" -P "$tmp_dir"
	cd "$tmp_dir" || exit
	tar -zxvf "$name"
	sudo mv tokei /usr/local/bin/tokei
fi
