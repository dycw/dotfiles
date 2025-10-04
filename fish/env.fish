if status --is-interactive
    # homebrew
    if test -d /opt/homebrew/bin
        fish_add_path /opt/homebrew/bin
        if type -q brew
            brew shellenv | source

            # node
            if test -d /opt/homebrew/opt/node/bin
                fish_add_path /opt/homebrew/opt/node/bin
            end

            # node
            if test -d /opt/homebrew/opt/node/bin
                fish_add_path /opt/homebrew/opt/node/bin
            end

            # postgresql@17
            if test -d /opt/homebrew/opt/postgresql@17/bin
                fish_add_path /opt/homebrew/opt/postgresql@17/bin
            end
        end

        # node
    end

    # direnv
    if type -q direnv
        direnv hook fish | source
    end

    # editor
    if type -q nvim
        set -gx EDITOR nvim
        set -gx VISUAL nvim
    else if type -q nvim
        set -gx EDITOR vim
        set -gx VISUAL vim
    else
        set -gx EDITOR vi
        set -gx VISUAL vi
    end

    # fzf
    if type -q fzf
        fzf --fish | source

        if type -q fd
            # https://github.com/junegunn/fzf#respecting-gitignore
            export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
            export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
            export FZF_ALT_C_COMMAND='fd --type d --strip-cwd-prefix --hidden --follow --exclude .git --exclude .venv'
        end

    end

    # gitlab
    export GITLAB_HOME=$HOME/gitlab-docker

    # pytest
    export PY_COLORS=1

    # ripgrep
    if test -f $XDG_CONFIG_HOME/ripgrep/ripgreprc
        export RIPGREP_CONFIG_PATH=$XDG_CONFIG_HOME/ripgrep/ripgreprc
    end

    # rust
    if test -d $HOME/.cargo/bin
        fish_add_path $HOME/.cargo/bin
    end

    # starship
    if type -q starship
        starship init fish | source
    end

    # XDG
    set -gx XDG_BIN_HOME (set -q XDG_BIN_HOME; and echo $XDG_BIN_HOME; or echo $HOME/.local/bin)
    set -gx XDG_CACHE_HOME (set -q XDG_CACHE_HOME; and echo $XDG_CACHE_HOME; or echo $HOME/.cache)
    set -gx XDG_CONFIG_DIRS (set -q XDG_CONFIG_DIRS; and echo $XDG_CONFIG_DIRS; or echo /etc/xdg)
    set -gx XDG_CONFIG_HOME (set -q XDG_CONFIG_HOME; and echo $XDG_CONFIG_HOME; or echo $HOME/.config)
    set -gx XDG_DATA_DIRS (set -q XDG_DATA_DIRS; and echo $XDG_DATA_DIRS; or echo /usr/local/share:/usr/share)
    set -gx XDG_DATA_HOME (set -q XDG_DATA_HOME; and echo $XDG_DATA_HOME; or echo $HOME/.local/share)
    set -gx XDG_RUNTIME_DIR (set -q XDG_RUNTIME_DIR; and echo $XDG_RUNTIME_DIR; or echo /run/user/(id -u))
    set -gx XDG_STATE_HOME (set -q XDG_STATE_HOME; and echo $XDG_STATE_HOME; or echo $HOME/.local/state)

    # zoxide
    if type -q zoxide
        zoxide init --cmd j fish | source
    end
end
