#!/usr/bin/env bash

if ! command -v conda >/dev/null 2>&1; then
	timed_log "conda not found; installing...\n"
	name="Miniconda3-latest-Linux-x86_64.sh"
	wget https://repo.anaconda.com/miniconda/$name -P /tmp
	path="/tmp/$name"
	chmod u+x "$path"
	"$path"
	timed_log "conda installed\n"
fi
