#!/usr/bin/env bash

if ! command -v rg >/dev/null 2>&1; then
	VERSION=12.1.1
	name="ripgrep_${VERSION}_amd64.deb"
	tmp_dir="$(mktemp -d -t ripgrep-XXXXXX)"
	wget "https://github.com/BurntSushi/ripgrep/releases/download/$VERSION/$name" -P "$tmp_dir"
	cd "$tmp_dir" || exit
	sudo dpkg -i "$name"
fi
