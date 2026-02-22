#!/usr/bin/env fish

#### npm global (interactive & non-interactive) ###############################

if test -d $HOME/.npm-global/bin
    fish_add_path $HOME/.npm-global/bin
end

#### interactive only #########################################################

if not status is-interactive
    exit
end

#### interactive only #########################################################

if set -q XDG_CONFIG_HOME
    export NVM_DIR=$XDG_CONFIG_HOME/nvm
else
    export NVM_DIR=$HOME/.config/nvm
end
