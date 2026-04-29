#!/usr/bin/env sh
# Installed to /etc/profile.d/env.sh; sourced by non-interactive and login shells.

#### xdg base directories #####################################################

export XDG_BIN_HOME="${XDG_BIN_HOME:-${HOME}/.local/bin}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"
export XDG_CONFIG_DIRS="${XDG_CONFIG_DIRS:-/etc/xdg}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
export XDG_DATA_DIRS="${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-${HOME}/.local/state}"

if [ -d "${HOME}/.local/bin" ]; then
	export PATH="${HOME}/.local/bin${PATH:+:${PATH}}"
fi

#### node #####################################################################

if command -v brew >/dev/null 2>&1 && brew --prefix node >/dev/null 2>&1; then
	_node_prefix=$(brew --prefix node)
	if [ -d "${_node_prefix}/bin" ]; then
		export PATH="${_node_prefix}/bin${PATH:+:${PATH}}"
	fi
	unset _node_prefix
fi

if [ -d "${HOME}/.local/share/nvm/v25.6.1/bin" ]; then
	export PATH="${HOME}/.local/share/nvm/v25.6.1/bin${PATH:+:${PATH}}"
fi

if [ -d "${HOME}/.npm-global/bin" ]; then
	export PATH="${HOME}/.npm-global/bin${PATH:+:${PATH}}"
fi

#### postgres #################################################################

if command -v brew >/dev/null 2>&1 && brew --prefix postgresql@18 >/dev/null 2>&1; then
	_pg_prefix=$(brew --prefix postgresql@18)
	if [ -d "${_pg_prefix}/bin" ]; then
		export PATH="${_pg_prefix}/bin${PATH:+:${PATH}}"
	fi
	unset _pg_prefix
fi

#### ripgrep ##################################################################

if command -v rg >/dev/null 2>&1; then
	export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME:-${HOME}/.config}/ripgrep/ripgreprc"
fi

#### rust #####################################################################

if [ -d "${HOME}/.cargo/bin" ]; then
	export PATH="${HOME}/.cargo/bin${PATH:+:${PATH}}"
fi

if command -v sccache >/dev/null 2>&1; then
	export RUSTC_WRAPPER=sccache
fi

#### tailscale ################################################################

if [ -d /Applications/Tailscale.app/Contents/MacOS ]; then
	export PATH="/Applications/Tailscale.app/Contents/MacOS${PATH:+:${PATH}}"
fi
