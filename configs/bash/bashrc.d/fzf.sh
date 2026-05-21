# shellcheck shell=bash
if command -v fzf >/dev/null 2>&1; then
	if command -v fd >/dev/null 2>&1; then
		export FZF_DEFAULT_COMMAND='fd --hidden --type=file --follow --exclude .git'
		export FZF_CTRL_T_COMMAND='fd --hidden --type=file --follow --exclude .git'
		export FZF_ALT_C_COMMAND='fd --hidden --type=directory --follow --exclude .git'
	elif command -v fdfind >/dev/null 2>&1; then
		export FZF_DEFAULT_COMMAND='fdfind --hidden --type=file --follow --exclude .git'
		export FZF_CTRL_T_COMMAND='fdfind --hidden --type=file --follow --exclude .git'
		export FZF_ALT_C_COMMAND='fdfind --hidden --type=directory --follow --exclude .git'
	fi
	eval "$(fzf --bash)"
fi
