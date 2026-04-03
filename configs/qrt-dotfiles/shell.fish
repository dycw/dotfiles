#!/usr/bin/env fish

if not status is-interactive
    exit
end

###############################################################################

for base in $HOME/work $HOME/work/derek
    set dotfiles "$base/qrt-dotfiles"
    if test -d "$dotfiles"
        set fish "$dotfiles/fish/config.fish"
        if test -f $fish
            source $fish
        end
        set yaml "$dotfiles/tea/config.yml"
        if test -f $yaml
            ln -sf "$yaml" ~/.config/tea/config.yml
        end
    end
end
