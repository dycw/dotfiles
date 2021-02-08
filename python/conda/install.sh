#!/usr/bin/env bash

if ! command -v conda >/dev/null 2>&1; then
	tmp_dir="$(mktemp -d)"
	cd "$tmp_dir" || exit
	wget --output-document=script.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
	chmod u+x script.sh
	# shellcheck source=/dev/null
	source script.sh
fi
