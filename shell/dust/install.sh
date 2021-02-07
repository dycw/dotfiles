#!/usr/bin/env bash

if ! command -v dust >/dev/null 2>&1; then
	VERSION=0.5.4
	name="dust-v$VERSION-x86_64-unknown-linux-musl"
	name_tar_gz="$name.tar.gz"
	tmp_dir="$(mktemp -d -t dust-XXXXXX)"
	wget "https://github.com/bootandy/dust/releases/download/v$VERSION/$name_tar_gz" -P "$tmp_dir"
	cd "$tmp_dir" || exit
	tar -zxvf "$name_tar_gz"
	sudo mv "$name/dust" /usr/local/bin/dust
fi
