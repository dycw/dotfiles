#!/usr/bin/env bash

name=dropbox.py
if command -v "$name" >/dev/null 2>&1; then
	"$name" autostart yes
	"$name" start >/dev/null 2>&1
else
	echo "$name not found"
fi
