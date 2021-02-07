#!/usr/bin/env bash

if ! command -v btm >/dev/null 2>&1; then
	VERSION=0.5.7
	name="bottom_${VERSION}_amd64.deb"
	tmp_dir="$(mktemp -d -t bottom-XXXXXX)"
	wget "https://github.com/ClementTsang/bottom/releases/download/$VERSION/$name" -P "$tmp_dir"
	cd "$tmp_dir" || exit
	sudo dpkg -i "$name"
fi
