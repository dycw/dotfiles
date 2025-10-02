if status --is-interactive; and type -q git
    function fish-git
        $EDITOR $XDG_CONFIG_HOME/fish/conf.d/git.fish
    end

    # add
    function ga
        set -l args
        if test (count $argv) -eq 0
            set args .
        else
            set args $argv
        end
        git add $args
    end
    function gap
        git add --all --patch $argv
    end

    # branch
    function delete-gone-branches
        git branch -vv | awk '/: gone]/{print $1}' | xargs -r git branch -D
    end
    function gb
        git branch --all --list --sort=-committerdate --verbose $argv
    end

    # checkout
    function gco
        git checkout $argv
    end

    # cherry-pick
    function gcp
        git cherry-pick $argv
    end

    # clone
    function gcl
        git clone --recurse-submodules $argv
    end

    # commit
    function __git_commit
        if git diff --quiet; and git diff --cached --quiet
            return 0
        end
        argparse m/message= n/no-verify -- $argv; or return $status
        set -l message
        if test -n "$_flag_message"
            set message $_flag_message
        else
            set message (__auto_msg)
        end
        set -l args
        if test $_flag_no_verify
            set args $args --no-verify
        end
        git commit --message="'$message'" $args; or return $status
    end

    # diff
    function gd
        git diff $argv
    end
    function gdc
        git diff --cached $argv
    end
    function gdm
        git diff origin/master $argv
    end

    # fetch
    function gf
        __git_fetch_and_purge
    end
    function __git_fetch_and_purge
        git fetch --all --force
        delete-gone-branches
    end

    # log
    function gl
        set -l args --abbrev-commit --decorate=short --pretty='format:%C(red)%h%C(reset) | %C(yellow)%d%C(reset) | %s | %Cgreen%cr%C(reset)'
        set -l n
        if test (count $argv) -eq 0
            set n 20
        else if string match -qr '^[0-9]+$' -- $argv[1]; and test $argv[1] -gt 0
            set n $argv[1]
        end
        if set -q n
            set args $args --max-count=$n
        end
        git log $args
    end

    # mv
    function gm
        git mv $argv
    end

    # push
    function gp
        __git_push
    end
    function gpf
        __git_push -f
    end
    function gpn
        __git_push -n
    end
    function gpfn
        __git_push -f -n
    end
    function gpw
        __git_push -a=web
    end
    function gpfw
        __git_push -f -a=web
    end
    function gpnw
        __git_push -n -a=web
    end
    function gpfnw
        __git_push -f -n -a=web
    end
    function gpe
        __git_push -a=exit
    end
    function gpfe
        __git_push -f -a=exit
    end
    function gpne
        __git_push -n -a=exit
    end
    function gpfne
        __git_push -f -n -a=exit
    end
    function gpx
        __git_push -a=web+exit
    end
    function gpfx
        __git_push -f -a=web+exit
    end
    function gpnx
        __git_push -n -a=web+exit
    end
    function gpfnx
        __git_push -f -n -a=web+exit
    end
    function __git_push
        argparse f/force n/no-verify a/action= -- $argv; or return $status
        set -l args
        if test -n "$_flag_force"
            set args $args --force
        end
        set args $args --set-upstream origin (current-branch)
        if test -n "$_flag_no_verify"
            set args $args --no-verify
        end
        git push $args; or return $status
        switch $_flag_action
            case web
                gitweb
            case exit
                exit
            case web+exit
                gitweb; and exit
        end
    end

    # rebase
    function grb
        __git_fetch_and_purge; or return $status
        git rebase --strategy=recursive --strategy-option=theirs origin/master
    end
    function grba
        git rebase --abort $argv
    end
    function grbc
        git rebase --continue $argv
    end

    # reset
    function grmb
        __git_fetch_and_purge; or return $status
        git reset --soft $(git merge-base origin/master HEAD)
    end

    # rev-parse
    function cdr
        cd (repo-root)
    end
    function current-branch
        git rev-parse --abbrev-ref HEAD
    end
    function repo-root
        git rev-parse --show-toplevel
    end

    # rm
    function grm
        git rm $argv
    end

    # stash
    function gst
        git stash $argv
    end
    function gstd
        git stash drop $argv
    end
    function gstp
        git stash pop $argv
    end

    # status
    function gs
        git status $argv
    end

    # combined
    function __git_create_and_push
        argparse t/title= b/body= n/num= -- $argv; or return $status
        __git_fetch_and_purge; or return $status
        set -l branch
        set -l title
        set -l body
        if test -z "$_flag_title"; and test -z "$_flag_body"; and test -z "$_flag_num"
            set branch dev
            set title (__auto_msg)
            set body .
        end
        git checkout -b $branch origin/master; or return $status
        git commit --allow-empty --message="$(__auto_msg)" --no-verify; or return $status

    end

    # utilities
    function __auto_msg
        echo (date "+%Y-%m-%d %H:%M:%S (%a)") " >" (hostname) " >" $USER
    end

end
