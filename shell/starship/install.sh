#!/usr/bin/env bash

if ! command -v starship >/dev/null 2>&1; then
	sudo snap install starship
fi
