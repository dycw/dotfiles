# shellcheck shell=bash
# shellcheck source=/dev/null

path="$HOME/dotfiles/shell/profile.sh"
if [ -f "$path" ]; then
	source "$path"
fi
