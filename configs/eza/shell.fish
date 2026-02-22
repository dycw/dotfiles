#!/usr/bin/env fish

if not status is-interactive
    exit
end

###############################################################################

function l
    if type -q eza
        la --git-ignore $argv
    else
        la $argv
    end
end

function la
    if type -q eza
        eza --all --classify=always --git --group --group-directories-first \
            --header --long --time-style=long-iso $argv
    else
        ls -ahl --color=always $argv
    end
end

if type -q eza
    function wl
        watch --color --differences --interval=1 -- \
            eza --all --classify=always --color=always --git --group \
            --group-directories-first --header --long --reverse \
            --sort=modified --time-style=long-iso $argv
    end
end
