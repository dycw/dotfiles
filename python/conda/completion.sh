#!/usr/bin/env bash

file="$(
	cd "$(dirname "$(readlink --canonicalize-existing "${BASH_SOURCE[0]}")")" || exit
	find "$(git rev-parse --show-toplevel)" -path \*/bash/completion-install.sh -type f
)"
if [ -f "$file" ]; then
	# shellcheck source=/dev/null
	source "$file" conda https://raw.githubusercontent.com/tartansandal/conda-bash-completion/master/conda
else
	echo "completion-install.sh not found"
fi
