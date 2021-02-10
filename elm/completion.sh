#!/usr/bin/env bash

file="$(
	cd "$(dirname "$(readlink --canonicalize-existing "${BASH_SOURCE[0]}")")" || exit
	find "$(git rev-parse --show-toplevel)" -path \*/bash/completion-install.sh -type f
)"
if [ -f "$file" ]; then
	# shellcheck source=/dev/null
	source "$file" elm https://raw.githubusercontent.com/dmy/elm-sh-completion/master/elm-completion.sh
else
	echo "completion-install.sh not found"
fi
