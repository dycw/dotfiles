if status --is-interactive
    # homebrew
    if test -d /opt/homebrew/bin
        fish_add_path /opt/homebrew/bin
        if type -q brew
            brew shellenv | source
        end
    end

    # pytest
    export PY_COLORS=1

    # ripgrep
    if test -f $XDG_CONFIG_HOME/ripgrep/ripgreprc
        export RIPGREP_CONFIG_PATH=$XDG_CONFIG_HOME/ripgrep/ripgreprc
    end

    # XDG
    set -Ux XDG_BIN_HOME (set -q XDG_BIN_HOME; and echo $XDG_BIN_HOME; or echo $HOME/.local/bin)
    set -Ux XDG_CACHE_HOME (set -q XDG_CACHE_HOME; and echo $XDG_CACHE_HOME; or echo $HOME/.cache)
    set -Ux XDG_CONFIG_DIRS (set -q XDG_CONFIG_DIRS; and echo $XDG_CONFIG_DIRS; or echo /etc/xdg)
    set -Ux XDG_CONFIG_HOME (set -q XDG_CONFIG_HOME; and echo $XDG_CONFIG_HOME; or echo $HOME/.config)
    set -Ux XDG_DATA_DIRS (set -q XDG_DATA_DIRS; and echo $XDG_DATA_DIRS; or echo /usr/local/share:/usr/share)
    set -Ux XDG_DATA_HOME (set -q XDG_DATA_HOME; and echo $XDG_DATA_HOME; or echo $HOME/.local/share)
    set -Ux XDG_RUNTIME_DIR (set -q XDG_RUNTIME_DIR; and echo $XDG_RUNTIME_DIR; or echo /run/user/(id -u))
    set -Ux XDG_STATE_HOME (set -q XDG_STATE_HOME; and echo $XDG_STATE_HOME; or echo $HOME/.local/state)

end
