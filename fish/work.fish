#!/usr/bin/env fish

if ! status is-interactive
    exit
end

# work
set -l infra
if test -d $HOME/work/infra
    set infra $HOME/work/infra
else if test -d $HOME/work-gitlab/infra
    set infra $HOME/work-gitlab/infra
end
if set -q infra; and test -f $infra/shell/fish.fish
    source $infra/shell/fish.fish
end
