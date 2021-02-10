#!/usr/bin/env bash

if command -v conda >/dev/null 2>&1; then
	alias cec="conda env create --force"
fi
