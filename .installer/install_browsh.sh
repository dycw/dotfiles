#!/usr/bin/env bash

if ! command -v browsh >/dev/null 2>&1; then
	printf "browsh not found; installing...\n"
	cd "/tmp" || return
	file=browsh_1.6.4_linux_amd64.deb
	wget "https://github.com/browsh-org/browsh/releases/download/v1.6.4/$file"
	sudo dpkg -i "$file"
	printf "browsh installed\n"
fi
