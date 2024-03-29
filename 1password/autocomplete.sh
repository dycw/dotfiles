#!/usr/bin/env bash

if [ -n "${BASH_VERSION+x}" ]; then
	# shellcheck source=/dev/null
	source <(op completion bash)
elif [ -n "${ZSH_VERSION+x}" ]; then
	eval "$(op completion zsh)"
	compdef _op op
fi
