#!/usr/bin/env fish

#### local (interactive & non-interactive) ####################################

if test -d $HOME/.cargo/bin
    fish_add_path $HOME/.cargo/bin
end

#### interactive only #########################################################

if not status is-interactive
    exit
end
