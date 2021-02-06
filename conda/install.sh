#!/usr/bin/env bash

if ! command -v conda >/dev/null 2>&1; then
	name=Miniconda3-latest-Linux-x86_64.sh
	tmp_dir="$(mktemp -d -t conda-XXXXXX)"
	wget "https://repo.anaconda.com/miniconda/$name" -P "$tmp_dir"
	cd "$tmp_dir" || exit
	chmod u+x "$name"
	# shellcheck source=/dev/null
	source "$name"
fi
