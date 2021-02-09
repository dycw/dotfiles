#!/usr/bin/env bash

file="$HOME/.bash-completions/$1.sh"
if ! [ -f "$file" ]; then
	mkdir --parents "$(dirname "$file")"
	wget --output-document="$file" "$2"
fi
if [ -f "$file" ]; then
	# shellcheck source=/dev/null
	source "$file"
else
	echo "$file not found"
fi
