#!/usr/bin/env sh

# brew
__file='/opt/homebrew/bin/brew'
if [ -f "${__file}" ]; then
	eval "$(${__file} shellenv)"
fi

# flutter
__dir="$HOME"/development/flutter/bin
case ":${PATH}:" in
*:"$__dir":*) ;;
*)
	export PATH="${__dir}:${PATH}"
	;;
esac

# neovim
if command -v nvim >/dev/null 2>&1; then
	export EDITOR=nvim
else
	export EDITOR=vim
fi

# node
if command -v brew >/dev/null 2>&1; then
	__dir="$(brew --prefix)"/opt/node@20/bin
	case ":${PATH}:" in
	*:"$__dir":*) ;;
	*)
		export PATH="${__dir}:${PATH}"
		;;
	esac
fi

# pipx
__dir="${HOME}"/.local/bin
case ":${PATH}:" in
*:"${__dir}":*) ;;
*)
	export PATH="${__dir}:${PATH}"
	;;
esac

# ripgrep
export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME:-${HOME}/.config}/ripgreprc"

# rust
__dir="${HOME}"/.cargo/bin
case ":${PATH}:" in
*:"${__dir}":*) ;;
*)
	export PATH="${__dir}:${PATH}"
	;;
esac

# xdg
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
