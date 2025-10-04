#!/usr/bin/env fish

if ! status is-interactive
    exit
end

if type -q git
    function fish-git
        $EDITOR $HOME/dotfiles/fish/git.fish
    end
    function git-ignore
        $EDITOR $(repo-root)/pyproject.toml
    end

    # add
    function ga
        __git_add $argv
    end
    function gaf
        __git_add $argv --force
    end
    function gap
        git add --all --patch $argv
    end
    function __git_add
        argparse force -- $argv; or return $status
        set -l args
        if test (count $argv) -eq 0
            set args $args --all
        else
            set args $args $argv
        end
        if test -n "$_flag_force"
            set args $args --force
        end
        git add $args
    end

    # branch
    function gb
        git branch --all --list --sort=-committerdate --verbose $argv
    end
    function gbd
        if test (count $argv) -eq 0
            __git_branch_fzf_local --multi | while read branch
                __git_branch_delete $branch
            end
        else
            for branch in $argv
                __git_branch_delete $branch
            end
        end
    end
    function gbdr
        __git_fetch_and_purge; or echo $status
        if test (count $argv) -eq 0
            __git_branch_fzf_remote --multi | xargs -r -I{} git push --delete origin "{}"
        else
            git push --delete origin $argv
        end
    end
    function gbm
        if test (count $argv) -lt 1
            echo "'gbm' expected [1..) arguments BRANCH; got $(count $argv)" >&2; and return 1
        end
        git branch -m $argv
    end
    function __git_branch_delete
        git branch --delete --force $argv
    end
    function __git_branch_fzf_local
        argparse multi -- $argv; or return $status
        set -l args
        if test -n "$_flag_multi"
            set args $args --multi
        end
        git branch --format='%(refname:short)' | fzf $args
    end
    function __git_branch_fzf_remote
        argparse multi -- $argv; or return $status
        set -l args
        if test -n "$_flag_multi"
            set args $args --multi
        end
        git branch --color=never --remotes | awk '!/- >/' | fzf $args \
            | sed -E 's|^[[:space:]]*origin/||'
    end
    function __git_branch_purge_local
        git branch -vv | awk '/: gone]/{print $1}' | xargs -r git branch -D
    end

    # checkout
    function gcb
        set -l args
        if test (count $argv) -eq 0
        else if test (count $argv) -eq 1
            set args $args --title $argv[1]
        else if test (count $argv) -eq 2
            set args $args --title $argv[1] --num $argv[2]
        else if test (count $argv) -eq 3
            set args $args --title $argv[1] --num $argv[2] --part
        else
            echo "'gcb' expected [0..3] arguments TITLE NUM PART; got $(count $argv)" >&2; and return 1
        end
        __git_checkout_open $args
    end
    function gcbr
        set -l branch
        if test (count $argv) -eq 0
            set branch (__git_branch_fzf_remote)
        else if test (count $argv) -eq 1
            set branch $argv[1]
        else
            echo "'gcbt' expected [0..1] arguments BRANCH; got "(count $argv) >&2; and return 1
        end
        git checkout -b $branch -t origin/$branch
    end
    function gco
        set -l branch
        if test (count $argv) -eq 0
            set branch (__git_branch_fzf_local)
        else
            set branch $argv[1]
        end
        git checkout $branch
    end
    function gcf
        if test (count $argv) -eq 0
            git checkout -- .
        else
            if __is_valid_ref $argv[1]
                __git_fetch_and_purge; or return $status
                git checkout $argv[1] -- $argv[2..-1]
            else
                git checkout -- $argv
            end
        end
    end
    function gcfm
        __git_fetch_and_purge; or return $status
        git checkout origin/master -- $argv
    end
    function gm
        __git_checkout_close master
    end
    function gmd
        __git_checkout_close master --delete
    end
    function gmx
        __git_checkout_close master --delete --exit
    end
    function __git_checkout_open
        argparse title= num= part -- $argv; or return $status
        __git_fetch_and_purge; or return $status
        set -l branch
        if test -z "$_flag_title"; and test -z "$_flag_num"
            set branch dev
        else if test -n "$_flag_title"; and test -z "$_flag_num"
            set branch (__clean_branch_name $_flag_title)
        else if test -z "$_flag_title"; and test -n "$_flag_num"
            set branch $_flag_num
        else
            set branch "$_flag_num-$(__clean_branch_name $_flag_title)"
        end
        git checkout -b $branch origin/master; or return $status
        git commit --allow-empty --message="$(__auto_msg)" --no-verify; or return $status
        __git_push --no-verify; or return $status
        set -l title
        if test -n "$_flag_title"
            set title $_flag_title
        else
            set title (__auto_msg)
        end
        set -l args
        if test -n "$_flag_num"
            if test -n "$_flag_part"
                set args $args "Part of $_flag_num"
            else
                set args $args "Closes $_flag_num"
            end
        end
        __github_or_gitlab_create --title $title $args
    end

    function __git_checkout_close
        if test (count $argv) -lt 1
            echo "'__git_checkout_close' expected [1..) arguments TARGET; got $(count $argv)" >&2; and return 1
        end
        argparse delete exit -- $argv; or return $status
        set -l target $argv[1]
        set -l original (current-branch); or return $status
        git checkout $target; or return $status
        __git_pull_force; or return $status
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
        if test (count $argv) -lt 1
            echo "'gcl' expected [1..2) arguments REPO DIR; got $(count $argv)" >&2; and return 1
        end
        set -l args
        if test (count $argv) -ge 2
            set args $args --dir $argv[2]
        end
        __git_clone --repo $argv[1] $args
    end
    function __git_clone
        argparse repo= dir= -- $argv; or return $status
        set -l dir
        if test -n "$_flag_dir"
            set dir $_flag_dir
        else
            set dir (basename (string replace -r '\.git$' '' -- $_flag_repo))
        end
        git clone --recurse-submodules $_flag_repo $dir; or return $status
        set -l current (pwd)
        cd $dir
        if type -q pre-commit
            pre-commit install; or return $status
        end
        if type -q direnv
            direnv allow .
        end
        cd $current
    end

    # commit
    function __git_commit
        if git diff --quiet; and git diff --cached --quiet
            return 0
        end
        argparse message= no-verify -- $argv; or return $status
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
    function __git_commit_until
        argparse message= no-verify -- $argv; or return $status
        set -l args
        if test -n "$_flag_message"
            set args $args --message $_flag_message
        end
        if test -n "$_flag_no_verify"
            set args $args --no-verify
        end
        for i in (seq 0 2) # @fish-lsp-disable
            ga $argv; or return $status
            if __git_commit $args
                return 0
            end
        end
        return 1
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
        git fetch --all --force --prune --prune-tags --recurse-submodules=yes --tags __git_branch_purge_local
    end

    # log
    function gl
        set -l args
        if test (count $argv) -eq 0
            set args $args -n 20
        else if string match -qr '^[0-9]+$' -- $argv[1]; and test $argv[1] -gt 0
            set args $args -n $argv[1]
        end
        __git_log $args
    end
    function __git_log
        argparse n= -- $argv; or return $status
        set -l args
        if test -n $_flag_n
            set args $args --max-count=$_flag_n
        end
        git log --abbrev-commit --decorate=short \
            --pretty='format:%C(red)%h%C(reset) | %C(yellow)%d%C(reset) | %s | %Cgreen%cr%C(reset)' \
            $args
    end

    # mv
    function gmv
        git mv $argv
    end

    # pull
    function gpl
        __git_pull_force $argv
    end
    function __git_pull_force
        __git_branch_purge_local; or return $status
        git pull --all --ff-only --force --prune --tags $argv
    end

    # push
    function gp
        __git_push
    end
    function gpf
        __git_push --force
    end
    function gpn
        __git_push --no-verify
    end
    function gpfn
        __git_push --force --no-verify
    end
    function gpw
        __git_push --web
    end
    function gpfw
        __git_push --force --web
    end
    function gpnw
        __git_push --no-verify --web
    end
    function gpfnw
        __git_push --force --no-verify --web
    end
    function gpe
        __git_push --exit
    end
    function gpfe
        __git_push --force --exit
    end
    function gpne
        __git_push --no-verify --exit
    end
    function gpfne
        __git_push --force --no-verify --exit
    end
    function gpx
        __git_push --web --exit
    end
    function gpfx
        __git_push --force --web --exit
    end
    function gpnx
        __git_push --no-verify --web --exit
    end
    function gpfnx
        __git_push --force --no-verify --web --exit
    end
    function __git_push
        argparse force no-verify web exit -- $argv; or return $status
        set -l args
        if test -n "$_flag_force"
            set args $args --force
        end
        set args $args --set-upstream origin (current-branch)
        if test -n "$_flag_no_verify"
            set args $args --no-verify
        end
        git push $args; or return $status
        if test -n "$_flag_web"
            gitweb; or return $status
        end
        if test -n "$_flag_exit"
            exit
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
    function grbs
        git rebase --skip $argv
    end

    # remote
    function gre
        git remote -v
    end
    function remote-name
        git remote get-url origin
    end
    function repo-name
        basename -s .git $(remote-name)
    end
    function __remote_is
        if test (count $argv) -lt 1
            echo "'__remote_is' expected [1..) arguments REMOTE; got $(count $argv)" >&2; and return 1
        end
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
    function gr
        git reset $argv
    end
    function grhom
        git reset --hard origin/master $argv
    end
    function grp
        git reset --patch $argv
    end
    function gsq
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
        __git_rm $argv
    end
    function grmc
        __git_rm $argv --cached
    end
    function __git_rm
        git rm -rf $argv
    end

    # show-ref
    function __is_valid_ref
        if test (count $argv) -lt 1
            echo "'__is_valid_ref' expected [1..) arguments REF; got $(count $argv)" >&2; and return 1
        end
        set -l ref $argv[1]
        git show-ref --verify --quiet refs/heads/$ref; or git show-ref --verify --quiet refs/remotes/$ref; or git show-ref --verify --quiet refs/tags/$ref; or git rev-parse --verify --quiet $ref >/dev/null
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
    function wg
        watch --color --interval 2 --no-title --no-wrap -- '
            echo "==== status ==================================================================="
            git -c color.ui=always status --short
            if ! git diff --quiet; then
                printf "\n==== diff =====================================================================\n"
                git -c color.ui=always diff --stat
            fi
            if ! git diff origin/master --quiet; then
                printf "\n==== diff origin/master =======================================================\n"
                git -c color.ui=always diff origin/master --stat
            fi
            printf "\n==== github ==================================================================="
            gh pr status
        '
    end

    # submodule
    function gsu
        git submodule update --init --recursive; or return $status
        git submodule foreach --recursive '
            git checkout -- . &&
            git checkout master &&
            git pull --ff-only
        '
    end

    # tag
    function gta
        if test (math (count $argv) % 2) -ne 0
            echo "'gta' accepts an even number of arguments; got (count $argv)" >&2; and return 1
        end
        set -l tag
        set -l sha
        while test (count $argv) -gt 0
            set tag $argv[1]
            set sha $argv[2]
            git tag -a "$tag" "$sha" -m "$tag"; or return $status
            git push --set-upstream origin --tags; or return $status
            set argv $argv[3..-1]
        end
        __git_log -n 20
    end

    function gtd
        git tag --delete $argv; or return $status
        git push --delete origin $argv; or return $status
        __git_log -n 20
    end

    # all
    function gg
        __git_all $argv
    end
    function ggf
        __git_all $argv --force
    end
    function ggn
        __git_all $argv --no-verify
    end
    function ggfn
        __git_all $argv --force --no-verify
    end
    function ggw
        __git_all $argv --web
    end
    function ggfw
        __git_all $argv --force --web
    end
    function ggnw
        __git_all $argv --no-verify --web
    end
    function ggfnw
        __git_all $argv --force --no-verify --web
    end
    function gge
        __git_all $argv --exit
    end
    function ggfe
        __git_all $argv --force --exit
    end
    function ggne
        __git_all $argv --no-verify --exit
    end
    function ggfne
        __git_all $argv --force --no-verify --exit
    end
    function ggm
        __git_all $argv --merge
    end
    function ggfm
        __git_all $argv --force --merge
    end
    function ggnm
        __git_all $argv --no-verify --merge
    end
    function ggfnm
        __git_all $argv --force --no-verify --merge
    end
    function ggx
        __git_all $argv --merge --exit
    end
    function ggfx
        __git_all $argv --force --merge --exit
    end
    function ggnx
        __git_all $argv --no-verify --merge --exit
    end
    function ggfnx
        __git_all $argv --force --no-verify --merge --exit
    end
    #
    function ggc
        if test (count $argv) -lt 1
            echo "'ggc' expected [1..) arguments TITLE; got $(count $argv)" >&2; and return 1
        end
        __git_all --title=$argv[1] $argv[2..]
    end
    function ggcf
        if test (count $argv) -lt 1
            echo "'ggcf' expected [1..) arguments TITLE; got $(count $argv)" >&2; and return 1
        end
        __git_all --title=$argv[1] --force $argv[2..]
    end
    function ggcn
        if test (count $argv) -lt 1
            echo "'ggcn' expected [1..) arguments TITLE; got $(count $argv)" >&2; and return 1
        end
        __git_all --title=$argv[1] --no-verify $argv[2..]
    end
    function ggcfn
        if test (count $argv) -lt 1
            echo "'ggcfn' expected [1..) arguments TITLE; got $(count $argv)" >&2; and return 1
        end
        __git_all --title=$argv[1] --force --no-verify $argv[2..]
    end
    function ggcw
        if test (count $argv) -lt 1
            echo "'ggcw' expected [1..) arguments TITLE; got $(count $argv)" >&2; and return 1
        end
        __git_all --title=$argv[1] --web $argv[2..]
    end
    function ggcfw
        if test (count $argv) -lt 1
            echo "'ggcfw' expected [1..) arguments TITLE; got $(count $argv)" >&2; and return 1
        end
        __git_all --title=$argv[1] --force --web $argv[2..]
    end
    function ggcnw
        if test (count $argv) -lt 1
            echo "'ggcnw' expected [1..) arguments TITLE; got $(count $argv)" >&2; and return 1
        end
        __git_all --title=$argv[1] --no-verify --web $argv[2..]
    end
    function ggcfnw
        if test (count $argv) -lt 1
            echo "'ggcfnw' expected [1..) arguments TITLE; got $(count $argv)" >&2; and return 1
        end
        __git_all --title=$argv[1] --force --no-verify --web $argv[2..]
    end
    function ggce
        if test (count $argv) -lt 1
            echo "'ggce' expected [1..) arguments TITLE; got $(count $argv)" >&2; and return 1
        end
        __git_all --title=$argv[1] --exit $argv[2..]
    end
    function ggcfe
        if test (count $argv) -lt 1
            echo "'ggcfe' expected [1..) arguments TITLE; got $(count $argv)" >&2; and return 1
        end
        __git_all --title=$argv[1] --force --exit $argv[2..]
    end
    function ggcne
        if test (count $argv) -lt 1
            echo "'ggcne' expected [1..) arguments TITLE; got $(count $argv)" >&2; and return 1
        end
        __git_all --title=$argv[1] --no-verify --exit $argv[2..]
    end
    function ggcfne
        if test (count $argv) -lt 1
            echo "'ggcfne' expected [1..) arguments TITLE; got $(count $argv)" >&2; and return 1
        end
        __git_all --title=$argv[1] --force --no-verify --exit $argv[2..]
    end
    function ggcm
        if test (count $argv) -lt 1
            echo "'ggcm' expected [1..) arguments TITLE; got $(count $argv)" >&2; and return 1
        end
        __git_all --title=$argv[1] --merge $argv[2..]
    end
    function ggcfm
        if test (count $argv) -lt 1
            echo "'ggcfm' expected [1..) arguments TITLE; got $(count $argv)" >&2; and return 1
        end
        __git_all --title=$argv[1] --force --merge $argv[2..]
    end
    function ggcnm
        if test (count $argv) -lt 1
            echo "'ggcnm' expected [1..) arguments TITLE; got $(count $argv)" >&2; and return 1
        end
        __git_all --title=$argv[1] --no-verify --merge $argv[2..]
    end
    function ggcfnm
        if test (count $argv) -lt 1
            echo "'ggcfnm' expected [1..) arguments TITLE; got $(count $argv)" >&2; and return 1
        end
        __git_all --title=$argv[1] --force --no-verify --merge $argv[2..]
    end
    function ggcx
        if test (count $argv) -lt 1
            echo "'ggcx' expected [1..) arguments TITLE; got $(count $argv)" >&2; and return 1
        end
        __git_all --title=$argv[1] --merge --exit $argv[2..]
    end
    function ggcfx
        if test (count $argv) -lt 1
            echo "'ggcfx' expected [1..) arguments TITLE; got $(count $argv)" >&2; and return 1
        end
        __git_all --title=$argv[1] --force --merge --exit $argv[2..]
    end
    function ggcnx
        if test (count $argv) -lt 1
            echo "'ggcnx' expected [1..) arguments TITLE; got $(count $argv)" >&2; and return 1
        end
        __git_all --title=$argv[1] --no-verify --merge --exit $argv[2..]
    end
    function ggcfnx
        if test (count $argv) -lt 1
            echo "'ggcfnx' expected [1..) arguments TITLE; got $(count $argv)" >&2; and return 1
        end
        __git_all --title=$argv[1] --force --no-verify --merge --exit $argv[2..]
    end
    function __git_all
        argparse title= num= part force no-verify web exit merge -- $argv; or return $status

        if test -n "$_flag_title"
            set -l checkout_args
            if test -n "$_flag_title"
                set checkout_args $checkout_args --title $_flag_title
            end
            if test -n "$_flag_num"
                set checkout_args $checkout_args --num $_flag_num
            end
            if test -n "$_flag_part"
                set checkout_args $checkout_args --part
            end
            __git_checkout_open $checkout_args; or return $status
        end

        set -l add_args
        if test -n "$_flag_force"
            set add_args $add_args --force
        end
        __git_add $argv $add_args; or return $status

        set -l commit_args
        if test -n "$_flag_no_verify"
            set commit_args $commit_args --no-verify
        end
        __git_commit_until $commit_args; or return $status

        set -l push_args
        if test -n "$_flag_force"
            set push_args $push_args --force
        end
        if test -n "$_flag_no_verify"
            set push_args $push_args --no-verify
        end
        if test -n "$_flag_web"
            set push_args $push_args --web
        end
        if test -n "$_flag_exit"; and test -z "$_flag_merge"
            set push_args $push_args --exit
        end
        __git_push $push_args; or return $status

        if test -n "$_flag_merge"
            set -l merge_args
            if test -n "$_flag_exit"
                set merge_args $merge_args --exit
            end
            __github_or_gitlab_merge $merge_args
        end
    end

    # github/gitlab
    function ghc
        set -l args
        if test (count $argv) -eq 0
        else if test (count $argv) -eq 1
            set args $args --title $argv[1]
        else if test (count $argv) -eq 2
            set args $args --title $argv[1] --num $argv[2]
        else
            echo "'ghc' expected [0..2] arguments TITLE NUM; got $(count $argv)" >&2; and return 1
        end
        __github_or_gitlab_create $args
    end

    function __github_or_gitlab_create
        argparse title= body= -- $argv; or return $status
        set -l args
        if test -n "$_flag_title"
            set args $args --title $_flag_title
        end
        if __remote_is_github
            if test -n "$_flag_body"
                set args $args --body $_flag_body
            end
            __github_create $args
        else if __remote_is_gitlab
            if test -n "$_flag_body"
                set args $args --description $_flag_description
            end
            __gitlab_create $args
        else
            echo "Invalid remote
got '$(remote-name)'" >&2; and return 1
        end
    end

    function ghe
        if test (count $argv) -lt 1
            echo "'ghe' expected [0..) arguments -t/--title or -b/--body; got $(count $argv)" >&2; and return 1
        end
        argparse t/title= b/body= -- $argv; or return $status
        set -l args
        if test -n "$_flag_title"
            set args $args --title $_flag_title
        end
        if __remote_is_github
            if test -n "$_flag_body"
                set args $args --body $_flag_body
            end
            __github_edit $args
        else if __remote_is_gitlab
            if test -n "$_flag_body"
                set args $args --description $_flag_description
            end
            __gitlab_update $args
        else
            echo "Invalid remote
got '$(remote-name)'" >&2; and return 1
        end
    end
    function ghm
        __github_or_gitlab_merge
    end
    function ghx
        __github_or_gitlab_merge --exit
    end
    function __github_or_gitlab_merge
        argparse exit -- $argv; or return $status
        set -l args
        if test -n "$_flag_exit"
            set args $args --exit
        end
        if __remote_is_github
            __github_merge $args
        else if __remote_is_github
            __gitlab_merge $args
        else
            echo "Invalid remote; got '$(remote-name)'" >&2; and return 1
        end
    end

    # utilities
    function __auto_msg
        echo (date "+%Y-%m-%d %H:%M:%S (%a)") " >" (hostname) " >" $USER
    end
    function __clean_branch_name
        if test (count $argv) -lt 1
            echo "'__clean_branch_name' expected [1..) arguments BRANCH; got $(count $argv)" >&2; and return 1
        end
        echo $argv[1] | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g' \
            | sed -E 's/^-+|-+$//g' | cut -c1-80
    end
end

if type -q gh
    function __github_create
        argparse title= body= -- $argv; or return $status
        set -l title
        if test -n "$_flag_title"
            set title $_flag_title
        else
            set title (__auto_msg)
        end
        set -l body
        if test -n "$_flag_body"
            set body $_flag_body
        else
            set body .
        end
        gh pr create --title $title --body $body
    end

    function __github_edit
        argparse title= body= -- $argv; or return $status
        set -l args
        if test -n "$_flag_title"
            set args $args --title $_flag_title
        end
        if test -n "$_flag_body"
            set args $args --body $_flag_body
        end
        gh pr edit $args
    end

    function __github_merge
        argparse exit -- $argv; or return $status
        if not __github_exists &>/dev/null
            echo "'__github_merge' could not find an open PR for '$(current-branch)'" >&2; and return 1
        end
        set -l start (date +%s)
        gh pr merge --auto --delete-branch --squash; or return $status
        while __github_merging
            set -l elapsed (math (date +%s) - $start)
            echo "$(repo-name)/$(current-branch) is still merging... ($elapsed s)"
            sleep 1
        end
        set -l args
        if test -n "$_flag_exit"
            set args $args --exit
        end
        __git_checkout_close master --delete $args
    end

    function __github_view
        if gh pr ready
            gh pr view -w
        else
            echo "'__github_view' could not find an open PR for $(current-branch)" >&2; and return 1
        end
    end

end

if type -q gh; and type -q jq
    function __github_exists
        set -l branch (current-branch); or return $status
        set -l num (gh pr list --head=$branch --json number --jq '. | length'); or return $status
        if test $num -eq 0
            echo "'__github_exists' expected a PR for '$branch'
got none" >&2; and return 1
        else if test $num -eq 1
            return 0
        else
            echo "'__github_exists' expected a unique PR for '$branch'
got $num" >&2; and return 1
        end
    end

    function __github_merging
        set -l branch (current-branch); or return $status
        set -l state (gh pr view --json state | jq -r .state)
        if test -z "$state" -o "$state" != OPEN
            return 1
        end
        set -l repo (gh repo view --json nameWithOwner -q .nameWithOwner)
        if gh api repos/$repo/branches/$branch >/dev/null
            return 0
        else
            return 1
        end
    end
end

if type -q glab
    function __gitlab_create
        argparse title= description= -- $argv; or return $status
        set -l args
        if test -n "$_flag_title"
            set title $_flag_title
        else
            set title (__auto_msg)
        end
        if test -n "$_flag_description"
            set description $_flag_description
        else
            set description .
        end
        gh mr create --push --remove-source-branch --squash-before-merge $args --title $title --description $description
    end

    function __gitlab_update
        argparse title= description= -- $argv; or return $status
        set -l args
        if test -n "$_flag_title"
            set args $args --title $_flag_title
        end
        if test -n "$_flag_body"
            set args $args --description $_flag_description
        end
        gh mr update (__gitlab_mr_num) $args
    end

    function __gitlab_mr_exists
    end
end

if type -q glab; and type -q jq
    function __gitlab_mr_json
        set -l branch (current-branch); or return $status
        set -l json (glab mr list --output=json --source-branch=$branch); or return $status
        set -l num (printf "%s" "$json" | jq length); or return $status
        if test $num -eq 0
            echo "'__gitlab_mr_json' expected an MR for '$branch'
got none" >&2; and return 1
        else if test $num -eq 1
            printf "%s" "$json" | jq '.[0]' | jq
        else
            echo "'__gitlab_mr_json' expected a unique MR for '$branch'
got $num" >&2; and return 1
        end
    end
end

if type -q gitweb
    function gw
        gitweb
    end
end
