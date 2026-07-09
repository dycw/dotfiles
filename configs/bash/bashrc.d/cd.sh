# shellcheck shell=sh disable=SC2164
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
cdconfig() { cd "${XDG_CONFIG_HOME:-${HOME}/.config}"; }
cddb() { cd "${HOME}/Dropbox"; }
cddbt() { cd "${HOME}/Dropbox/Temporary"; }
cddf() { cd "${PATH_DOTFILES}"; }
cddl() { cd "${HOME}/Downloads"; }
cdp() { mkdir -p "${HOME}/personal" && cd "${HOME}/personal"; }
cdw() { mkdir -p "${HOME}/work" && cd "${HOME}/work"; }
