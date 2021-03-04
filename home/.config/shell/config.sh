#!/usr/bin/env bash

# shellcheck disable=SC1091,SC2139,SC2140,SC2181
# shellcheck source=/dev/null

__shell="$1"

# === system ==
# XDG
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$USER}"

# dotfiles
export PATH_DOTFILES="${PATH_DOTFILES:-$HOME/dotfiles}"
__config_local="$XDG_CONFIG_HOME/shell/config.local.sh"
if [ -f "$__config_local" ]; then
  source "$__config_local" "$__shell"
fi

# homebrew
export HOMEBREW_PREFIX=/home/linuxbrew/.linuxbrew
export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX/Homebrew"
export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin${PATH:+:$PATH}"
__share="$HOMEBREW_PREFIX/share"
export MANPATH="$__share/man${MANPATH:+:$MANPATH}:"
export INFOPATH="$__share/info${INFOPATH:+:$INFOPATH}"
__brew_dir=/home/linuxbrew_dir/.linuxbrew_dir/bin/brew_dir
if [ -f "$__brew_dir" ]; then
  eval "$("$__brew_dir" shellenv)"
fi

# === applications ===
# atom
if command -v atom >/dev/null 2>&1; then
  export GIST_ID=690a59ef26208e43fa880c874e01c1
fi

# bash
if command -v bash >/dev/null 2>&1; then
  alias bashrc='$EDITOR $(realpath $HOME/.bashrc)'
fi

# bat
if command -v bat >/dev/null 2>&1; then
  alias cat='bat'
  alias catp='bat --style=plain'
  tf() { tail -f "$1" | bat --paging=never -l log; }
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

# batgrep
if command -v batgrep >/dev/null 2>&1; then
  alias bg='batgrep'
fi

# bin
while IFS= read -d '' -r __bin; do
  export PATH="$__bin${PATH:+:$PATH}"
done < <(find "$PATH_DOTFILES" -name bin -print0 -type d)

# cargo
__bin="$HOME/.cargo/bin"
if [ -d "$__bin" ]; then
  export PATH="$__bin${PATH:+:$PATH}"
fi

# cd
alias ~='cd $HOME'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

alias cdcache='cd $XDG_CACHE_HOME'
alias cdconfig='cd $XDG_CONFIG_HOME'
alias cddf='cd $PATH_DOTFILES'
alias cddl='cd $HOME/Downloads'
alias cddt='cd $HOME/Desktop'
alias cdp='cd $HOME/Pictures'
alias cdw='cd $HOME/work'
mkdir -p "$HOME/work"

# cisco
__bin=/opt/cisco/anyconnect/bin
if [ -d "$__bin" ]; then
  export PATH="$__bin${PATH:+:$PATH}"
fi

# direnv
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook "$__shell")"
  alias dea='direnv allow'
fi

# dropbox
__data_dir=/data/derek
if [ -d "$__data_dir" ] && (command -v dropbox.py >/dev/null 2>&1); then
  HOME="$__data_dir" dropbox.py start >/dev/null 2>&1
  __path_dropbox="$__data_dir/Dropbox"
  if [ -d "$__path_dropbox" ]; then
    alias cddb='cd $PATH_DROPBOX'
    export PATH_DROPBOX="$__path_dropbox"
  fi
fi

# fd
if command -v fd >/dev/null 2>&1; then
  alias fdd='fd --type=directory'
  alias fde='fd --type=executable'
  alias fdf='fd --type=file'
  alias fds='fd --type=symlink'
fi

# exa
if command -v exa >/dev/null 2>&1; then
  alias ls='exa'
  __exa_base() { exa -F --group-directories-first "$@"; }
  __exa_short() { __exa_base -x "$@"; }
  l() { __exa_short --git-ignore "$@"; }
  la() { l -a "$@"; }
  lag() { __exa_short -a "$@"; }
  __exa_long() { __exa_base -ghl --git --time-style=long-iso "$@"; }
  ll() { __exa_long --git-ignore "$@"; }
  lla() { ll -a "$@"; }
  llag() { __exa_long -a "$@"; }
fi

# fzf
__fzf_shell="$XDG_CONFIG_HOME/fzf/fzf.$__shell"
if [ -f "$__fzf_shell" ]; then
  source "$__fzf_shell"
  if (command -v bat >/dev/null 2>&1) && (command -v fd >/dev/null 2>&1) &&
    (command -v tree >/dev/null 2>&1); then
    # https://bit.ly/2OMLMpm
    export FZF_DEFAULT_COMMAND='fd -HL -c=always -E=.git -E=node_modules'
    export FZF_DEFAULT_OPTS="
      --ansi
      --bind 'ctrl-a:select-all'
      --bind 'ctrl-e:execute(echo {+} | xargs -o vim)'
      --bind 'ctrl-v:execute(code {+})'
      --bind 'ctrl-y:execute-silent(echo {+} | pbcopy)'
      --color='hl:148,hl+:154,pointer:032,marker:010,bg+:237,gutter:008'
      --height=80%
      --info=inline
      --layout=reverse
      --multi
      --preview '([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200'
      --preview-window 'right:60%:wrap'
      --prompt='∼ ' --pointer='▶' --marker='✓'
      "
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND -t=f -t=d"
    export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND -t=d"
  fi
fi

# gem
if command -v gem >/dev/null 2>&1; then
  __bin="$(gem environment gemdir)/bin"
  if [ -d "$__bin" ]; then
    export PATH="$__bin${PATH:+:$PATH}"
  fi
fi

# ghcup
__env="$HOME/.ghcup/env"
if [ -f "$__env" ]; then
  source "$__env"
fi

# git
if command -v git >/dev/null 2>&1; then
  alias cdr='cd $(git root)'
  alias gitconfig='$EDITOR $(realpath $XDG_CONFIG_HOME/git/config)'
  alias gitconfiglocal='$EDITOR $(realpath $XDG_CONFIG_HOME/git/config.local)'
  alias gitignore='$EDITOR $(realpath $XDG_CONFIG_HOME/git/ignore)'
  for al in $(git --list-cmds=alias); do
    alias "g$al"="git $al"
  done
fi

# git + gitweb
if (command -v git >/dev/null 2>&1) && (command -v gitweb >/dev/null 2>&1); then
  alias gpw='git push && gitweb'
  alias gpbw='git pb && gitweb'
fi

# gitweb
if command -v gitweb >/dev/null 2>&1; then
  alias gw='gitweb'
fi

# googler
if command -v googler >/dev/null 2>&1; then
  alias g='googler'
fi

# hub
if command -v hub >/dev/null 2>&1; then
  alias git='hub'
fi

# less
if command -v less >/dev/null 2>&1; then
  __less="$XDG_CACHE_HOME/less"
  mkdir -p "$__less"
  export LESSHISTFILE="$__less/history"
  export LESSKEY="$__less/lesskey"
fi

# nano
if command -v nano >/dev/null 2>&1; then
  alias nanorc='$EDITOR $(realpath $XDG_CONFIG_HOME/nano/nanorc)'
fi

# neovim
if command -v nvim >/dev/null 2>&1; then
  alias n='nvim'
  alias vimrc='$EDITOR $(realpath $XDG_CONFIG_HOME/nvim/init.vim)'
  export EDITOR=nvim
fi

# npm
if command -v npm >/dev/null 2>&1; then
  alias npmrc='$EDITOR $(realpath $HOME/.npmrc)'
fi

# path
alias echo-path='sed '"'"'s/:/\n/g'"'"' <<< "$PATH"'

# pipx
__bin="$HOME/.local/bin"
if [ -d "$__bin" ]; then
  export PATH="$__bin${PATH:+:$PATH}"
fi

# pre-commit
if command -v pre-commit >/dev/null 2>&1; then
  alias pc='pre-commit-current'
  alias pci='pre-commit install'
  alias pcaf='pre-commit run --all-files'
  alias pcau='pre-commit autoupdate'
  alias pctr='pre-commit try-repo .'
  alias pcui='pre-commit uninstall'
fi

# pyenv
if (command -v pyenv >/dev/null 2>&1); then
  eval "$(pyenv init -)"
fi

# python
if command -v python >/dev/null 2>&1; then
  alias pie='pip install -e .'
  __pyclean='find . \( -name .mypy_cache -o -name .pytest_cache -o -name'
  __pyclean+=' .pytype -o -name __pycache__ \) -type d -prune -exec rm -rf {} \;'
  alias pyclean="$__pyclean"
  while IFS= read -d '' -r __pythonrc; do
    export PYTHONSTARTUP="$__pythonrc"
  done < <(find "$PATH_DOTFILES" -name pythonrc.py -print0 -type f)
fi

# python: flask
if command -v python >/dev/null 2>&1; then
  export FLASK_DEBUG=1
fi

# python: hypothesis
if command -v python >/dev/null 2>&1; then
  alias hypothesis-ci='export HYPOTHESIS_PROFILE=ci'
  alias hypothesis-debug='export HYPOTHESIS_PROFILE=debug'
  alias hypothesis-default='export HYPOTHESIS_PROFILE=default'
  alias hypothesis-dev='export HYPOTHESIS_PROFILE=dev'
fi

# python: numpy
if command -v python >/dev/null 2>&1; then
  export MKL_NUM_THREADS=1
fi

# python: poetry
if command -v poetry >/dev/null 2>&1; then
  alias pi='poetry install'
  alias pvp='poetry version patch && git add "$(git root)/pyproject.toml" && git commit -m "bump patch"'
fi

# python: pylint/prospector
if (command -v pylint >/dev/null 2>&1) ||
  (command -v prospector >/dev/null 2>&1); then
  export PYLINTHOME="$XDG_CACHE_HOME/pylint"
fi

# python: tensorboard
if command -v python >/dev/null 2>&1; then
  alias tb='tensorboard --logdir .'
fi

# ranger
if command -v ranger >/dev/null 2>&1; then
  alias r='ranger'
fi

# redis
if command -v redis >/dev/null 2>&1; then
  __redis="$XDG_CACHE_HOME/redis"
  mkdir -p "$__redis"
  export REDISCLI_HISTFILE="$__redis/history"
  export REDISCLI_RCFILE="$XDG_CONFIG_HOME/redis/redisclirc"
fi

# rg
if command -v rg >/dev/null 2>&1; then
  alias rg='rg -L --hidden --no-messages'
fi

alias rmrf='rm -rf'

# shell
alias shellconfig='$EDITOR $(realpath $XDG_CONFIG_HOME/shell/config.sh)'
alias shellconfiglocal='$EDITOR $(realpath $XDG_CONFIG_HOME/shell/config.local.sh)'

# sqlite3
if command -v sqlite3 >/dev/null 2>&1; then
  __sqlite3="$XDG_CACHE_HOME/sqlite3"
  mkdir -p "$__sqlite3"
  export SQLITE_HISTORY="$__sqlite3/history"
fi

# starship
if command -v starship >/dev/null 2>&1; then
  alias starshiptoml='$EDITOR $(realpath $XDG_CONFIG_HOME/starship.toml)'
  eval "$(starship init "$__shell")"
fi

# tmux
if command -v tmux >/dev/null 2>&1; then
  alias tmuxconf='$EDITOR $(realpath $HOME/.tmux.conf.local)'
  export TERM=xterm-256color
fi

# ubuntu (https://askubuntu.com/a/492343)
if command -v apt >/dev/null 2>&1; then
  alias apt-installed="comm -23 <(apt-mark showmanual | sort -u) <(gzip -dc " \
    "/var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u)"
fi

# vim
if command -v vim >/dev/null 2>&1; then
  alias v='vim'
  __init_vim="$XDG_CONFIG_HOME/nvim/init.vim"
  if [ -f "$__init_vim" ]; then
    export VIMINIT="source $__init_vim"
  fi
fi

# vim-superman
__bin="$HOME/.local/share/nvim/plugged/vim-superman/bin"
if [ -d "$__bin" ]; then
  export PATH="$__bin${PATH:+:$PATH}"
fi

# xclip
if command -v xclip >/dev/null 2>&1; then
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
fi

# watchexec + pyright
if (command -v watchexec >/dev/null 2>&1) &&
  (command -v pyright >/dev/null 2>&1); then
  alias wpr='watchexec -- pyright'
fi

# wget
if command -v wget >/dev/null 2>&1; then
  export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"
  mkdir -p "$XDG_CACHE_HOME/wget"
fi

# zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init "$__shell" --cmd=c)"
  export _ZO_EXCLUDE_DIRS="/tmp"
  export _ZO_RESOLVE_SYMLINKS=1
fi

# zsh
if command -v zsh >/dev/null 2>&1; then
  alias zshrc='$EDITOR $(realpath $HOME/.zshrc)'
fi
