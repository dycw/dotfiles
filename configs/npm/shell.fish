#!/usr/bin/env fish

#### local (interactive & non-interactive) ####################################

if test -d $HOME/.npm-global/bin
    fish_add_path $HOME/.npm-global/bin
end

#### interactive only #########################################################

if not status is-interactive
    exit
end
