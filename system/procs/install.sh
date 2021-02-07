#!/usr/bin/env bash

name=procs
if ! command -v "$name" >/dev/null 2>&1; then
	sudo snap install "$name"
fi
