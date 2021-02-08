#!/usr/bin/env bash

file="$(
	cd "$(dirname "$(readlink --canonicalize-existing "${BASH_SOURCE[0]}")")" || exit
	find "$(git rev-parse --show-toplevel)" -path \*/bash-completion/bash-completion.bash -type f
)"
if [ -f "$file" ]; then
	# shellcheck source=/dev/null
	source "$file"
else
	echo "bash-completion.bash not found"
fi
