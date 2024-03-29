#!/usr/bin/sh

# coverage
alias open-cov='open .coverage/html/index.html'

# hypothesis
alias hypothesis-ci='export HYPOTHESIS_PROFILE=ci'
alias hypothesis-debug='export HYPOTHESIS_PROFILE=debug'
alias hypothesis-default='export HYPOTHESIS_PROFILE=default'
alias hypothesis-dev='export HYPOTHESIS_PROFILE=dev'

# pip
alias pi='pip install'
alias pie='pip install --editable .'
alias piip='pip install ipython'
alias pijl='pip install jupyterlab jupyterlab-vim'
alias pipt='pip install pip-tools'
alias piup='pip install --upgrade pip'
alias plo='pip list --outdated'
alias pui='pip uninstall'
alias pipconf='$EDITOR "${XDG_CONFIG_HOME:-$HOME/.config}/pip/pip.conf"'
alias pypirc='$EDITOR "$HOME/.pypirc"'

# pyproject.toml
alias pyprojecttoml='$EDITOR $(git rev-parse --show-toplevel)/pyproject.toml'

# pytest
alias pytco='pytest --co'

if git rev-parse --show-toplevel >/dev/null 2>&1; then
	_root="$(git rev-parse --show-toplevel)"
	if [ -f "$_root/pyproject.toml" ]; then
		_file="$HOME/dotfiles/bin/pytest-aliases"
		if [ -f "$_file" ]; then
			# shellcheck source=/dev/null
			. "$_file"
		fi
	fi
fi
