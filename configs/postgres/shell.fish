#!/usr/bin/env fish

#### postgresql@18 (interactive & non-interactive) ############################

if command -q brew; and brew --prefix postgresql@18 >/dev/null 2>&1; and test -d (brew --prefix postgresql@18)/bin
    fish_add_path (brew --prefix postgresql@18)/bin
end

#### interactive only #########################################################

if not status is-interactive
    exit
end
