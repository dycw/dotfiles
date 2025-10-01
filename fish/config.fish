# xdg
set -Ux XDG_CONFIG_HOME $HOME/.config
set -Ux XDG_CACHE_HOME $HOME/.cache
set -Ux XDG_DATA_HOME $HOME/.local/share
set -Ux XDG_STATE_HOME $HOME/.local/state

if status is-interactive
    # Commands to run in interactive sessions can go here

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
        edit ~/.config/fish/config.fish
    end

    # fzf
    if type -q fzf
        fzf --fish | source
    end

    # neovim
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
