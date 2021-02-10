#!/usr/bin/env bash

if [ "$(command -v vim)" ] && ! [ "$(command -v nvim)" ]; then
	export EDITOR=nvim
fi
