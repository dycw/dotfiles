#!/usr/bin/env bash

if ! command -v rg >/dev/null 2>&1; then
	printf "ripgrep not found; installing...\n"
	name="ripgrep_12.1.1_amd64.deb"
	curl -LO "https://github.com/BurntSushi/ripgrep/releases/download/12.1.1/$name"
	sudo dpkg -i "$name"
	rm "$name"
	printf "ripgrep installed\n"
fi
