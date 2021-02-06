#!/usr/bin/env bash

if ! command -v sqlitebrowser >/dev/null 2>&1; then
	sudo snap install sqlitebrowser
fi
