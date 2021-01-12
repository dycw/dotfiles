#!/usr/bin/env sh

# bump2version
alias bp='bump2version patch --allow-dirty'
alias bp-major='bump2version major --allow-dirty'
alias bp-minor='bump2version minor --allow-dirty'

# bat
alias cat=batcat
tf() {
	tail -f "$1" | batcat --paging=never -l log
}

# cd
alias ~='cd ~'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias cddb='cd $PATH_DROPBOX'
alias cddf='cd ~/.dotfiles'
alias cdw='cd ~/work'

# conda
alias ceu='conda env update --prune'

# dotfiles
alias gitconfig='$EDITOR ~/.config/git/config'
alias gitignore='$EDITOR ~/.config/git/ignore'
alias i3config='$EDITOR ~/.config/i3/config'
alias tmuxconf='$EDITOR ~/.tmux.conf'
alias vimrc='$EDITOR ~/.vimrc'
alias zshenv='$EDITOR ~/.zshenv'
alias zshrc='$EDITOR ~/.zshrc'
alias zshreload='. ~/.zshrc'
alias set-dotfiles-to-ssh="cddf && gremset origin git@github.com:dycw/dotfiles.git"

# dropbox
if command -v "dropbox.py" >/dev/null 2>&1; then
	dropbox.py start >/dev/null 2>&1
fi

# emacs mode
bindkey -e

# evince
alias ev='evince'

# find
alias fd=fdfind
alias fdd='fd --type=directory'
alias fde='fd --type=executable'
alias fdf='fd --type=file'
alias fds='fd --type=symlink'

# git
alias g='git'
# git add
alias ga='g add'
alias gaa='ga --all'
alias gaac='gaa && gc'
alias gaacm='gaa && gcm'
alias gai='gaa --interactive'
alias gap='ga --patch'
alias gapc='ga --patch && gc'
alias gaip='ga --interactive --patch'
gac() { git add "$@" && git commit; }
gacnv() { git add "$@" && git commit --no-verify; }
# git branch
alias gb='g branch --verbose'
alias gba='gb --all'
alias gbd='gb --delete'
alias gbr='gb --remote'
alias gbu='gb -u'
alias gbdD='gb -D'
alias gbdev='gbdD dev; gcob dev'
# git checkout
alias gco='g checkout'
alias gcob='gco -b'
alias gcom='gco master'
alias gcoml='gcom && gll'
alias gcop='gco --patch'
# git cherry-pick
alias gcp='g cherry-pick'
alias gcpa='gcp --abort'
alias gcpc='gcp --continue'
alias gcps='gcp --skip'
# git commit
alias gc='g commit'
alias gcm='gc --message'
alias gcnv='gc --no-verify'
alias gcnvm='gcnv -m'
# git diff
alias gd='g diff'
alias gdc='gd --cached'
# git fetch
alias gf='g fetch --all --prune'
# git log
alias gl='g log --oneline --decorate --graph'
# git merge
alias gm='g merge'
# git mv
alias gmv='g mv'
# git pull
alias gll='g pull'
# git push
alias gp='g push'
alias gpf='gp --force'
alias gpd='gp --dry-run'
# git rebase
alias grb='git rebase'
alias grba='grb --abort'
alias grbc='grb --continue'
alias grbi='grb --interactive'
alias grbm='grb master'
alias grbs='grb --skip'
# git remote
alias grem='g remote'
alias gremset='grem set-url'
alias gremu='grem update'
# git reset
alias gr='g reset'
alias grp='gr --patch'
# git revert
alias grv='g revert'
# git rm
alias grm='g rm'
alias grmc='grm --cached'
# git stash
alias gst='g stash'
alias gsta='gst apply'
alias gstc='gst clear'
alias gstd='gst drop'
alias gstl='gst list'
alias gstp='gst pop'
# git submodule
alias gsmurr='git submodule update --recursive --remote'
# git status
alias gs='g status --short'
# git/custom
alias gpb='g publish'
alias gpbnv='g unpublish-no-verify'
alias gupb='g unpublish'

# grep
alias grep='grep --color'

# hypothesis
alias hypothesis-ci='export HYPOTHESIS_PROFILE=ci'
alias hypothesis-debug='export HYPOTHESIS_PROFILE=debug'
alias hypothesis-default='export HYPOTHESIS_PROFILE=default'
alias hypothesis-dev='export HYPOTHESIS_PROFILE=dev'

# ib gateway
alias ib-gateway=~/Jts/ibgateway/978/ibgateway

# jupyter
alias juplab='jupyter lab'
alias jupnb='jupyter notebook'

# ls
alias l='ls -l --classify --color --human-readable --time-style=long-iso'
alias la='ls -hl --almost-all --classify --color --time-style=long-iso'
alias ld='ls -lt --classify --color --human-readable --reverse --time-style=long-iso'
alias lda='ls -lt --almost-all --classify --color --human-readable --reverse --time-style=long-iso'
alias lh='ls -l --classify --color --directory --human-readable .*'
alias lr='ls --classify --color --human-readable --recursive'
alias lra='ls --almost-all --classify --color --recursive'

# pre-commit
alias pc='pre-commit run --all-files'
alias pcau='pre-commit autoupdate'
alias pci='pre-commit install'
alias pcui='pre-commit uninstall'
alias pctr='pre-commit try-repo . --all-files'

# python
alias p='python'

# python clean
pyclean() {
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete
}

# python install
alias pyinstall='pip install hvplot jupyterlab pyinstrument-decorator seaborn'

# python-path
alias pypath='export PYTHONPATH=.'

# tensorboard
alias tb='tensorboard --logdir .'

# vim
alias v=vim

# zsh
HISTFILE=~/.cache/zsh/zsh_history
