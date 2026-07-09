# shellcheck shell=sh
if command -v zoxide >/dev/null 2>&1; then
	eval "$(zoxide init --cmd j bash)"
fi
