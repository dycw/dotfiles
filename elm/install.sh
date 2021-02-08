#!/usr/bin/env bash

if ! command -v elm >/dev/null 2>&1; then
	VERSION=0.19.1
	tmp_dir="$(mktemp -d)"
	cd "$tmp_dir" || exit
	wget --output-document=elm.gz "https://github.com/elm/compiler/releases/download/$VERSION/binary-for-linux-64-bit.gz"
	gunzip elm.gz
	chmod u+x elm
	sudo mv elm /usr/local/bin
fi
