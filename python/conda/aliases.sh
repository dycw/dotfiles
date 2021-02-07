#!/usr/bin/env bash

if command -v conda >/dev/null 2>&1; then
	alias cec='conda env create --force'
	alias cel='conda env list'
	alias cer='conda env remove'
	alias ceu='conda env update'
fi
