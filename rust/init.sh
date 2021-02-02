#!/usr/bin/env bash
# shellcheck disable=SC1090

path="$HOME/.cargo/env"
if [ -f "$path" ]; then
	source "$path"
else
	printf "Unable to find %s\n" "$path"
fi
