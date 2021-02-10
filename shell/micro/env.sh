#!/usr/bin/env bash

if [ "$(command -v micro)" ] && ! [ "$(command -v vim)" ]; then
	export EDITOR=micro
fi
