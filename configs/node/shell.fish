#!/usr/bin/env fish

#### node (interactive & non-interactive) #####################################

if command -q brew; and brew --prefix node >/dev/null 2>&1; and test -d (brew --prefix node)/bin
    fish_add_path (brew --prefix node)/bin
end
if test -d $HOME/.local/share/nvm/v25.6.1/bin
    fish_add_path $HOME/.local/share/nvm/v25.6.1/bin
end

#### interactive only #########################################################

if not status is-interactive
    exit
end
