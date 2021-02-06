#!/usr/bin/env bash

if ! command -v bat >/dev/null 2>&1; then
	VERSION=0.17.1
	name="bat-musl_${VERSION}_amd64.deb"
	tmp_dir="$(mktemp -d -t bat-XXXXXX)"
	wget "https://github.com/sharkdp/bat/releases/download/v$VERSION/$name" -P "$tmp_dir"
	cd "$tmp_dir" || exit
	sudo dpkg -i "$name"
fi
