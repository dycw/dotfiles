#!/usr/bin/env bash
# Installed to ~/.bash_profile.d/editor.sh; sourced by login shells.
# shellcheck disable=SC2155

if command -v vim >/dev/null 2>&1; then
	export EDITOR=vim
	export VISUAL=vim
elif command -v vi >/dev/null 2>&1; then
	export EDITOR=vi
	export VISUAL=vi
elif command -v nano >/dev/null 2>&1; then
	export EDITOR=nano
	export VISUAL=nano
fi
