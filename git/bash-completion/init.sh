#!/usr/bin/env bash

root=$(
	cd "$(dirname "$(readlink --canonicalize-existing "${BASH_SOURCE[0]}")")" || exit
	git rev-parse --show-toplevel
)
file="$root/git/bash-completion/bash-completion.bash"
if [ -f "$file" ]; then
	# shellcheck source=/dev/null
	source "$file"
else
	echo "$file not found"
fi
