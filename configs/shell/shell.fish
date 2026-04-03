#!/usr/bin/env fish

#### local (interactive & non-interactive) ####################################

if test -d $HOME/.local/bin
    fish_add_path $HOME/.local/bin
end

#### XDG (interactive & non-interactive) ######################################

set -gx XDG_BIN_HOME (set -q XDG_BIN_HOME; and echo $XDG_BIN_HOME; or echo $HOME/.local/bin)
set -gx XDG_CACHE_HOME (set -q XDG_CACHE_HOME; and echo $XDG_CACHE_HOME; or echo $HOME/.cache)
set -gx XDG_CONFIG_DIRS (set -q XDG_CONFIG_DIRS; and echo $XDG_CONFIG_DIRS; or echo /etc/xdg)
set -gx XDG_CONFIG_HOME (set -q XDG_CONFIG_HOME; and echo $XDG_CONFIG_HOME; or echo $HOME/.config)
set -gx XDG_DATA_DIRS (set -q XDG_DATA_DIRS; and echo $XDG_DATA_DIRS; or echo /usr/local/share:/usr/share)
set -gx XDG_DATA_HOME (set -q XDG_DATA_HOME; and echo $XDG_DATA_HOME; or echo $HOME/.local/share)
set -gx XDG_RUNTIME_DIR (set -q XDG_RUNTIME_DIR; and echo $XDG_RUNTIME_DIR; or echo /run/user/(id -u))
set -gx XDG_STATE_HOME (set -q XDG_STATE_HOME; and echo $XDG_STATE_HOME; or echo $HOME/.local/state)

#### interactive only #########################################################

if not status is-interactive
    exit
end

#### cd #######################################################################

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
    cd $PATH_DOTFILES
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

#### chmod ####################################################################

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

#### chown ####################################################################

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

#### config ###################################################################

function edit-shell
    $EDITOR $PATH_DOTFILES/configs/shell/shell.fish
end

#### cp #######################################################################

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

#### dns ######################################################################

function flush
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder
end

#### env ######################################################################

function eg
    if test (count $argv) -lt 1
        echo "'eg' expected [1..) arguments PATTERN; got $(count $argv)" >&2; and return 1
    end
    env | sort | grep -i $argv
end

#### editor ###################################################################

if type -q nvim
    set -gx EDITOR nvim
    set -gx VISUAL nvim
else if type -q vim
    set -gx EDITOR vim
    set -gx VISUAL vim
else if type -q vi
    set -gx EDITOR vi
    set -gx VISUAL vi
else if type -q nano
    set -gx EDITOR nano
    set -gx VISUAL nano
end

#### path dotfiles ############################################################

set -l script_dir (dirname -- (realpath -- (status filename)))
set -gx PATH_DOTFILES (realpath -- "$script_dir/../..")

#### swap files ###############################################################

for swap in $HOME/.mode.sw*
    command rm -v $swap
end

#### git ######################################################################

function yield-git-repos
    set -l dir $argv[-1]
    for dir in */
        if test -d "$dir/.git"
            set abs (realpath -- "$dir")
            echo $abs
        end
    end
end

#### lsof #####################################################################

function check-port
    if test (count $argv) -lt 1
        echo "'check-port' expected [1..) argument PORT; got $(count $argv)" >&2; and return 1
    end
    lsof -i :$argv[1]
end

#### mkdir ####################################################################

function mkdir
    command mkdir -p $argv
end

#### mv #######################################################################

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

#### networking ###############################################################

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

#### ncmli ####################################################################

function spoof-mac-address
    set -l name (nmcli connection show --active | awk '$3=="wifi"{print $1}')
    function rb
        od -An -N1 -tu1 /dev/urandom | tr -d ' '
    end
    set -l first (math "2 + 2 * ($(rb) % 127)")
    set -l mac (printf '%02X:%02X:%02X:%02X:%02X:%02X' $first (rb) (rb) (rb) (rb) (rb))
    nmcli connection modify "$name" 802-11-wireless.cloned-mac-address "$mac"
    nmcli connection down "$name"
    nmcli connection up "$name"
end

#### ping #####################################################################

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

#### rm #######################################################################

function rm
    if contains -- .git $argv
        read -P "Are you sure you want to remove '.git'? (y/N) " reply
        switch $reply
            case y Y
                # continue
            case '*'
                echo "Exiting..." >&2; and return 1
                return 1
        end
    end
    command rm -frv $argv
end

function unlink
    for arg in $argv
        command unlink $arg
    end
end

#### ssh ######################################################################

function add-known-host
    if test (count $argv) -eq 0
        echo "'add-known-host' expected [1..2] arguments HOST PORT; got $(count $argv)" >&2; and return 1
    end
    set -l host $argv[1]
    if test (count $argv) -ge 2
        set -l port $argv[2]
        ssh-keygen -R "[$host]:$port"
        __ssh_keyscan $host -p $port
    else
        ssh-keygen -R $host
        __ssh_keyscan $host
    end
end

function edit-authorized-keys
    $EDITOR $HOME/.ssh/authorized_keys
end

function edit-known-hosts
    $EDITOR $HOME/.ssh/known_hosts
end

function edit-ssh-config
    $EDITOR $HOME/.ssh/config
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

function ssh-auto
    if test (count $argv) -lt 1
        echo "'ssh-auto' expected [1..] arguments DESTINATION; got $(count $argv)" >&2; and return 1
    end
    argparse r/root -- $argv; or return $status
    set -l destination $argv[1]
    set -l args $destination
    if test -n "$_flag_root"
        set args $args --root
    end
    if not __ssh_strict $args
        set -l parts (string split -m1 @ $destination)
        set -l host $parts[2]
        ssh-keygen -R $host
        __ssh_keyscan $host
        __ssh_strict $args
    end
end

function ssh-debian-13
    ssh -p 2222 derek@localhost
end

function __ssh_keyscan
    if test (count $argv) -lt 1
        echo "'__ssh_keyscan' expected [1..] arguments HOST; got $(count $argv)" >&2; and return 1
    end
    argparse p/port= -- $argv; or return $status
    set -l args -t ed25519
    if test -n "$_flag_port"
        set args $args -p "$_flag_port"
    end
    set args $args $argv[1]
    set -l tmp (mktemp)
    ssh-keyscan $args -q >>~/.ssh/known_hosts 2>$tmp
    set -l result $status
    if test $result -eq 0
        return
    end
    if grep -q "illegal option -- q" $tmp
        ssh-keyscan $args >>~/.ssh/known_hosts
    else
        cat $tmp >&2
        rm -f $tmp
        return $result
    end
    rm -f $tmp
end

function __ssh_strict
    if test (count $argv) -lt 1
        echo "'__ssh_strict' expected [1..] arguments DESTINATION; got $(count $argv)" >&2; and return 1
    end
    argparse r/root -- $argv; or return $status
    set -l args
    set -l destination $argv[1]
    if test -n "$_flag_root"
        set args $args -t $destination 'sudo -i'
    else
        set args $args $destination
    end
    ssh -o HostKeyAlgorithms=ssh-ed25519 -o StrictHostKeyChecking=yes $args
end

#### tail #####################################################################

function tf
    tail -F --verbose $argv
end

#### touch ####################################################################

function touch
    for file in $argv
        mkdir -p (dirname $file); or exit $status
        command touch $file; or exit $status
    end
end
