#!/usr/bin/env bash
# shellcheck disable=SC1090,SC2139,SC2140,SC2154

# https://gist.github.com/mwhite/6887990

path="$PATH_DOTFILES/git/bash-completion.bash"
if [ -f "$path" ]; then
	source "$path"

	function_exists() {
		declare -f -F "$1" >/dev/null
		return $?
	}

	for al in $(git --list-cmds=alias); do
		alias g"$al"="git $al"
		complete_func=_git_$(__git_aliased_command "$al")
		function_exists "$complete_fnc" && __git_complete g"$al" "$complete_func"
	done
else
	timed_log "Unable to find %s\n" "$path"
fi
