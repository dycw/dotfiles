# shellcheck disable=SC1091,SC2139,SC2140,SC2181
# shellcheck shell=bash
# shellcheck source=/dev/null

rc="$HOME/dotfiles/shell/rc.sh"
if [ -f "$rc" ]; then
	source "$rc" zsh
fi

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
export HISTSIZE=10000
export SAVEHIST=10000
setopt autocd extendedglob nomatch notify
unsetopt beep
bindkey -v
# End of lines configured by zsh-newuser-install

# === auto managed ===

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/derek/miniconda3/bin/conda' 'shell.zsh' 'hook' 2>/dev/null)"
if [ $? -eq 0 ]; then
	eval "$__conda_setup"
else
	if [ -f "/home/derek/miniconda3/etc/profile.d/conda.sh" ]; then
		. "/home/derek/miniconda3/etc/profile.d/conda.sh"
	else
		export PATH="/home/derek/miniconda3/bin:$PATH"
	fi
fi
unset __conda_setup
# <<< conda initialize <<<

# The following lines were added by compinstall
zstyle :compinstall filename '/home/derek/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
