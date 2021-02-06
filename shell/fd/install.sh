#!/usr/bin/env bash

if ! command -v fd >/dev/null 2>&1; then
	VERSION=8.2.1
	name="fd-musl_${VERSION}_amd64.deb"
	tmp_dir="$(mktemp -d -t fd-XXXXXX)"
	wget "https://github.com/sharkdp/fd/releases/download/v$VERSION/$name" -P "$tmp_dir"
	cd "$tmp_dir" || exit
	sudo dpkg -i "$name"
fi
