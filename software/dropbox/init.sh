#!/usr/bin/env bash

if command -v dropbox.py >/dev/null 2>&1; then
	dropbox.py autostart yes
	dropbox.py start >/dev/null 2>&1
else
	echo "dropbox.py not found"
fi
