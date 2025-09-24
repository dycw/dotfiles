#!/usr/bin/env sh
# shellcheck source=/dev/null

# brew
case "$(uname)" in
Darwin) __dir='/opt/homebrew/bin' ;;
Linux) __dir='/home/linuxbrew/.linuxbrew/bin' ;;
*) __dir='' ;;
esac
case ":${PATH}:" in
*:"$__dir":*) ;;
*) export PATH="${__dir}:${PATH}" ;;
esac
if command -v brew >/dev/null 2>&1; then
	eval "$(brew shellenv)"
fi

# flutter
__dir="${HOME}"/development/flutter/bin
case ":${PATH}:" in
*:"$__dir":*) ;;
*) export PATH="${__dir}:${PATH}" ;;
esac

# gitlab
export GITLAB_HOME="${HOME}/gitlab-docker"

# kdb
export QHOME="${HOME}"/q
__dir="${QHOME}"/m64
case ":${PATH}:" in
*:"${__dir}":*) ;;
*) export PATH="${__dir}:${PATH}" ;;
esac

# local
for __dir in "${HOME}"/bin "${HOME}"/.local/bin; do
	case ":${PATH}:" in
	*:"${__dir}":*) ;;
	*) export PATH="${__dir}:${PATH}" ;;
	esac
done

# neovim
if command -v nvim >/dev/null 2>&1; then
	export EDITOR=nvim
else
	export EDITOR=vim
fi

# node
if command -v brew >/dev/null 2>&1; then
	__dir="$(brew --prefix)/opt/node@20/bin"
	case ":${PATH}:" in
	*:"$__dir":*) ;;
	*) export PATH="${__dir}:${PATH}" ;;
	esac
fi

# postgres
if command -v brew >/dev/null 2>&1; then
	__dir="$(brew --prefix)/opt/postgresql@17/bin"
	case ":${PATH}:" in
	*:"$__dir":*) ;;
	*) export PATH="${__dir}:${PATH}" ;;
	esac
fi

# ripgrep
export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME:-${HOME}/.config}/ripgreprc"

# rust
__dir="${HOME}"/.cargo/bin
case ":${PATH}:" in
*:"${__dir}":*) ;;
*) export PATH="${__dir}:${PATH}" ;;
esac

# SSH
if ! pgrep -u "${USER}" ssh-agent >/dev/null; then
	eval "$(ssh-agent -s)"
fi

# tailscale
__dir='/Applications/Tailscale.app/Contents/MacOS'
case ":${PATH}:" in
*:"${__dir}":*) ;;
*) export PATH="${__dir}:${PATH}" ;;
esac

# tsunami
for __name in client server; do
	__dir="${HOME}"/work/tsunami-udp/tsunami-udp/"${__name}"
	case ":${PATH}:" in
	*:"${__dir}":*) ;;
	*) export PATH="${__dir}:${PATH}" ;;
	esac
done

# xdg
export XDG_BIN_HOME="${XDG_BIN_HOME:-${HOME}/.local/bin}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"
export XDG_CONFIG_DIRS="${XDG_CONFIG_DIRS:-/etc/xdg}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
export XDG_DATA_DIRS="${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-${HOME}/.local/state}"
