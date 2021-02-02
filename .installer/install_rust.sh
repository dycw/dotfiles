#!/usr/bin/env bash

if ! command -v cargo >/dev/null 2>&1; then
	printf "rust not found; installing...\n"
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	printf "rust installed\n"
fi
