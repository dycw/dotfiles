#!/usr/bin/env fish

if status is-interactive
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
    function ..
        cd ..
    end
    function ...
        cd ../..
    end
    function ....
        cd ../../..
    end
    function cdconfig
        cd $XDG_CONFIG_HOME
    end
    function cddb
        cd $HOME/Dropbox
    end
    function cddbt
        cd $HOME/Dropbox/Temporary
    end
    function cddf
        cd $HOME/dotfiles
    end
    function cddl
        cd $HOME/Downloads
    end
    function cdh
        set -l current (pwd)
        cd /; or return $status
        cd $current
    end
    function cdw
        cd $HOME/work
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

    function fish-config
        $EDITOR $XDG_CONFIG_HOME/fish/config.fish
    end
    function fish-reload
        for file in $XDG_CONFIG_HOME/fish/**/*.fish
            source $file
        end
    end

    # local
    if test -f $HOME/local.fish
        source $HOME/local.fish
    end
    if test -f $HOME/work/infra/shell/fish.fish
        source $HOME/work/infra/shell/fish.fish
    end

    # neovim
    function cd-nvim-plugins
        cd $XDG_CONFIG_HOME/nvim/lua/plugins
    end
    function clean-neovim
        set -l dirs $XDG_STATE_HOME $XDG_DATA_HOME $XDG_STATE_HOME
        for dir in $dirs
            set nvim $dir/nvim
            echo "Cleaning '$nvim'..."
            rm -rf $nvim
        end
    end
    if type -q nvim
        function n
            nvim $argv
        end
    end

    # pre-commit
    if type -q pre-commit
        function pcau
            pre-commit autoupdate
        end
        function pci
            pre-commit install
        end
        function pca
            pre-commit run --all-files
        end
    end

    # python
    function fish-config
        $EDITOR $XDG_CONFIG_HOME/fish/config.fish
    end

    # ssh
    function ssh-mac
        ssh derekwan@dw-mac
    end
    function ssh-swift
        ssh derek@dw-swift
    end

    # tailscale
    if type -q tailscale
        function ts-up
            set -l auth_key $XDG_CONFIG_HOME/tailscale/auth-key.txt
            if not test -f $auto_key
                echo "'$auto_key' does not exist"
                return 1
            end
            if not set -q TAILSCALE_LOGIN_SERVER
                echo "'\$TAILSCALE_LOGIN_SERVER' is not set"
                return 1
            end
            echo "Starting 'tailscaled' in the background..."
            sudo tailscaled &
            echo "Starting 'tailscale'..."
            sudo tailscale up --accept-dns --accept-routes --auth-key="file:$auth_key" \
                --login-server="$TAILSCALE_LOGIN_SERVER" --reset
        end
        function ts-exit-node
            sudo tailscale set --exit-node=qrt-nanode
        end
        function ts-no-exit-node
            sudo tailscale set --exit-node=
        end
    end

    # uv
    if type -q uv
        function ipy
            set -l args
            for arg in $argv
                set args $args --with $arg
            end
            uv run --with ipython $args ipython
        end
        function jl
            set -l args
            for arg in $argv
                set args $args --with $arg
            end
            uv run --with jupyterlab --with juputetlab-vim $args jupyter lab
        end
    end

    # vim
    if type -q vim
        function v
            vim $argv
        end
    end
end
