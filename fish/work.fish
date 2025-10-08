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
function mount-shared-drive
    if test (count $argv) -eq 0
        echo "'mount-shared-drive' expected [1..) arguments SUBNET; got $(count $argv)" >&2; and return 1
    end
    set -l subnet $argv[1]
    set -l dir
    switch (uname)
        case Darwin
            set dir /Volumes/qrt-$subnet
        case Linux
            set dir /mnt/qrt-$subnet
        case *
            echo "Invalid OS; got '$(uname)'" >&2; and return 1
    end
    sudo command mkdir -p $dir
    set -l pool_name
    set -l dataset_name
    switch $subnet
        case main
            set pool_name mypool
            set dataset_name mydataset
        case test
            set pool_name pool-test
            set dataset_name dataset-test
        case *
            echo "Invalid subnet; got '$subnet'" >&2; and return 1
    end
    switch (uname)
        case Darwin
            sudo mount -t nfs -o vers=4,resvport truenas.$subnet:/mnt/$pool_name/$dataset_name $dir
        case Linux
            sudo apt -y install nfs-common
            sudo mount -t nfs truenas.$subnet:/mnt/$pool_name/$dataset_name $dir
        case *
            echo "Invalid OS; got '$(uname)'" >&2; and return 1
    end
end

# work
if test -f $HOME/work/infra/shell/fish.fish
    source $HOME/work/infra/shell/fish.fish
end
