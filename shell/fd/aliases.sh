#!/usr/bin/env bash

if command -v fd >/dev/null 2>&1; then
	alias fdd='fd --type=directory'
	alias fde='fd --type=executable'
	alias fdf='fd --type=file'
	alias fds='fd --type=symlink'
fi
