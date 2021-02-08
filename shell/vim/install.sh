#!/usr/bin/env bash

if ! command -v vim >/dev/null 2>&1; then
	sudo apt-get update
	sudo apt-get --yes vim
fi
