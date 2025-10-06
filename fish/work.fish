#!/usr/bin/env fish

if ! status is-interactive
    exit
end

# cd
if test (hostname) = DW-Mac
    function cdg
        cd $HOME/work-gitlab
    end
end
# git
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

# mount
function mount-drives
    if test (count $argv) -eq 0
        echo "'mount-drives' expected [1..) arguments SUBNET; got $(count $argv)" >&2; and return 1
    end
    set -l subnet $argv[1]
    set -l dir /mnt/qrt-$subnet
    set -l pool_name
    set -l dataset_name
    switch $subnet
        case main
            set pool_name mypool
            set dataset_name mydataset
        case test
            set pool_name pool-test
            set dataset_name dataset-test
        case '*'
            # default case
            echo "Invalid subnet; got '$subnet'" >&2; and return 1
    end
    sudo apt -y install nfs-common
    sudo mkdir -p $dir
    sudo mount -t nfs truenas.$subnet:/mnt/$pool_name/$dataset_name $dir
end

# work
if test -f $HOME/work/infra/shell/fish.fish
    source $HOME/work/infra/shell/fish.fish
end
