# shellcheck shell=sh
if [ -z "${__dotfiles_bat_command:-}" ]; then
	if command -v bat >/dev/null 2>&1; then
		__dotfiles_bat_command=bat
	elif command -v batcat >/dev/null 2>&1; then
		__dotfiles_bat_command=batcat
	fi
fi

if [ -n "${__dotfiles_bat_command:-}" ]; then
	bat() { command "${__dotfiles_bat_command}" "$@"; }
	cat() { bat "$@"; }
	catp() { bat --style=plain "$@"; }
fi
