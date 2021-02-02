#!/usr/bin/env bash

dir="$PATH_DOTFILES/dropbox"
if [ -d "$dir" ]; then
	PATH="$dir${PATH:+:${PATH}}"
	file="$dir/dropbox.py"
	if [ -f "$file" ]; then
		"$file" autostart yes
		"$file" start >/dev/null 2>&1
	else
		printf "Unable to find %s\n" "$file"
	fi
else
	printf "Unable to find %s\n" "$dir"
fi
