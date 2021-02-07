#!/usr/bin/env bash

if ! command -v delta >/dev/null 2>&1; then
	file="$(git rev-parse --show-toplevel)/installers/"
	if [ -f "$file" ]; then
		# shellcheck source=/dev/null
		source "$file" git-delta
	else
		echo "$file not found"
	fi
fi
