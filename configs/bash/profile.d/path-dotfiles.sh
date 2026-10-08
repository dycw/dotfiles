#!/usr/bin/env bash
# shellcheck disable=SC2155

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
