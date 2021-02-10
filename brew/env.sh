#!/usr/bin/env bash

file="/home/linuxbrew/.linuxbrew/bin/brew"
if [ -f "$file" ]; then
	eval "$("$file" shellenv)"
fi
