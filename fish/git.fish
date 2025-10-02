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
    function __git_branch_delete
        git branch --delete --force $argv
    end

    # checkout
    function gco
        __git_checkout $argv
    end
    function __git_checkout
        argparse d/delete e/exit -- $argv; or return $status
        set -l target $argv[1]
        set -l original (current-branch); or return $status
        git checkout $target
        __git_pull_force
        if test -n "$_flag_delete"
            __git_branch_delete $original
        end
        if test -n "$_flag_exit"
            exit
        end
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

    # pull
    function gpl
        __git_pull_force $argv
    end
    function __git_pull_force
        git pull --force $argv
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

    # remote
    function remote-name
        git remote get-url origin
    end
    function __remote_is
        if remote-name | grep -q $argv[1]
            return 0
        else
            return 1
        end
    end
    function __remote_is_github
        __remote_is github
    end
    function __remote_is_gitlab
        __remote_is gitlab
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
        set -l args
        if test -z "$_flag_title"; and test -z "$_flag_body"; and test -z "$_flag_num"
            set branch dev
            set title (__auto_msg)
            set body .
        end
        git checkout -b $branch origin/master; or return $status
        git commit --allow-empty --message="$(__auto_msg)" --no-verify; or return $status
        __gh_create $args

    end

    # github/gitlab
    function ghc
        if test (count $argv) -eq 1; and __remote_is_github
            __github_create_or_edit -t $argv[1] -b .
        else if test (count $argv) -eq 2; and __remote_is_github
            __github_create_or_edit -t $argv[1] -b $argv[2]
        else if test (count $argv) -eq 1; and __remote_is_gitlab
            __gitlab_create_or_update -t $argv[1] -d .
        else if test (count $argv) -eq 2; and __remote_is_gitlab
            __gitlab_create_or_update -t $argv[1] -d $argv[2]
        else
            echo "Invalid call to 'ghc'"; and return 1
        end
    end
    function ghm
        __github_or_gitlab_merge
    end
    function ghmd
        __github_or_gitlab_merge -d
    end
    function ghme
        __github_or_gitlab_merge -e
    end
    function ghmx
        __github_or_gitlab_merge -d -e
    end
    function __github_or_gitlab_merge
        if __remote_is_github
            __github_merge $argv
        else if __remote_is_github
            __gitlab_merge $argv
        else
            echo "Invalid remote; got '$(remote-name)'"; and return 1
        end
    end

    # utilities
    function __auto_msg
        echo (date "+%Y-%m-%d %H:%M:%S (%a)") " >" (hostname) " >" $USER
    end
    function __clean_branch_name
        echo $argv[1] | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g' \
            | sed -E 's/^-+|-+$//g' | cut -c1-80
    end
end

if status --is-interactive; and type -q gh
    function __github_create_or_edit
        argparse t/title= b/body= -- $argv; or return $status
        set -l action
        if __github_exists
            set action edit
        else
            set action create
        end
        set -l args
        if test -n "$_flag_title"
            set args $args --title=$_flag_title
        end
        if test -n "$_flag_body"
            set args $args --body=$_flag_body
        end
        gh pr $action $args
    end

    function __github_exists
        set -l branch (current-branch); or return $status
        set -l num (gh pr list --head=$branch --json number --jq '. | length'); or return $status
        if test "$num" -eq 1
            return 0
        else
            return 1
        end
    end

    function __github_merge
        argparse d/delete e/exit -- $argv; or return $status
        if not __github_exists
            echo "'__github_merge' could not find an open PR for '$(current-branch)'"; and return 1
        end
        set -l start (date +%s)
        gh pr merge --auto --delete-branch --squash; or return $status
        while __github_merging
            set -l elapsed (math (date +%s) - $start)
            echo "$(repo_name)/$(current-branch) is still merging... ($elapsed s)"
            sleep 1
        end
        __git_checkout $argv
    end

    function __github_merging
        set -l branch (current-branch); or return $status
        if test (gh pr view --json state | jq -r .state) != OPEN
            return 1
        end
        set -l repo (gh repo view --json nameWithOwner -q .nameWithOwner)
        if gh api repos/$repo/branches/$branch >/dev/null
            return 0
        else
            return 1
        end
    end

    function __github_view
        if gh pr ready
            gh pr view -w
        else
            echo "'__github_view' could not find an open PR for $(current-branch)"; and return 1
        end
    end
end

if status --is-interactive; and type -q glab
    function __gitlab_create_or_update
        argparse t/title= d/description= -- $argv; or return $status
        set -l action
        set -l args
        if __gitlab_mr_exists
            set action update
            set args $args (__gitlab_mr_num)
        else
            set action create
            set args $args --push --remove-source-branch --squash-before-merge
        end
        if test -n "$_flag_title"
            set args $args --title=$_flag_title
        end
        if test -n "$_flag_description"
            set args $args --description=$_flag_description
        end
        gh mr $action $args
    end

    function __gitlab_mr_exists
    end

    if type -q jq
        function __gitlab_mr_json
            set -l branch (__current_branch); or return $status
            set -l json (glab mr list --output=json --source-branch=$branch); or return $status
            set -l num (printf "%s" "$json" | jq length); or return $status
            if test $num -eq 0
                echo "'__gitlab_mr_json' expected an MR for '$branch'; got none"; and return 1
            else if test $num -eq 1
                printf "%s" "$json" | jq '.[0]' | jq
            else
                echo "'__gitlab_mr_json' expected a unique MR for '$branch'; got $num"; and return 1
            end
        end
    end
end
