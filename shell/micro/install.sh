#!/usr/bin/env bash

if ! command -v micro >/dev/null 2>&1; then
	cd /usr/local/bin || exit
	curl https://getmic.ro | bash
fi
