#!/usr/bin/env bash
# shellcheck disable=SC2139,SC2140

alias cdr='cd $(git rev-parse --show-toplevel)'

# https://gist.github.com/mwhite/6887990

for al in $(git --list-cmds=alias); do
	alias "g$al"="git $al"
done
