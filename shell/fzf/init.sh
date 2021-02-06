#!/usr/bin/env bash

file="$HOME/.fzf.bash"
if [ -f "$file" ]; then
	# shellcheck source=/dev/null
	source "$file"
else
	echo "$file not found"
fi
