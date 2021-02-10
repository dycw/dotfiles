#!/usr/bin/env bash

if command -v vim >/dev/null 2>&1; then
	if ! command -v nvim >/dev/null 2>&1; then
		export EDITOR=nvim
	fi
fi
