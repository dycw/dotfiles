#!/usr/bin/env bash

if command -v bash-it >/dev/null 2>&1; then
	path="$HOME/.bash_it"
	git clone --depth=1 https://github.com/Bash-it/bash-it.git "$path"
	file="$path/install.sh"
	if [ -f "$file" ]; then
		# shellcheck source=/dev/null
		source "$file"

		declare -a aliases=()
		aliases+=("apt")
		aliases+=("bash-it")
		aliases+=("clipboard")
		aliases+=("curl")
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
		echo "$file not found"
	fi
fi
