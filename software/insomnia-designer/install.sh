#!/usr/bin/env bash

name=insomnia-designer
if ! command -v "$name" >/dev/null 2>&1; then
	sudo snap install "$name"
fi
