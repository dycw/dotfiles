#!/usr/bin/env bash

process_link() {
	from=$1
	to=$2
	if [ -L "$to" ]; then
		target=$(readlink "$to")
		if ! [ "$target" = "$from" ]; then
			printf "Overwriting symlink:\n"
			printf "   %s\n" "$to"
			printf "-> |    %s\n" "$target"
			printf "   | -> %s\n" "$to"
			rm "$to"
			make_link "$from" "$to"
		fi
	else
		printf "Symlinking:\n"
		printf "   %s\n" "$from"
		printf "-> %s\n" "$to"
		make_link "$from" "$to"
	fi
}

make_link() {
	from=$1
	to=$2
	mkdir -p "$(dirname "$to")"
	ln -s "$from" "$to"
}

declare -A mappings=()
mappings["bash/bash_profile.sh"]=".bash_profile"
mappings["bash/bashrc.sh"]=".bashrc"
mappings["git/config"]=".config/git/config"
mappings["git/ignore"]=".config/git/ignore"
mappings["i3/config"]=".config/i3/config"
mappings["i3/status"]=".config/i3status/config"
mappings["ipython/ipython_config.py"]=".ipython/profile_default/ipython_config.py"
mappings["jupyter/jupyter_notebook_config.py"]=".jupyter/jupyter_notebook_config.py"
mappings["npm/npmrc"]=".npmrc"
mappings["shell/direnvrc.sh"]=".config/direnv/direnvrc"
mappings["shell/inputrc.sh"]=".inputrc"
mappings["tmux/tmux.conf"]=".tmux.conf"
mappings["vim/vimrc"]=".vimrc"
for key in "${!mappings[@]}"; do
	from="$PATH_DOTFILES/$key"
	value="${mappings[$key]}"
	to="$HOME/$value"
	process_link "$from" "$to"
done

for filename in "$PATH_DOTFILES"/ipython/startup/*.py; do
	process_link "$filename" "$HOME/.ipython/profile_default/startup/$(basename "$filename")"
done
