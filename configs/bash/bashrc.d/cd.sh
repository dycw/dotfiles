# shellcheck shell=sh disable=SC2164
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

cdconfig() { cd "${XDG_CONFIG_HOME:-${HOME}/.config}"; }

if [ "$(uname)" = Darwin ]; then
	cdic() { cd "${ICLOUD_HOME:-${HOME}/Library/Mobile Documents/com~apple~CloudDocs}"; }

	cddl() { cd "${ICLOUD_HOME:-${HOME}/Library/Mobile Documents/com~apple~CloudDocs}/Downloads"; }

	cddoc() { cd "${ICLOUD_HOME:-${HOME}/Library/Mobile Documents/com~apple~CloudDocs}/Documents"; }
fi

cddf() { cd "${PATH_DOTFILES:-${HOME}/dotfiles}"; }

cdp() { mkdir -p "${HOME}/personal" && cd "${HOME}/personal"; }

cdw() { mkdir -p "${HOME}/work" && cd "${HOME}/work"; }
