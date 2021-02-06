#!/usr/bin/env bash

name=spotify
if ! command -v "$name" >/dev/null 2>&1; then
	sudo snap install "$name"
fi
