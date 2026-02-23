#!/usr/bin/env fish

if not status is-interactive
    exit
end

#### fish #####################################################################

fish_vi_key_bindings

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
