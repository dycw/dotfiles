#!/usr/bin/env bash

if ! command -v fzf >/dev/null 2>&1; then
	path="$HOME/.fzf"
	git clone --depth 1 https://github.com/junegunn/fzf.git "$path"
	file="$path/install"
	if [ -f "$file" ]; then
		# shellcheck source=/dev/null
		source "$file"
	else
		echo "$file not found"
	fi
fi
