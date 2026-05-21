#!/usr/bin/env bash
# Installed to ~/.bash_profile.d/path-dotfiles.sh; sourced by login shells.
# shellcheck disable=SC2155

# Resolve PATH_DOTFILES from the ~/.bashrc symlink target.
if [ -L "${HOME}/.bashrc" ]; then
	_t=$(readlink "${HOME}/.bashrc")
	case "${_t}" in
	/*) ;;
	*) _t="$(dirname "${HOME}/.bashrc")/${_t}" ;;
	esac
	PATH_DOTFILES=$(CDPATH='' cd -- "$(dirname "${_t}")/../.." && pwd -P)
	export PATH_DOTFILES
	unset _t
fi
