if status --is-interactive; and type -q git
    function fish-git
        $EDITOR "$XDG_CONFIG_HOME/fish/conf.d/git.fish"
    end

    # branch
    function delete-gone-branches
        git branch -vv | awk '/: gone]/{print $1}' | xargs -r git branch -D
    end
    function gb
        git branch --all --list --sort=-committerdate --verbose $argv
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
        if test -n $_flag_message
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
    function __git_push
        argparse f/force n/no-verify a/action= -- $argv; or return
        set -l args
        if test -n $_flag_force
            set args $args --force
        end
        set args $args --set-upstream origin (current-branch)
        if test -n $_flag_no_verify
            set args $args --no-verify
        end
        git push $args; or return $status
        switch $_flag_action
            case web
                gitweb
            case exit
                exit
            case 'web+exit'
                gitweb; and exit
        end
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

    # all

    # utilities
    function __auto-msg
        echo (date "+%Y-%m-%d %H:%M:%S (%a)") ">" (hostname) ">" $USER
    end

end
