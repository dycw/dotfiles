#!/usr/bin/env bash
# shellcheck disable=SC1090

path="$BASH_IT/bash_it.sh"
if [ -f "$path" ]; then
	source "$path"

	declare -a aliases=()
	aliases+=("apt")
	aliases+=("bash-it")
	aliases+=("clipboard")
	aliases+=("curl")
	aliases+=("general")
	aliases+=("npm")
	aliases+=("tmux")
	aliases+=("vim")
	for alias_ in "${aliases[@]}"; do
		bash-it enable alias "$alias_" >/dev/null 2>&1
	done

	declare -a completions=()
	completions+=("bash-it")
	completions+=("git")
	for completion in "${completions[@]}"; do
		bash-it enable completion "$completion" >/dev/null 2>&1
	done

	declare -a plugins=()
	plugins+=("alias-completion")
	plugins+=("base")
	plugins+=("direnv")
	plugins+=("fzf")
	plugins+=("history")
	plugins+=("man")
	plugins+=("tmux")
	plugins+=("xterm")
	for plugin in "${plugins[@]}"; do
		bash-it enable plugin "$plugin" >/dev/null 2>&1
	done
else
	printf "Unable to find %s\n" "$path"
fi
