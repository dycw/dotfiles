#!/usr/bin/env bash

if ! command -v starship >/dev/null 2>&1; then
	curl -fsSL https://starship.rs/install.sh | bash
fi
