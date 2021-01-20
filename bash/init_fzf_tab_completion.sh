#!/usr/bin/env bash
# shellcheck disable=SC1090

path="$PATH_DOTFILES/shell/fzf-tab-completion/bash/fzf-bash-completion.sh"
if [ -f "$path" ]; then
	source "$path"
	bind -x '"\t": fzf_bash_completion'
else
	timed_log "Unable to find %s\n" "$path"
fi
