#!/usr/bin/env fish

if ! status is-interactive
    exit
end

# work
if test -f $HOME/work/qrt-dotfiles/fish/config.fish
    export INFRA_FISH_CONFIG=$HOME/work/qrt-dotfiles/fish/config.fish
else if test -f $HOME/infra/shell/infra.fish
    export INFRA_FISH_CONFIG=$HOME/infra/shell/infra.fish
else if test -f $HOME/work/infra/shell/infra.fish
    export INFRA_FISH_CONFIG=$HOME/work/infra/shell/infra.fish
else if test -f $HOME/work-gitlab/infra/shell/infra.fish
    export INFRA_FISH_CONFIG=$HOME/work-gitlab/infra/shell/infra.fish
end
if set -q INFRA_FISH_CONFIG; and test -f $INFRA_FISH_CONFIG
    source $INFRA_FISH_CONFIG
end
