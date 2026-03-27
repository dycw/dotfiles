#!/usr/bin/env fish

#### local (interactive & non-interactive) ####################################

if test -d /Applications/Tailscale.app/Contents/MacOS
    fish_add_path /Applications/Tailscale.app/Contents/MacOS
end

#### interactive only #########################################################

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
    if type -q tailscale
        tailscale status
    else if type -q Tailscale
        Tailscale status
    else if type -q docker
        docker exec --interactive tailscale tailscale status
    else
        echo "'ts' expected 'tailscale', 'Tailscale' or 'docker' to be available; got neither" >&2; and return 1
    end
end

function ts-exit-node
    if type -q tailscale
        tailscale set --exit-node=qrt-nanode
    else if type -q Tailscale
        Tailscale set --exit-node=qrt-nanode
    else if type -q docker
        docker exec --interactive tailscale tailscale set --exit-node=qrt-nanode
    else
        echo "'ts-exit-node' expected 'tailscale', 'Tailscale' or 'docker' to be available; got neither" >&2; and return 1
    end
end

function ts-no-exit-node
    if type -q tailscale
        tailscale set --exit-node=
    else if type -q Tailscale
        Tailscale set --exit-node=
    else if type -q docker
        docker exec --interactive tailscale tailscale set --exit-node=
    else
        echo "'ts-no-exit-node' expected 'tailscale', 'Tailscale' or 'docker' to be available; got neither" >&2; and return 1
    end
end

function wts
    if type -q tailscale
        watch --color --differences --interval=1 -- tailscale status
    else if type -q Tailscale
        watch --color --differences --interval=1 -- Tailscale status
    else if type -q docker
        docker exec --interactive tailscale watch --color --differences --interval=1 -- tailscale status
    else
        echo "'wts' expected 'tailscale', 'Tailscale' or 'docker' to be available; got neither" >&2; and return 1
    end
end
