# xdg
set -Ux XDG_BIN_HOME (set -q XDG_BIN_HOME; and echo $XDG_BIN_HOME; or echo $HOME/.local/bin)
set -Ux XDG_CACHE_HOME (set -q XDG_CACHE_HOME; and echo $XDG_CACHE_HOME; or echo $HOME/.cache)
set -Ux XDG_CONFIG_DIRS (set -q XDG_CONFIG_DIRS; and echo $XDG_CONFIG_DIRS; or echo /etc/xdg)
set -Ux XDG_CONFIG_HOME (set -q XDG_CONFIG_HOME; and echo $XDG_CONFIG_HOME; or echo $HOME/.config)
set -Ux XDG_DATA_DIRS (set -q XDG_DATA_DIRS; and echo $XDG_DATA_DIRS; or echo /usr/local/share:/usr/share)
set -Ux XDG_DATA_HOME (set -q XDG_DATA_HOME; and echo $XDG_DATA_HOME; or echo $HOME/.local/share)
set -Ux XDG_RUNTIME_DIR (set -q XDG_RUNTIME_DIR; and echo $XDG_RUNTIME_DIR; or echo /run/user/(id -u))
set -Ux XDG_STATE_HOME (set -q XDG_STATE_HOME; and echo $XDG_STATE_HOME; or echo $HOME/.local/state)

if status is-interactive
    # Commands to run in interactive sessions can go here

    # bat
    if type -q batcat
        function cat
            batcat $argv
        end
        function catp
            batcat --plain $argv
        end
    end

    # cd
    function cd-config
        cd "$XDG_CONFIG_HOME"
    end
    function cd-df
        cd "$HOME/dotfiles"
    end

    # eza
    if type -q eza
        function l
            __eza --git-ignore $argv
        end
        function la
            __eza $argv
        end
        function ll
            __eza $argv
        end
        function __eza
            eza --all --classify=always --git --group --group-directories-first --header --long --time-style=long-iso $argv
        end
    end

    # fish
    fish_vi_key_bindings

    function fish_config
        edit "$XDG_CONFIG_HOME/fish/config.fish"
    end

    # fzf
    if type -q fzf
        fzf --fish | source
    end

    # neovim
    function cd-nvim-plugins
        cd "$XDG_CONFIG_HOME/nvim/lua/plugins"
    end
    function clean-neovim
        set dirs $XDG_STATE_HOME $XDG_DATA_HOME $XDG_STATE_HOME
        for dir in $dirs
            set nvim "$dir/nvim"
            echo "Cleaning '$nvim'..."
            rm -rf $nvim
        end
    end
    if type -q nvim
        set -gx EDITOR nvim
        set -gx VISUAL nvim

        function n
            nvim $argv
        end
    end

    # vim
    if type -q vim
        if not type -q nvim
            set -gx EDITOR vim
            set -gx VISUAL vim
        end

        function v
            vim $argv
        end
    end
end
