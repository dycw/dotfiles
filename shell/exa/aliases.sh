#!/usr/bin/env bash

if command -v exa >/dev/null 2>&1; then
	_EXA_ARGS="--classify --group-directories-first"
	_EXA_SHORT_ARGS="$_EXA_ARGS --across"
	alias l="exa \$_EXA_SHORT_ARGS --git-ignore"
	alias la="exa \$_EXA_SHORT_ARGS --all"
	_EXA_LONG_ARGS="\$_EXA_ARGS --git --group --header --long --time-style=long-iso"
	alias ll="exa \$_EXA_LONG_ARGS --git-ignore"
	alias lla="exa \$_EXA_LONG_ARGS --all"
	alias lal="lla"
fi
