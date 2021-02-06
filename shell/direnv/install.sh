#!/usr/bin/env bash

if ! command -v direnv >/dev/null 2>&1; then
	curl -sfL https://direnv.net/install.sh | bash
fi
