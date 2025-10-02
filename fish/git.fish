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
    function gbd
        if test (count $argv) -eq 0
            __git_branch_fzf_local | while read branch
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
    function __git_branch_delete
        git branch --delete --force $argv
    end
    function __git_branch_fzf_local
        git branch --format=%(refname:short) | fzf --multi
    end
    function __git_branch_fzf_remote
        argparse m/multi -- $argv; or return $status
        set -l args
        if test -n "$_flag_multi"
            set args $args --multi
        end
        git branch --color=never --remotes | awk '!/->/' | fzf $args \
            | sed -E 's|^[[:space:]]*origin/||'
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
    function __git_commit_until
        argparse m/message= n/no-verify -- $argv; or return $status
        set -l args
        if test -n "$_flag_message"
            set args $args --message $_flag_message
        end
        if test -n "$_flag_no_verify"
            set args $args --no-verify
        end
        for i in (seq 0 4) # @fish-lsp-disable
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
        argparse f/force n/no-verify w/web e/exit -- $argv; or return $status
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

    # remote
    function remote-name
        git remote get-url origin
    end
    function repo-name
        basename -s .git $(remote-name)
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
    function gc
        __git_all $argv
    end
    function gcf
        __git_all $argv --force
    end
    function gcn
        __git_all $argv --no-verify
    end
    function gcfn
        __git_all $argv --force --no-verify
    end
    function gcw
        __git_all $argv --web
    end
    function gcfw
        __git_all $argv --force --web
    end
    function gcnw
        __git_all $argv --no-verify --web
    end
    function gcfnw
        __git_all $argv --force --no-verify --web
    end
    function gce
        __git_all $argv --exit
    end
    function gcfe
        __git_all $argv --force --exit
    end
    function gcne
        __git_all $argv --no-verify --exit
    end
    function gcfne
        __git_all $argv --force --no-verify --exit
    end
    function gcm
        __git_all $argv --merge
    end
    function gcfm
        __git_all $argv --force --merge
    end
    function gcnm
        __git_all $argv --no-verify --merge
    end
    function gcfnm
        __git_all $argv --force --no-verify --merge
    end
    function gcx
        __git_all $argv --merge --exit
    end
    function gcfx
        __git_all $argv --force --merge --exit
    end
    function gcnx
        __git_all $argv --no-verify --merge --exit
    end
    function gcfnx
        __git_all $argv --force --no-verify --merge --exit
    end
    function gac
        __git_all $argv --add
    end
    function gacf
        __git_all $argv --add --force
    end
    function gacn
        __git_all $argv --add --no-verify
    end
    function gacfn
        __git_all $argv --add --force --no-verify
    end
    function gacw
        __git_all $argv --add --web
    end
    function gacfw
        __git_all $argv --add --force --web
    end
    function gacnw
        __git_all $argv --add --no-verify --web
    end
    function gacfnw
        __git_all $argv --add --force --no-verify --web
    end
    function gace
        __git_all $argv --add --exit
    end
    function gacfe
        __git_all $argv --add --force --exit
    end
    function gacne
        __git_all $argv --add --no-verify --exit
    end
    function gacfne
        __git_all $argv --add --force --no-verify --exit
    end
    function gacm
        __git_all $argv --add --merge
    end
    function gacfm
        __git_all $argv --add --force --merge
    end
    function gacnm
        __git_all $argv --add --no-verify --merge
    end
    function gacfnm
        __git_all $argv --add --force --no-verify --merge
    end
    function gacx
        __git_all $argv --add --merge --exit
    end
    function gacfx
        __git_all $argv --add --force --merge --exit
    end
    function gacnx
        __git_all $argv --add --no-verify --merge --exit
    end
    function gacfnx
        __git_all $argv --add --force --no-verify --merge --exit
    end
    function __git_all
        argparse a/add n/no-verify f/force w/web e/exit m/merge -- $argv; or return $status
        if test -n "$_flag_add"
            ga $argv; or return $status
        end
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
            __github_or_gitlab_merge --delete --exit
        end
    end
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
            echo "Invalid call to 'ghc'" >&2; and return 1
        end
    end
    function ghm
        __github_or_gitlab_merge
    end
    function ghmd
        __github_or_gitlab_merge --delete
    end
    function ghme
        __github_or_gitlab_merge --exit
    end
    function __github_or_gitlab_merge
        argparse d/delete e/exit -- $argv; or return $status
        set -l args
        if test -n "$_flag_delete"
            set args $args --delete
        end
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

    function __github_merge
        argparse d/delete e/exit -- $argv; or return $status
        if not __github_exists
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
            set args $args --delete --exit
        else if test -n "$_flag_delete"
            set args $args --delete
        end
        __git_checkout $args
    end

    function __github_view
        if gh pr ready
            gh pr view -w
        else
            echo "'__github_view' could not find an open PR for $(current-branch)" >&2; and return 1
        end
    end

end

if status --is-interactive; and type -q gh; and type -q jq
    function __github_exists
        set -l branch (current-branch); or return $status
        set -l num (gh pr list --head=$branch --json number --jq '. | length'); or return $status
        if test $num -eq 0
            echo "'__github_exists' expected a PR for '$branch'; got none" >&2; and return 1
        else if test $num -eq 1
            return 0
        else
            echo "'__github_exists' expected a unique PR for '$branch'; got $num" >&2; and return 1
        end
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
end

if status --is-interactive; and type -q glab; and type -q jq
    function __gitlab_mr_json
        set -l branch (__current_branch); or return $status
        set -l json (glab mr list --output=json --source-branch=$branch); or return $status
        set -l num (printf "%s" "$json" | jq length); or return $status
        if test $num -eq 0
            echo "'__gitlab_mr_json' expected an MR for '$branch'; got none" >&2; and return 1
        else if test $num -eq 1
            printf "%s" "$json" | jq '.[0]' | jq
        else
            echo "'__gitlab_mr_json' expected a unique MR for '$branch'; got $num" >&2; and return 1
        end
    end
end
