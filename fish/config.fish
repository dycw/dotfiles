#!/usr/bin/env fish

if ! status is-interactive
    exit
end

# asciinema
if type -q asciinema
    function asciinema-record
        set -l dir
        if test -d $HOME/Dropbox/Screenshots
            set dir $HOME/Dropbox/Screenshots
        else
            set dir (pwd)
        end
        set -l now (date -u +"%Y-%m-%dT%H-%M-%S-UTC")
        set -l path_tmp $dir/$now.asciinema
        asciinema record $path_tmp
        if type -q agg
            agg $path_tmp $dir/$now.gif
            rm $path_tmp
        end
    end
end

# bat
if type -q bat
    function cat
        bat $argv
    end
    function catp
        bat --style=plain $argv
    end
end

# batwatch
if type -q batwatch
    function bw
        batwatch -n0.5 $argv
    end
end

# bottom
function bottom-toml
    $EDITOR $HOME/dotfiles/bottom/bottom.toml
end

# bump-my-version
if type -q bump-my-version
    function bump-patch
        bump-my-version bump patch
    end
    function bump-minor
        bump-my-version bump minor
    end
    function bump-major
        bump-my-version bump major
    end
    function bump-set
        if test (count $argv) -lt 1
            echo "'bump-set' expected [1..) arguments VERSION; got $(count $argv)" >&2; and return 1
        end
        while true
            if bump-my-version replace --new-version $argv[1]
                return
            end
            sleep 2
        end
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
    eval $(direnv export fish); or return $status
    cd $current; or return $status
    eval $(direnv export fish)
end
function cdp
    set -l dir $HOME/personal
    command mkdir -p $dir
    cd $dir
end
function cdw
    set -l dir $HOME/work
    command mkdir -p $dir
    cd $dir
end

# chmod
function chmod-files
    if test (count $argv) -lt 1
        echo "'chmod-files' expected [1..) arguments MODE; got $(count $argv)" >&2; and return 1
    end
    find . -type f -print0 | xargs -0 chmod $argv[1]
end
function chmod-dirs
    if test (count $argv) -lt 1
        echo "'chmod-dirs' expected [1..) arguments MODE; got $(count $argv)" >&2; and return 1
    end
    find . -type d -print0 | xargs -0 chmod $argv[1]
end

# chown
function chown-files
    if test (count $argv) -lt 1
        echo "'chown-files' expected [1..) arguments OWNER; got $(count $argv)" >&2; and return 1
    end
    find . -type f -exec chown $argv[1] {} \;
end
function chown-dirs
    if test (count $argv) -lt 1
        echo "'chown-dirs' expected [1..) arguments OWNER; got $(count $argv)" >&2; and return 1
    end
    find . -type d -exec chown $argv[1] {} \;
end

# cp
function cp
    if test (count $argv) -lt 2
        echo "'cp' expected [2..) arguments SOURCE ... TARGET; got $(count $argv)" >&2; and return 1
    end
    set -l target $argv[-1]
    set -l mkdir_target
    if test (count $argv) -eq 2; and not string match -q '*/' -- $target
        set mkdir_target $(dirname $target)
    else
        set mkdir_target $target
    end
    command mkdir -p $mkdir_target
    command cp -frv $argv
end

# curl
if type -q curl
    function curl-sh
        if test (count $argv) -lt 1
            echo "'curl-sh' expected [1..) arguments URL; got $(count $argv)" >&2; and return 1
        end
        curl -fsSL $argv[1] | sh -s -- $argv[2..]
    end
    function curl-ip
        curl api.ipify.org
    end
end

# direnv
if type -q direnv
    function dea
        direnv allow .
    end
end

# docker
if type -q docker
    function dco
        docker container prune --force
        docker container ls --all --size
    end
    function dim
        docker image prune --all --force
        docker images --all
    end
    function dps
        docker container prune --force
        docker ps --all --size
    end
    function wdps
        watch --color --differences --interval=1 -- \
            docker container prune --force && docker ps --all --size
    end
end

# dns
function dns-refresh
    sudo dscacheutil -flushcache; or return $status
    sudo killall -HUP mDNSResponder
end

# env
function eg
    if test (count $argv) -lt 1
        echo "'eg' expected [1..) arguments PATTERN; got $(count $argv)" >&2; and return 1
    end
    env | sort | grep -i $argv
end

# eza
if type -q eza
    function l
        la --git-ignore $argv
    end
    function la
        eza --all --classify=always --git --group --group-directories-first \
            --header --long --time-style=long-iso $argv
    end
    function wl
        watch --color --differences --interval=1 -- \
            eza --all --classify=always --color=always --git --group \
            --group-directories-first --header --long --reverse \
            --sort=modified --time-style=long-iso $argv
    end
end

# fd
if type -q fd
    function fdd
        __fd_base directory $argv
    end
    function fdf
        __fd_base file $argv
    end
    function __fd_base
        if test (count $argv) -lt 1
            echo "'__fd_base' expected [1..) arguments TYPE; got $(count $argv)" >&2; and return 1
        end
        fd --hidden --type=$argv[1] $argv[2..]
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
        echo "Reloading $file..."
        source $file
    end
    if set -q INFRA_FISH_CONFIG; and test -f $INFRA_FISH_CONFIG
        echo "Reloading $INFRA_FISH_CONFIG..."
        source $INFRA_FISH_CONFIG
    end
end

# fzf
if type -q fzf
    set fzf_fd_opts --hidden
    set fzf_history_time_format '%Y-%m-%d %H:%M:%S (%a)'
end

# ghostty
function ghostty-config
    $EDITOR $HOME/dotfiles/ghostty/config
end

# hypothesis
function hypothesis-ci
    export HYPOTHESIS_PROFILE=ci
end
function hypothesis-default
    export HYPOTHESIS_PROFILE=default
end
function hypothesis-dev
    export HYPOTHESIS_PROFILE=dev
end

# ipython
function coverage
    open .coverage/html/index.html
end
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

# lsof
function check-port
    if test (count $argv) -lt 1
        echo "'check-port' expected [1..) argument PORT; got $(count $argv)" >&2; and return 1
    end
    lsof -i :$argv[1]
end

# mac
if test (uname) = Darwin
    function sleep-display
        pmset displaysleepnow
    end
end
# mkdir
function mkdir
    command mkdir -p $argv
end

# mode
for swap in $HOME/.mode.sw*
    command rm -v $swap
end

# mv
function mv
    if test (count $argv) -lt 2
        echo "'mv' expected [2..) arguments SOURCE ... TARGET; got $(count $argv)" >&2; and return 1
    end
    set -l target $argv[-1]
    set -l mkdir_target
    if test (count $argv) -eq 2; and not string match -q '*/' -- $target
        set mkdir_target $(dirname $target)
    else
        set mkdir_target $target
    end
    command mkdir -p $mkdir_target
    command mv -fv $argv
end

# linode
if type -q uv
    function linode-cli
        uv tool run linode-cli $argv
    end
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
function plugins-dial
    $EDITOR $HOME/dotfiles/nvim/lua/plugins/dial.nvim.lua
end
function snippets-python
    $EDITOR $HOME/dotfiles/nvim/snippets/python.json
end
if type -q nvim
    function n
        nvim $argv
    end
end

# networking
function resolv-conf
    if test (id -u) -eq 0
        chattr -i /etc/resolv.conf || true
        $EDITOR /etc/resolv.conf
        chattr +i /etc/resolv.conf || true
    else
        sudo chattr -i /etc/resolv.conf || true
        sudo $EDITOR /etc/resolv.conf
        sudo chattr +i /etc/resolv.conf || true
    end
end
function watch-resolv-conf
    watch --color --differences --interval=1 -- cat /etc/resolv.conf
end

# ping
function ping-ts
    argparse c/count= i/interval= w/deadline= -- $argv; or return $status
    set -l args
    if test -n "$_flag_count"
        set args $args -c "$_flag_count"
    end
    if test -n "$_flag_interval"
        set args $args -i "$_flag_interval"
    else
        set args $args -i 2
    end
    if test -n "$_flag_deadline"
        set args $args -W "$_flag_deadline"
    else
        set args $args -W 2
    end
    if test (count $argv) -lt 1
        echo "'ping-ts' expected [1..) arguments ... DESTINATION; got $(count $argv)" >&2; and return 1
    end
    set -l destination $argv[-1]
    ping -O $args $argv | while read pong
        echo "[$(date "+%Y-%m-%d %H:%M:%S")/$destination] $pong"
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
    function pca-force
        rm -rf "$HOME/.cache/pre-commit-hooks"
        pre-commit run --all-files
    end
    function pcau
        pre-commit autoupdate --jobs=10
        pre-commit run --all-files
    end
    function pci
        pre-commit install
    end
    function pcui
        pre-commit uninstall
    end
end

# protonvpn
if type -q uv
    function protonvpn
        uv tool run --from protonvpn-cli protonvpn $argv
        # plan = VPN plus
    end
end

# pyright
function pyr
    __pyright $argv
end
function pyrightconfig
    __edit_ancestor pyrightconfig.json
end
if type -q watchexec
    function wpyr
        set -l cmd "cd $(pwd); pyright"
        watchexec --exts json --exts py --exts toml --exts yaml --shell bash -- $cmd
    end
end
function __pyright
    if type -q pyright
        pyright .
    else if type -q uv
        set -l args
        if test -f .venv/bin/python
            set args $args --pythonpath .venv/bin/python
        end
        uv tool run pyright $args .
    else
        echo "'__pyright' expected 'pyright' or 'uv' to be available; got neither" >&2; and return 1
    end
end

# pyright + pytest
function pyrt
    __pyright $argv; or return $status
    pytest --numprocesses auto $argv
end
function pyrtf
    set -l n 5
    while true
        if type -q pyright; or type -q uv
            while not __pyright $argv
                sleep $n
            end
        else
            echo "'pyrtf' expected 'pyright' to be available" >&2; and return 1
        end
        sleep $n
        if type -q pytest
            while not pytest --numprocesses auto $argv
                sleep $n
            end
        else
            echo "'pyrtf' expected 'pytest' to be available" >&2; and return 1
        end
        sleep $n
    end
end

# pytest
function pyt
    __pytest $argv
end
function pytf
    __pytest --looponfail $argv
end
function pytfk
    if test (count $argv) -lt 1
        echo "'pytfk' expected [1..) arguments EXPRESSION; got $(count $argv)" >&2; and return 1
    end
    __pytest --looponfail -k $argv
end
function pytfn
    __pytest --looponfail --numprocesses auto $argv
end
function pytfnr
    __pytest --force-regen --looponfail --numprocesses auto $argv
end
function pytfnx
    __pytest -x --looponfail --numprocesses auto $argv
end
function pytfr
    __pytest --force-regen --looponfail $argv
end
function pytfxk
    if test (count $argv) -lt 1
        echo "'pytfxk' expected [1..) arguments EXPRESSION; got $(count $argv)" >&2; and return 1
    end
    __pytest --exitfirst --looponfail -k $argv
end
function pytk
    if test (count $argv) -lt 1
        echo "'pytk' expected [1..) arguments EXPRESSION; got $(count $argv)" >&2; and return 1
    end
    __pytest -k $argv
end
function pytn
    __pytest --numprocesses auto $argv
end
function pytnr
    __pytest --force-regen --numprocesses auto $argv
end
function pytnx
    __pytest --exitfirst --numprocesses auto $argv
end
function pytp
    __pytest --pdb $argv
end
function pytpk
    if test (count $argv) -lt 1
        echo "'pytpk' expected [1..) arguments EXPRESSION; got $(count $argv)" >&2; and return 1
    end
    __pytest --pdb -k $argv
end
function pytpx
    __pytest --exitfirst --pdb $argv
end
function pytpxk
    if test (count $argv) -lt 1
        echo "'pytpxk' expected [1..) arguments EXPRESSION; got $(count $argv)" >&2; and return 1
    end
    __pytest --exitfirst --pdb -k $argv
end
function pytr
    __pytest --force-regen $argv
end
function pytx
    __pytest --exitfirst $argv
end
function pkytx
    __pytest --exitfirst -k $argv
end
function pytfx
    __pytest --exitfirst --looponfail $argv
end
function __pytest
    pytest --color=yes $argv
end

# python
function p3
    python3 $argv
end
function pyproject
    __edit_ancestor pyproject.toml
end

# rm
function rm
    command rm -frv $argv
end
function unlink
    for arg in $argv
        command unlink $arg
    end
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
function add-known-host
    if test (count $argv) -eq 0
        echo "'ssh-auto' expected [1..2] arguments HOST PORT; got $(count $argv)" >&2; and return 1
    end
    set -l host $argv[1]
    if test (count $argv) -ge 2
        set -l port $argv[2]
        ssh-keygen -R "[$host]:$port"
        ssh-keyscan -p $port $host >>~/.ssh/known_hosts
    else
        ssh-keygen -R $host
        ssh-keyscan $host >>~/.ssh/known_hosts
    end
end
function authorized-keys
    $EDITOR $HOME/.ssh/authorized_keys
end
function generate-ssh-key
    argparse f/filename= -- $argv; or return $status
    set -l filename_use
    if test -n "$_flag_filename"
        set filename_use $_flag_filename
    else
        set filename_use id_ed25519
    end
    ssh-keygen -C '' -f $filename_use -P '' -t ed25519 $args
end
function known-hosts
    $EDITOR $HOME/.ssh/known_hosts
end
function ssh-config
    $EDITOR $HOME/.ssh/config
end
function ssh-auto
    if test (count $argv) -lt 1
        echo "'ssh-auto' expected [1..] arguments DESTINATION; got $(count $argv)" >&2; and return 1
    end
    set -l destination $argv[1]
    if not __ssh_strict $destination
        set -l parts (string split -m1 @ $destination)
        set -l host $parts[2]
        ssh-keygen -R $host
        ssh-keyscan -q -t ed25519 $host >>~/.ssh/known_hosts
        __ssh_strict $destination
    end
end
function __ssh_strict
    if test (count $argv) -lt 1
        echo "'__ssh_strict' expected [1..] arguments DESTINATION; got $(count $argv)" >&2; and return 1
    end
    ssh -o HostKeyAlgorithms=ssh-ed25519 -o StrictHostKeyChecking=yes $argv
end

# ssl
function ssl-mac
    ssh -N -L 8888:localhost:8888 derekwan@dw-mac
end

# sops
if type -q sops
    function sops-new
        if test (count $argv) -lt 2
            echo "'sops-new' expected [2..] arguments AGE FILE; got $(count $argv)" >&2; and return 1
        end
        sops edit --age $argv[1] $argv[2]
    end
end

# starship
function starship-toml
    $EDITOR $HOME/dotfiles/starship/starship.toml
end

# tail
function tf
    tail -F --verbose $argv
end

# tailscale
if type -q tailscale; or type -q docker
    function ssh-dw-mac
        ssh-auto derekwan@(ts-ip dw-mac)
    end
    function ssh-rh-mac
        ssh-auto derekwan@(ts-ip rh-mac)
    end
    function ssh-swift
        ssh-auto derek@(ts-ip dw-swift)
    end
    function ts
        set -l args
        if not type -q tailscale; and type -q docker
            set args $args docker exec --interactive tailscale
        end
        set args $args tailscale status
        $args
    end
    function ts-exit-node
        set -l args
        if not type -q tailscale; and type -q docker
            set args $args docker exec --interactive tailscale
        end
        set args $args tailscale set --exit-node=qrt-nanode
        $args
    end
    function ts-ip
        if test (count $argv) -lt 1
            echo "'ts-ip' expected [1..) arguments HOSTNAME; got $(count $argv)" >&2; and return 1
        end
        set -l args
        if not type -q tailscale; and type -q docker
            set args $args docker exec --interactive tailscale
        end
        set args $args tailscale status --json
        $args 2>/dev/null \
            | jq .Peer \
            | jq values[] \
            | jq --arg hostname $argv[1] 'select(.HostName | ascii_downcase == ($hostname | ascii_downcase))' \
            | jq .TailscaleIPs[] \
            | jq 'select(contains("."))' \
            | jq --slurp --raw-output first
    end
    function ts-no-exit-node
        set -l args
        if not type -q tailscale; and type -q docker
            set args $args docker exec --interactive tailscale
        end
        set args $args tailscale set --exit-node=
        $args
    end
    function wts
        set -l args
        if not type -q tailscale; and type -q docker
            set args $args docker exec --interactive tailscale
        end
        set args $args watch --color --differences --interval=1 -- tailscale status
        $args
    end
end

# tmux
function tmux-conf
    $EDITOR $HOME/dotfiles/tmux/tmux.conf.local
end
if type -q tmux
    function ta
        if test (count $argv) -eq 0
            set -l count (tmux ls | wc -l)
            if test "$count" -eq 0
                tmux new
                return
            else if test "$count" -eq 1
                tmux attach
            else
                echo "'ta' expected [0..1] arguments SESSION; got $(count $argv)" >&2; and return 1
            end
        else
            tmux attach -t $argv[1]
        end
    end
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
        uv run --with jupyterlab --with jupyterlab-vim $args jupyter lab
    end
    function pyc
        uv tool run pyclean --debris=all .
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
    function uvpo
        set -l paths '.project.dependencies[]?' '.["dependency-groups"].*[]?' '.project."optional-dependencies".*[]?'
        set -l all_current (uv pip list --color=never | string collect)
        set -l outdated (uv pip list --color=never --outdated | string collect)
        set -l dep_and_vers
        set -l name
        set -l ver
        for p in $paths
            for dep in (yq -r $p pyproject.toml)
                if test -n "$dep"
                    set name (echo $dep | sed 's/\[.*\]//
        s/[ ,<>=!].*//')
                    set ver (string match -r '\d+\.\d+\.\d+' $dep)
                    if test -n "$ver"
                        set dep_and_vers $dep_and_vers "$name | $ver"
                    end
                end
            end
        end
        set -l dep_and_vers (printf "%s\n" $dep_and_vers | sort -u)
        set -l num_deps (count $dep_and_vers)
        printf "Checking %d dependencies...\n" $num_deps
        for dep_ver in $dep_and_vers
            __uvpo_core $all_current $outdated $dep_ver
        end
        printf "Finished checking %d dependencies\n" $num_deps
    end
    function __uvpo_core
        if test (count $argv) -lt 3
            echo "'__uvpo_core' accepts [3..) arguments ALL_CURRENT OUTDATED DEP_VER; got $(count $argv)" >&2; and return 1
        end
        set -l all_current $argv[1]
        set -l outdated $argv[2]
        set -l dep_ver (string split " | " $argv[3])
        set -l name (string trim $dep_ver[1])
        set -l pyproject (string trim $dep_ver[2])
        set -l current (printf "%s\n" $all_current \
            | string match -r "^$name\s+\d+\.\d+\.\d+" | awk '{print $2}')
        set -l latest (printf "%s\n" $outdated \
            | string match -r "^$name\s+\d+\.\d+\.\d+\s+\d+\.\d+\.\d+" \
            | awk '{print $3}')
        set -l latest_print
        if test -n "$latest"
            set latest_print latest
        else
            set latest_print -
        end
        if test "$current" != "$pyproject"
            printf "%-20s %-10s %-10s %-10s\n" $name $pyproject $current $latest_print
        else if test -n "$latest"; and test "$latest" != "$pyproject"
            printf "%-20s %-10s %-10s %-10s\n" $name $pyproject $current $latest
        end
    end
    function uvrp
        uv run python -m $argv
    end
    function uvrpd
        uv run python -m pdb --command continue -m $argv
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
        echo "'edit_ancestor' expected [1..) arguments FILENAME; got $(count $argv)" >&2; and return 1
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
    echo "'edit_ancestor' did not find a file named '$file' in any parent directory" >&2; and return 1
end
