#!/usr/bin/env fish

#### node (interactive & non-interactive) #####################################

if command -q brew; and brew --prefix node >/dev/null 2>&1; and test -d (brew --prefix node)/bin
    fish_add_path (brew --prefix node)/bin
end

#### interactive only #########################################################

if not status is-interactive
    exit
end
