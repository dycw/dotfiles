#!/usr/bin/env bash
# shellcheck disable=SC2155

if command -v nvim >/dev/null 2>&1; then
	export EDITOR=nvim
	export VISUAL=nvim
elif command -v vim >/dev/null 2>&1; then
	export EDITOR=vim
	export VISUAL=vim
elif command -v vi >/dev/null 2>&1; then
	export EDITOR=vi
	export VISUAL=vi
elif command -v nano >/dev/null 2>&1; then
	export EDITOR=nano
	export VISUAL=nano
fi
