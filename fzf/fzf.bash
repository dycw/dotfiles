#!/usr/bin/env bash
# shellcheck disable=SC1090

path="$HOME/.fzf.bash"
if [ -f "$path" ]; then
	source "$path"
else
	printf "%(%Y-%m-%d %H:%M:%S)T: unable to find %s\n" -1 "$path"
fi
