#!/usr/bin/env fish

if ! status is-interactive
    exit
end

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

# env
function eg
    if test (count $argv) -lt 1
        echo "'eg' expected [1..) arguments PATTERN; got "(count $argv) >&2; and return 1
    end
    env | sort | grep -i $argv
end

# eza
if type -q eza
    function l
        la --git-ignore $argv
    end
    function la
        eza --all --classify=always --git --group --group-directories-first --header --long --time-style=long-iso $argv
    end
end

# fish
fish_vi_key_bindings

function fish-config
    $EDITOR $HOME/dotfiles/fish/config.fish
end
function fish-env
    $EDITOR $HOME/dotfiles/fish/env.fish
end
function fish-reload
    for file in $XDG_CONFIG_HOME/fish/**/*.fish
        source $file
    end
end

# ghostty
function ghostty-config
    $EDITOR $HOME/dotfiles/ghostty/config
end

# ipython
function ipython-startup
    $EDITOR $HOME/dotfiles/ipython/startup.py
end

# just
function justfile
    __edit_ancestor justfile
end

# local
if test -f $HOME/local.fish
    source $HOME/local.fish
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
function snippets-python
    $EDITOR $HOME/dotfiles/nvim/snippets/python.json
end
if type -q nvim
    function n
        nvim $argv
    end
end

# pre-commit
function pre-commit-config
    __edit_ancestor .pre-commit-config.yaml
end
if type -q pre-commit
    function pca
        pre-commit run --all-files
    end
    function pcau
        pre-commit autoupdate
    end
    function pci
        pre-commit install
    end
    function pcui
        pre-commit uninstall
    end
end

# pyright
function pyr
    pyright $argv
end
function pyrightconfig
    __edit_ancestor pyrightconfig.json
end

# pytest
function pyt
    __pytest $argv
end
function pytf
    __pytest -f $argv
end
function pytfk
    if test (count $argv) -lt 1
        echo "'pytfk' expected [1..) arguments EXPRESSION; got "(count $argv) >&2; and return 1
    end
    __pytest -fk $argv
end
function pytfxk
    if test (count $argv) -lt 1
        echo "'pytfxk' expected [1..) arguments EXPRESSION; got "(count $argv) >&2; and return 1
    end
    __pytest -fk $argv
end
function pytk
    if test (count $argv) -lt 1
        echo "'pytk' expected [1..) arguments FILENAME; got "(count $argv) >&2; and return 1
    end
    __pytest -k $argv
end
function pytx
    __pytest -x $argv
end
function pytfx
    __pytest -fx $argv
end
function __pytest
    pytest --color=yes $argv
end

# python
function pyproject
    __edit_ancestor pyproject.toml
end

# rm
function rm
    command rm -rf $argv
end

# ruff
function ruff-toml
    __edit_ancestor ruff.toml
end
if type -q ruff
    function rw
        ruff check -w $argv
    end
end

# rust
function cargo-toml
    __edit_ancestor cargo.toml
end

# ssh
function ssh-mac
    ssh derekwan@dw-mac
end
function ssh-swift
    ssh derek@dw-swift
end

# ssl
function ssl-mac
    ssh -N -L 8888:localhost:8888 derekwan@dw-mac
end

# starship
function starship-toml
    $EDITOR $HOME/dotfiles/starship/starship.toml
end

# tailscale
if type -q tailscale; and type -q tailscaled
    function ts-up
        set -l auth_key $XDG_CONFIG_HOME/tailscale/auth-key.txt
        if not test -f $auto_key
            echo "'$auto_key' does not exist" >&2; and return 1
        end
        if not set -q TAILSCALE_LOGIN_SERVER
            echo "'\$TAILSCALE_LOGIN_SERVER' is not set" >&2; and return 1
        end
        echo "Starting tailscaled in the background..."
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

# tmux
function tmux-conf
    $EDITOR $HOME/dotfiles/tmux/tmux.conf.local
end
if type -q tmux
    function tmux-reload
        tmux source-file $XDG_CONFIG_HOME/tmux/tmux.conf
    end
end

# touch
function touch
    for file in $argv
        mkdir -p (dirname $file); or exit $status
        command touch $file; or exit $status
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
    function uvl
        if test (count $argv) -eq 0
            uv pip list
        else
            uv pip list | grep -i $argv[1]
        end
    end
    function uvo
        uv pip list --outdated
    end
end

# vim
if type -q vim
    function v
        vim $argv
    end
end

# wezterm
function wezterm-lua
    $EDITOR $HOME/dotfiles/wezterm/wezterm.lua
end

# private
function __edit_ancestor
    if test (count $argv) -lt 1
        echo "'edit_ancestor' expected [1..) arguments FILENAME; got "(count $argv) >&2; and return 1
    end
    set file $argv[1]
    set dir (pwd)
    while test $dir != /
        if test -f $dir/$file
            $EDITOR $dir/$file
            return 0
        end
        set dir (dirname $dir)
    end
    echo "'editancestor' did not find a file named '$file' in any parent directory" >&2; and return 1
end
