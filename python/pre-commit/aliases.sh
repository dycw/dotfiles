#!/usr/bin/env bash

if command -v python >/dev/null 2>&1; then
	alias pc='pre-commit-current'
	alias pci='pre-commit install'
	alias pc='pre-commit-loop'
	alias pcaf='pre-commit run --all-files'
	alias pcau='pre-commit autoupdate'
	alias pcui='pre-commit uninstall'
fi
