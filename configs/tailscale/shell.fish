#!/usr/bin/env fish

if not status is-interactive
    exit
end

#### auth key #################################################################

if set -q XDG_CONFIG_HOME
    export TAILSCALE_AUTH_KEY=$XDG_CONFIG_HOME/tailscale/auth-key.txt
else
    export TAILSCALE_AUTH_KEY=$HOME/.config/tailscale/auth-key.txt
end

#### ssh #####################################################################

function ssh-dw-mac
    ssh-auto derekwan@dw-mac.tail.net
end

function ssh-dw-swift
    ssh-auto derek@dw-swift.tail.net
end

function ssh-rh-mac
    ssh-auto derekwan@rh-mac.tail.net
end

function ssh-rh-macbook
    ssh-auto derekwan@rh-macbook.tail.net
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
