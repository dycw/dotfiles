#!/usr/bin/env fish

if ! status is-interactive
    exit
end

if test -f $HOME/work/infra/shell/fish.fish
    source $HOME/work/infra/shell/fish.fish
end

if type -q git
    function gclw
        if test (count $argv) -eq 0
            echo "'gclw' expected [1..) arguments REPO DIR; got $(count $argv)" >&2; and return 1
        end
        set -l args
        if test (count $argv) -ge 2
            set args $args --dir $argv[2]
        end
        __git_clone --repo ssh://git@gitlab.main:2424/qrt/$argv[1] $args
    end

end
