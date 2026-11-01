# shellcheck shell=sh

edit_bashrc() { "${EDITOR}" "${PATH_DOTFILES:-${HOME}/dotfiles}/configs/bash/bashrc"; }
