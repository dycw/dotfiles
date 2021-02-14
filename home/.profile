#!/usr/bin/env bash

# shellcheck shell=bash
# shellcheck source=/dev/null

profile="$HOME/dotfiles/shell/profile.sh"
if [ -f "$profile" ]; then
	source "$profile"
fi
