#!/usr/bin/env bash

if command -v dropbox.py >/dev/null 2>&1; then
	alias cddb="cd \$PATH_DROPBOX"
fi
