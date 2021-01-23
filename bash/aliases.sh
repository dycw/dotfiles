#!/usr/bin/env bash
# shellcheck disable=SC2154

# bat
alias cat=batcat

# cd
alias ~='cd ~'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias cddb='cd $PATH_DROPBOX'
alias cddf='cd $PATH_DOTFILES'
alias cddt='cd ~/Desktop'
alias cdw='cd ~/work'

# conda
alias cec='conda env create'
alias cel='conda env list'
alias cer='default_env="$CONDA_DEFAULT_ENV"; if ! [[ $default_env == base  ]]; then conda deactivate; conda env remove --name "$default_env"; fi'
alias ceu='conda env update --prune'

# evince
alias ev='evince'

# find
alias fd=fdfind
alias fdd='fd --type=directory'
alias fde='fd --type=executable'
alias fdf='fd --type=file'
alias fds='fd --type=symlink'

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

# pre-commit
alias pc='pre-commit run --files $(git diff --name-only | xargs )'
alias pci='pre-commit install'
alias pcaf='pre-commit run --all-files'
alias pcau='pre-commit autoupdate'
alias pcui='pre-commit uninstall'

# python
alias p='python'

# python install
alias pyinstall='pip install hvplot jupyterlab pyinstrument-decorator seaborn'

# python-path
alias pypath='export PYTHONPATH=.'

# tensorboard
alias tb='tensorboard --logdir .'

# vim
alias v=vim
