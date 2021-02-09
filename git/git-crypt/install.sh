#!/usr/bin/env bash

if ! command -v git-crypt >/dev/null 2>&1; then
	sudo apt-get update
	sudo apt-get --yes install build-essential g++ libssl-dev make openssl-dev
	tmp_dir="$(mktemp -d)"
	cd "$tmp_dir" || exit
	git clone https://github.com/AGWA/git-crypt
	cd git-crypt || exit
	make
	sudo make install
fi
