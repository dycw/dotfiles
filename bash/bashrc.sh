#!/usr/bin/env bash
# shellcheck disable=SC1090

# Set $PATH_DOTFILES
PATH_DOTFILES="$(dirname "$(dirname "$(readlink --canonicalize-existing "${BASH_SOURCE[0]}")")")"
export PATH_DOTFILES
PATH="$PATH_DOTFILES/bin${PATH:+:${PATH}}"

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# some settings
shopt -s histappend
shopt -s checkwinsize
#shopt -s globstar

declare -a scripts=()
scripts+=("bash/aliases")
scripts+=("bash/configure_bash")
scripts+=("bash/init_bash_it")
scripts+=("bash/init_fzf_tab_completion")
scripts+=("bash/init_git_aliases")
scripts+=("bash/init_zoxide")
scripts+=("conda/init")
scripts+=("dropbox/init")
scripts+=("rust/init")
for script in "${scripts[@]}"; do
	path_script="$PATH_DOTFILES/$script.sh"
	if [ -f "$path_script" ]; then
		source "$path_script"
	else
		timed_log "%Unable to find %s\n" "$path_script"
	fi
done
