#!/usr/bin/env sh
# shellcheck disable=SC2120,SC2317

# echo
echo_date() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"; }

# git
if command -v git >/dev/null 2>&1; then
    # add
    ga() {
        if [ $# -eq 0 ]; then
            git add --all
        else
            git add "$@"
        fi
    }
    gap() { git add --all --patch "$@"; }
    # all
    gac() { __git_add_commit_push 0 0 0 0 "$@"; }
    gacn() { __git_add_commit_push 1 0 0 0 "$@"; }
    gacf() { __git_add_commit_push 0 1 0 0 "$@"; }
    gacnf() { __git_add_commit_push 1 1 0 0 "$@"; }
    gacw() { __git_add_commit_push 0 0 1 0 "$@"; }
    gacnw() { __git_add_commit_push 1 0 1 0 "$@"; }
    gacfw() { __git_add_commit_push 0 1 1 0 "$@"; }
    gacnfw() { __git_add_commit_push 1 1 1 0 "$@"; }
    gacd() { __git_add_commit_push 0 0 0 1 "$@"; }
    gacnd() { __git_add_commit_push 1 0 0 1 "$@"; }
    gacfd() { __git_add_commit_push 0 1 0 1 "$@"; }
    gacnfd() { __git_add_commit_push 1 1 0 1 "$@"; }
    gacwd() { __git_add_commit_push 0 0 1 1 "$@"; }
    gacnwd() { __git_add_commit_push 1 0 1 1 "$@"; }
    gacfwd() { __git_add_commit_push 0 1 1 1 "$@"; }
    gacnfwd() { __git_add_commit_push 1 1 1 1 "$@"; }
    gace() { __git_add_commit_push 0 0 0 2 "$@"; }
    gacne() { __git_add_commit_push 1 0 0 2 "$@"; }
    gacfe() { __git_add_commit_push 0 1 0 2 "$@"; }
    gacnfe() { __git_add_commit_push 1 1 0 2 "$@"; }
    gacwe() { __git_add_commit_push 0 0 1 2 "$@"; }
    gacnwe() { __git_add_commit_push 1 0 1 2 "$@"; }
    gacfwe() { __git_add_commit_push 0 1 1 2 "$@"; }
    gacnfwe() { __git_add_commit_push 1 1 1 2 "$@"; }
    __git_add_commit_push() {
        if [ $# -le 2 ]; then
            echo_date "'__git_add_commit_push' accepts [4..) arguments; got $#" && return 1
        fi
        __gacp_no_verify="$1"
        __gacp_force="$2"
        __gacp_web="$3"
        __gacp_action="$4"
        if [ "${__gacp_action}" != 'none' ] && [ "${__gacp_action}" != 'delete' ] && [ "${__gacp_action}" != 'delete' ] && [ "${__gacp_action}" != 'delete+exit' ]; then
            echo_date "'__create_add_merge' invalid gacp_action; got '${__gacp_action}'" && return 1
        fi
        shift 4

        __gacp_count_file=0
        __gacp_count_non_file=0
        __gacp_message=""
        __gacp_file_names=""
        __gacp_file_args=""

        for arg in "$@"; do
            if [ "${__gacp_count_non_file}" -eq 0 ] && { [ -f "$arg" ] || [ -d "$arg" ]; }; then
                __gacp_file_args="${__gacp_file_args} \"$arg\""
                __gacp_file_names="${__gacp_file_names}${__gacp_file_names:+ }$arg"
                __gacp_count_file=$((__gacp_count_file + 1))
            else
                __gacp_count_non_file=$((__gacp_count_non_file + 1))
                __gacp_message="$arg"
            fi
        done

        __gacp_file_list=""
        for f in ${__gacp_file_names}; do
            __gacp_file_list="${__gacp_file_list}'${f}',"
        done
        __gacp_file_list="${__gacp_file_list%,}"
        __gacp_attempts=0

        if [ "${__gacp_count_file}" -eq 0 ] && [ "${__gacp_count_non_file}" -eq 0 ]; then
            ga
            until __git_commit_push "${__gacp_no_verify}" "" "${__gacp_force}" "${__gacp_web}" "${__gacp_action}"; do
                ga
                __gacp_attempts=$((__gacp_attempts + 1))
                if [ "${__gacp_attempts}" -ge 5 ]; then
                    return 1
                fi
            done
        elif [ "${__gacp_count_file}" -eq 0 ] && [ "${__gacp_count_non_file}" -eq 1 ]; then
            ga
            until __git_commit_push "${__gacp_no_verify}" "${__gacp_message}" "${__gacp_force}" "${__gacp_web}" "${__gacp_action}"; do
                ga
                __gacp_attempts=$((__gacp_attempts + 1))
                if [ "${__gacp_attempts}" -ge 5 ]; then
                    return 1
                fi
            done
        elif [ "${__gacp_count_file}" -ge 1 ] && [ "${__gacp_count_non_file}" -eq 0 ]; then
            eval "ga ${__gacp_file_args}"
            __git_commit_push "${__gacp_no_verify}" "" "${__gacp_force}" "${__gacp_web}" "${__gacp_action}"
        elif [ "${__gacp_count_file}" -ge 1 ] && [ "${__gacp_count_non_file}" -eq 1 ]; then
            eval "ga ${__gacp_file_args}"
            __git_commit_push "${__gacp_no_verify}" "${__gacp_message}" "${__gacp_force}" "${__gacp_web}" "${__gacp_action}"
        else
            echo_date "'__git_add_commit_push' accepts any number of files followed by [0..1] messages; got ${__gacp_count_file} file(s) ${__gacp_file_list:-'(none)'} and ${__gacp_count_non_file} message(s)" && return 1
        fi
    }
    __git_all() {
        if [ $# -le 3 ]; then
            echo_date "'__git_all' accepts [4..) arguments; got $#" && return 1
        fi
        # $1 = no-verify
        # $2 = message
        # $3 = force
        # $4 = action = {none/web/exit/web+exit/merge/merge+exit}
        __no_verify="$1"
        __message="$2"
        __force="$3"
        __action="$4"
        shift 4
        if [ "${__action}" != 'none' ] && [ "${__action}" != 'web' ] &&
            [ "${__action}" != 'exit' ] && [ "${__action}" != 'web+exit' ] &&
            [ "${__action}" != 'merge' ] && [ "${__action}" != 'merge+exit' ]; then
            echo_date "'__git_all' invalid action; got '${__action}'" && return 1
        fi
        ga "$@"
        echo "done"
        for __i in $(seq 0 4); do
            echo "${__i}"
            if __git_commit "${__no_verify}" "${__message}"; then
                break
            else
                ga "$@"
            fi
            echo_date "'__git_all' failed to commit after 5 times'" && return 1
        done
    }
    # branch
    gb() {
        if [ $# -ne 0 ]; then
            echo_date "'gb' accepts no arguments; got $#" && return 1
        fi
        git branch --all --list --sort=-committerdate --verbose
    }
    gbd() {
        if [ $# -eq 0 ]; then
            __target="$(__select_local_branch)"
        elif [ $# -eq 1 ]; then
            __target="$1"
        else
            echo_date "'gbd' accepts [0..1] arguments; got $#" && return 1
        fi
        __current="$(current_branch)" || return $?
        if [ "${__target}" != "${__current}" ] && __branch_exists "${__target}"; then
            git branch --delete --force "${__target}"
        fi
    }
    gbdr() {
        if [ $# -eq 0 ]; then
            __branch="$(__select_remote_branch)" || return $?
        elif [ $# -eq 1 ]; then
            __branch="$1"
        else
            echo_date "'gbdr' accepts [0..1] arguments; got $#" && return 1
        fi
        gf && git push --delete origin "${__branch}"
    }
    gbm() { git branch -m "$1"; }
    __delete_gone_branches() {
        if [ $# -ne 0 ]; then
            echo_date "'__delete_gone_branches' accepts no arguments; got $#" && return 1
        fi
        git branch -vv | awk '/: gone]/{print $1}' | xargs -r git branch -D
    }
    __select_local_branch() {
        if [ $# -ne 0 ]; then
            echo_date "'__select_local_branch' accepts no arguments; got $#" && return 1
        fi
        git branch --format="%(refname:short)" | fzf
    }
    __select_remote_branch() {
        if [ $# -ne 0 ]; then
            echo_date "'__select_remote_branch' accepts no arguments; got $#" && return 1
        fi
        git branch --color=never --remotes | awk '!/->/' | fzf | sed -E 's|^[[:space:]]*origin/||'
    }
    # checkout
    gcb() {
        if [ $# -eq 0 ]; then
            if ! __is_current_branch_master; then
                echo_date "'gcb' off 'master' accepts 1 argument; got $#" && return 1
            fi
            __branch='dev'
            __title="$(__git_commit_auto_msg) > ${__branch}"
            unset __num
        elif [ $# -eq 1 ]; then
            __title="$1"
            __branch="$(__to_valid_branch "${__title}")"
            unset __num
        elif [ $# -eq 2 ]; then
            __title="$1"
            __num="$2"
            __desc="$(__to_valid_branch "${__title}")"
            __branch="$2-${__desc}"
        else
            echo_date "'gcb' accepts [0..2] arguments; got $#" && return 1
        fi
        gf && git checkout -b "${__branch}" origin/master && gp &&
            __git_commit_empty_msg && gp || return $?
        if [ -z "${__num}" ]; then
            __gh_create "${__title}"
        else
            __gh_create "${__title}" "${__num}"
        fi
    }
    gcbac() {
        if [ $# -ge 3 ]; then
            echo_date "'gcbac' accepts [0..2] arguments; got $#" && return 1
        fi
        gcb "$@" && gac
    }
    gcbacm() {
        if [ $# -ge 3 ]; then
            echo_date "'gcbacm' accepts [0..2] arguments; got $#" && return 1
        fi
        gcb "$@" && gacm
    }
    gcbacd() {
        if [ $# -eq 0 ] || [ $# -ge 3 ]; then
            echo_date "'gcbacd' accepts [0..2] arguments; got $#" && return 1
        fi
        gcb "$@" && gacd
    }
    gcbace() {
        if [ $# -eq 0 ] || [ $# -ge 3 ]; then
            echo_date "'gcbace' accepts [0..2] arguments; got $#" && return 1
        fi
        gcb "$@" && gace
    }
    gcbt() {
        if [ $# -eq 0 ]; then
            __branch="$(__select_remote_branch)"
        elif [ $# -eq 1 ]; then
            __branch="$1"
        else
            echo_date "'gcbt' accepts [0..1] arguments; got $#" && return 1
        fi
        if __is_current_branch_master; then
            gf && git checkout -b "${__branch}" --track='direct'
        else
            gco master
        fi
    }
    gcm() {
        if [ $# -ne 0 ]; then
            echo_date "'gcm' accepts no arguments; got $#" && return 1
        fi
        __git_checkout_master 'none'
    }
    gcmd() {
        if [ $# -ne 0 ]; then
            echo_date "'gcmd' accepts no arguments; got $#" && return 1
        fi
        __git_checkout_master 'delete'
    }
    gcme() {
        if [ $# -ne 0 ]; then
            echo_date "'gcme' accepts no arguments; got $#" && return 1
        fi
        __git_checkout_master 'delete+exit'
    }
    gco() {
        if [ $# -eq 0 ]; then
            __target="$(__select_local_branch)" || return $?
        elif [ $# -eq 1 ]; then
            __target="$1"
        else
            echo_date "'gco' accepts [0..1] arguments; got $#" && return 1
        fi
        __current="$(current_branch)" || return $?
        if [ "${__current}" != "${__target}" ]; then
            git checkout "${__branch}"
        fi
        gpl
    }
    gcof() {
        if [ $# -eq 0 ]; then
            git checkout -- .
        else
            if __is_valid_ref "$1"; then
                __branch="$1"
                shift
                git checkout "${__branch}" -- "$@"
            else
                git checkout -- "$@"
            fi
        fi
    }
    gcofm() {
        if [ $# -eq 0 ]; then
            echo_date "'gcofm' accepts [1..] arguments; got $#" && return 1
        fi
        gcof origin/master "$@"
    }
    gcop() { git checkout --patch "$@"; }
    __git_checkout_master() {
        if [ $# -ne 1 ]; then
            echo_date "'__git_checkout_master' accepts 1 argument; got $#" && return 1
        fi
        __action="$1"
        # $1 = action = {none/delete/delete+exit}
        if [ "$1" != 'none' ] && [ "$1" != 'delete' ] && [ "$1" != 'delete+exit' ]; then
            echo_date "'__git_checkout_master' invalid action; got '$1'" && return 1
        fi
        __branch="$(current_branch)" || return $?
        gco master
        if [ "$1" = 'delete' ] || [ "$1" = 'delete+exit' ]; then
            gbd "${__branch}" || return $?
        fi
        if [ "$1" = 'delete+exit' ]; then
            exit
        fi
    }
    __to_valid_branch() {
        if [ $# -ne 1 ]; then
            echo_date "'__to_valid_branch' accepts 1 argument; got $#" && return 1
        fi
        echo "$1" |
            tr '[:upper:]' '[:lower:]' |
            sed -E 's/[^a-z0-9]+/-/g' |
            sed -E 's/^-+|-+$//g' |
            cut -c1-80
    }
    # checkout + branch
    gbr() {
        if [ $# -ne 0 ]; then
            echo_date "'gbr' accepts no arguments; got $#" && return 1
        elif __is_current_branch_master; then
            echo_date "'gbr' cannot be run on master" && return 1
        else
            __gbr_branch="$(current_branch)" || return 1
            gcof && gcm && gcb "${__gbr_branch}"
        fi
    }
    # cherry-pick
    gcp() { git cherry-pick "$@"; }
    # clone
    gcl() { git clone --recurse-submodules "$@"; }
    # commit
    __git_commit() {
        if [ $# -ne 2 ]; then
            echo_date "'__git_commit' accepts 2 arguments; got $#" && return 1
        fi
        __no_verify="$1"
        __message="$2"
        if git diff --cached --quiet && git diff --quiet; then
            return 0
        fi
        if [ "${__message}" = '' ]; then
            __message_use="$(__git_commit_auto_msg)"
        else
            __message_use="${__message}"
        fi
        if "${__no_verify}"; then
            git commit --message="${__message_use}" --no-verify
        else
            git commit --message="${__message_use}"
        fi
    }
    __git_commit_auto_msg() {
        if [ $# -ne 0 ]; then
            echo_date "'__git_commit_auto_msg' accepts no arguments; got $#" && return 1
        fi
        echo "$(date +"%Y-%m-%d %H:%M:%S (%a)") > $(hostname) > ${USER}"
    }
    __git_commit_empty_msg() {
        if [ $# -ne 0 ]; then
            echo_date "'__git_commit_empty_msg' accepts no arguments; got $#" && return 1
        fi
        git commit --allow-empty --message="$(__git_commit_auto_msg)" --no-verify
    }
    # commit + push
    gc() {
        if [ $# -ge 2 ]; then
            echo_date "'gc' accepts [0..1] arguments; got $#" && return 1
        fi
        __git_commit_push 0 "${1:-}" 0 0 0
    }
    gcn() {
        if [ $# -ge 2 ]; then
            echo_date "'gcn' accepts [0..1] arguments; got $#" && return 1
        fi
        __git_commit_push 1 "${1:-}" 0 0 0
    }
    gcf() {
        if [ $# -ge 2 ]; then
            echo_date "'gcf' accepts [0..1] arguments; got $#" && return 1
        fi
        __git_commit_push 0 "${1:-}" 1 0 0
    }
    gcnf() {
        if [ $# -ge 2 ]; then
            echo_date "'gcnf' accepts [0..1] arguments; got $#" && return 1
        fi
        __git_commit_push 1 "${1:-}" 1 0 0
    }
    gcw() {
        if [ $# -ge 2 ]; then
            echo_date "'gcw' accepts [0..1] arguments; got $#" && return 1
        fi
        __git_commit_push 0 "${1:-}" 0 1 0
    }
    gcnw() {
        if [ $# -ge 2 ]; then
            echo_date "'gcnw' accepts [0..1] arguments; got $#" && return 1
        fi
        __git_commit_push 1 "${1:-}" 0 1 0
    }
    gcfw() {
        if [ $# -ge 2 ]; then
            echo_date "'gcfw' accepts [0..1] arguments; got $#" && return 1
        fi
        __git_commit_push 0 "${1:-}" 1 1 0
    }
    gcnfw() {
        if [ $# -ge 2 ]; then
            echo_date "'gcnfw' accepts [0..1] arguments; got $#" && return 1
        fi
        __git_commit_push 1 "${1:-}" 1 1 0
    }
    gce() {
        if [ $# -ge 2 ]; then
            echo_date "'gce' accepts [0..1] arguments; got $#" && return 1
        fi
        __git_commit_push 0 "${1:-}" 0 0 1
    }
    gcne() {
        if [ $# -ge 2 ]; then
            echo_date "'gcne' accepts [0..1] arguments; got $#" && return 1
        fi
        __git_commit_push 1 "${1:-}" 0 0 1
    }
    gcfe() {
        if [ $# -ge 2 ]; then
            echo_date "'gcfe' accepts [0..1] arguments; got $#" && return 1
        fi
        __git_commit_push 0 "${1:-}" 1 0 1
    }
    gcnfe() {
        if [ $# -ge 2 ]; then
            echo_date "'gcnfe' accepts [0..1] arguments; got $#" && return 1
        fi
        __git_commit_push 1 "${1:-}" 1 0 1
    }
    gcwe() {
        if [ $# -ge 2 ]; then
            echo_date "'gcwe' accepts [0..1] arguments; got $#" && return 1
        fi
        __git_commit_push 0 "${1:-}" 0 1 1
    }
    gcnwe() {
        if [ $# -ge 2 ]; then
            echo_date "'gcnwe' accepts [0..1] arguments; got $#" && return 1
        fi
        __git_commit_push 1 "${1:-}" 0 1 1
    }
    gcfwe() {
        if [ $# -ge 2 ]; then
            echo_date "'gcfwe' accepts [0..1] arguments; got $#" && return 1
        fi
        __git_commit_push 0 "${1:-}" 1 1 1
    }
    gcnfwe() {
        if [ $# -ge 2 ]; then
            echo_date "'gcnfwe' accepts [0..1] arguments; got $#" && return 1
        fi
        __git_commit_push 1 "${1:-}" 1 1 1
    }
    __git_commit_push() {
        if [ "$#" -ne 5 ]; then
            echo_date "'__git_commit_push' accepts 5 arguments; got $#" && return 1
        fi
        # $1 = no-verify
        # $2 = message
        # $3 = force
        # $4 = action = {none/web/exit/web+exit}
        # $4 = action
        # .............................push only, push+web, push+exit, push+merge+delete, push+merge+delete+exit
        __git_commit "$1" "$2" && __git_push "$3" "$4" "$5"
    }
    # diff
    gd() { git diff "$@"; }
    gdc() { git diff --cached "$@"; }
    gdm() { git diff origin/master "$@"; }
    # fetch
    gf() {
        if [ $# -ne 0 ]; then
            echo_date "'gf' accepts no arguments; got $#" && return 1
        fi
        git fetch --all --force && __delete_gone_branches
    }
    # log
    gl() {
        if [ $# -ne 0 ]; then
            echo_date "'gl' accepts no arguments; got $#" && return 1
        fi
        git log --abbrev-commit --decorate=short --pretty=format:'%C(red)%h%C(reset) |%C(yellow)%d%C(reset) | %s | %Cgreen%cr%C(reset)'
    }
    # merge
    gma() {
        if [ $# -ne 0 ]; then
            echo_date "'gma' accepts no arguments; got $#" && return 1
        fi
        git merge --abort
    }
    # mv
    gmv() {
        if [ $# -ne 2 ]; then
            echo_date "'gmv' accepts 2 arguments; got $#" && return 1
        fi
        git mv "$1" "$2"
    }
    # pull
    gpl() {
        if [ $# -ne 0 ]; then
            echo_date "'gpl' accepts no arguments; got $#" && return 1
        fi
        git pull --force && gf
    }
    # push
    gp() {
        if [ $# -ne 0 ]; then
            echo_date "'gp' accepts no arguments; got $#" && return 1
        fi
        __git_push false false false
    }
    gpf() {
        if [ $# -ne 0 ]; then
            echo_date "'gpf' accepts no arguments; got $#" && return 1
        fi
        __git_push true false false
    }
    gpw() {
        if [ $# -ne 0 ]; then
            echo_date "'gpw' accepts no arguments; got $#" && return 1
        fi
        __git_push false true false
    }
    gpfw() {
        if [ $# -ne 0 ]; then
            echo_date "'gpfw' accepts no arguments; got $#" && return 1
        fi
        __git_push true true false
    }
    gpe() {
        if [ $# -ne 0 ]; then
            echo_date "'gpe' accepts no arguments; got $#" && return 1
        fi
        __git_push false false false
    }
    gpfe() {
        if [ $# -ne 0 ]; then
            echo_date "'gpfe' accepts no arguments; got $#" && return 1
        fi
        __git_push true false true
    }
    gpwe() {
        if [ $# -ne 0 ]; then
            echo_date "'gpwe' accepts no arguments; got $#" && return 1
        fi
        __git_push false true true
    }
    gpfwe() {
        if [ $# -ne 0 ]; then
            echo_date "'gpfwe' accepts no arguments; got $#" && return 1
        fi
        __git_push true true true
    }
    __git_push() {
        if [ $# -ne 2 ]; then
            echo_date "'__git_push' accepts 2 arguments; got $#" && return 1
        fi
        # $1 = force
        # $2 = action = {none/web/exit/web+exit}
        if [ "$2" != 'none' ] && [ "$2" != 'web' ] && [ "$2" != 'exit' ] &&
            [ "$2" != 'web+exit' ]; then
            echo_date "'__gh_push' invalid action; got '$2'" && return 1
        fi
        __git_push_current_branch "$1" || return $?
        if [ "$2" = 'none' ]; then
            :
        elif [ "$2" = 'web' ]; then
            gw
        elif [ "$2" = 'exit' ]; then
            exit
        elif [ "$2" = 'web+exit' ]; then
            gw && exit
        else
            echo_date "'__git_push' impossible case" && return 1
        fi
    }
    __git_push_current_branch() {
        if [ $# -ne 1 ]; then
            echo_date "'__git_push_current_branch' accepts 1 argument; got $#" && return 1
        fi
        # $1 = force
        if "$1"; then
            git push --force --set-upstream origin "$(current_branch)"
        else
            git push --set-upstream origin "$(current_branch)"
        fi
    }
    # rebase
    grb() {
        if [ $# -eq 0 ]; then
            __grb_branch='origin/master'
        elif [ $# -eq 1 ]; then
            __grb_branch="$1"
        else
            echo_date "'grb' accepts [0..1] arguments; got $#" && return 1
        fi
        gf && git rebase --strategy=recursive --strategy-option=theirs "${__grb_branch}"
    }
    grba() {
        if [ $# -ne 0 ]; then
            echo_date "'grba' accepts no arguments; got $#" && return 1
        fi
        git rebase --abort
    }
    grbc() {
        if [ $# -ne 0 ]; then
            echo_date "'grbc' accepts no arguments; got $#" && return 1
        fi
        git rebase --continue
    }
    grbs() {
        if [ $# -ne 0 ]; then
            echo_date "'grbs' accepts no arguments; got $#" && return 1
        fi
        git rebase --skip
    }
    # rebase (squash)
    gsqm() { gf && git reset --soft "$(git merge-base HEAD master)" && gcf "$@"; }
    # remote
    grmv() {
        if [ $# -ne 0 ]; then
            echo_date "'grmv' accepts no arguments; got $#" && return 1
        fi
        git remote -v
    }
    __is_github() {
        if [ $# -ne 0 ]; then
            echo_date "'__is_github' accepts no arguments; got $#" && return 1
        fi
        if git remote get-url origin 2>/dev/null | grep -q 'github'; then
            true
        else
            false
        fi
    }
    __is_gitlab() {
        if [ $# -ne 0 ]; then
            echo_date "'__is_gitlab' accepts no arguments; got $#" && return 1
        fi
        if git remote get-url origin 2>/dev/null | grep -q 'gitlab'; then
            true
        else
            false
        fi
    }
    # reset
    gr() { git reset "$@"; }
    grp() { git reset --patch "$@"; }
    # rev-parse
    current_branch() {
        if [ $# -ne 0 ]; then
            echo_date "'current_branch' accepts no arguments; got $#" && return 1
        fi
        git rev-parse --abbrev-ref HEAD
    }
    repo_root() {
        if [ $# -ne 0 ]; then
            echo_date "'repo_root' accepts no arguments; got $#" && return 1
        fi
        git rev-parse --show-toplevel
    }
    __branch_exists() {
        if [ $# -ne 1 ]; then
            echo_date "'__branch_exists' accepts 1 argument; got $#" && return 1
        fi
        if git rev-parse --verify "$1" >/dev/null 2>&1; then
            true
        else
            false
        fi
    }
    __is_current_branch() {
        if [ $# -ne 0 ]; then
            echo_date "'__is_current_branch' accepts no arguments; got $#" && return 1
        fi
        if [ "$(current_branch)" = "$1" ]; then
            true
        else
            false
        fi
    }
    __is_current_branch_dev() {
        if [ $# -ne 0 ]; then
            echo_date "'__is_current_branch_dev' accepts no arguments; got $#" && return 1
        fi
        __is_current_branch 'dev'
    }
    __is_current_branch_master() {
        if [ $# -ne 0 ]; then
            echo_date "'__is_current_branch_master' accepts no arguments; got $#" && return 1
        fi
        __is_current_branch 'master'
    }
    # rm
    grm() { git rm "$@"; }
    grmc() { git rm --cached "$@"; }
    grmf() { git rm -f "$@"; }
    grmr() { git rm -r "$@"; }
    grmrf() { git rm -rf "$@"; }
    # show-ref
    __is_valid_ref() {
        if [ $# -ne 1 ]; then
            echo_date "'__is_valid_ref' accepts 1 argument; got $#" && return 1
        fi
        git show-ref --verify --quiet "refs/heads/$1" ||
            git show-ref --verify --quiet "refs/remotes/$1" ||
            git show-ref --verify --quiet "refs/tags/$1" ||
            git rev-parse --verify --quiet "$1" >/dev/null
    }
    # status
    gs() {
        if [ $# -ge 2 ]; then
            echo_date "'gs' accepts [0..1] arguments; got $#" && return 1
        fi
        git status "$@"
    }
    __tree_is_clean() {
        if [ $# -ne 0 ]; then
            echo_date "'__tree_is_clean' accepts no arguments; got $#" && return 1
        fi
        [ -z "$(git status --porcelain)" ]
    }
    # stash
    gst() { git stash "$@"; }
    gstd() { git stash drop "$@"; }
    gstp() { git stash pop "$@"; }
    # submodules
    gsu() {
        if [ $# -ne 0 ]; then
            echo_date "'gsub_update' accepts no arguments; got $#" && return 1
        fi
        git submodule foreach --recursive 'git checkout master && git pull --ff-only'
    }
    # tag
    gta() {
        if [ $(($# % 2)) -ne 0 ]; then
            echo_date "'gta' accepts an even number of arguments; got $#" && return 1
        fi
        while [ $# -gt 0 ]; do
            __gta_tag="$1"
            __gta_sha="$2"
            git tag -a "${__gta_tag}" "${__gta_sha}" -m "${__gta_tag}" &&
                git push --set-upstream origin --tags
            shift 2
        done
    }
    gtd() { git tag --delete "$@" && git push --delete origin "$@"; }
fi

# gh/glab
if command -v gh >/dev/null 2>&1 || command -v glab >/dev/null 2>&1; then
    # ghcm() {
    #     if [ $# -eq 0 ] || [ $# -ge 3 ]; then
    #         echo_date "'ghcm' accepts [1..2] arguments; got $#" && return 1
    #     fi
    #     ghc "$@" && ghm
    # }
    # ghcmd() {
    #     if [ $# -eq 0 ] || [ $# -ge 3 ]; then
    #         echo_date "'ghcmd' accepts [1..2] arguments; got $#" && return 1
    #     fi
    #     ghc "$@" && ghm && gcmd
    # }
    # ghcme() {
    #     if [ $# -eq 0 ] || [ $# -ge 3 ]; then
    #         echo_date "'ghcme' accepts [1..2] arguments; got $#" && return 1
    #     fi
    #     ghc "$@" && ghm && gcmd && exit
    # }
    ghic() {
        if __is_github && [ $# -eq 1 ]; then
            gh issue create --title="$1" --body='.'
        elif __is_github && [ $# -eq 2 ]; then
            gh issue create --title="$1" --label="$2" --body='.'
        elif __is_github && [ $# -eq 3 ]; then
            gh issue create --title="$1" --label="$2" --body="$3"
        elif __is_gitlab && [ $# -eq 1 ]; then
            glab issue create --title="$1" --description='.'
        elif __is_gitlab && [ $# -eq 2 ]; then
            glab issue create --title="$1" --label="$2" --description='.'
        elif __is_gitlab && [ $# -eq 3 ]; then
            glab issue create --title="$1" --label="$2" --description="$3"
        elif [ $# -eq 0 ] || [ $# -ge 4 ]; then
            echo_date "'ghic' accepts [1..3] arguments; got $#" && return 1
        fi
    }
    ghil() {
        if [ $# -ne 0 ]; then
            echo_date "'ghil' accepts no arguments; got $#" && return 1
        fi
        if __is_github; then
            gh issue list
        elif __is_gitlab; then
            glab issue list
        fi
    }
    ghiv() {
        if [ $# -eq 0 ]; then
            __branch="$(current_branch)" || return $?
            __num="${__branch%%-*}"
            __msg="'ghiv' cannot be run on a branch without an issue number"
        elif [ $# -eq 1 ]; then
            __num="$1"
            __msg="'ghiv' issue number must be an integer; got '$1'"
        else
            echo_date "'ghiv' accepts [0..1] arguments; got $#" && return 1
        fi
        if ! [ "${__num}" -eq "${__num}" ] 2>/dev/null; then
            echo_date "${__num}" && return 1
        fi
        if __is_github; then
            gh issue view "${__num}" --web
        elif __is_gitlab; then
            glab issue view "${__num}" --web
        fi
    }
    ghl() {
        if [ $# -ne 0 ]; then
            echo_date "'ghl' accepts no arguments; got $#" && return 1
        fi
        if __is_github; then
            gh pr list
        elif __is_gitlab; then
            glab mr list
        fi
    }
    ghm() {
        if [ $# -ne 0 ]; then
            echo_date "'ghm' accepts no arguments; got $#" && return 1
        fi
        __gh_merge 'none'
    }
    ghd() {
        if [ $# -ne 0 ]; then
            echo_date "'ghd' accepts no arguments; got $#" && return 1
        fi
        __gh_merge 'delete'
    }
    ghe() {
        if [ $# -ne 0 ]; then
            echo_date "'ghe' accepts no arguments; got $#" && return 1
        fi
        __gh_merge 'delete+exit'
    }
    ghv() {
        if [ $# -ne 0 ]; then
            echo_date "'ghv' accepts no arguments; got $#" && return 1
        fi
        if __is_github; then
            if gh pr ready >/dev/null 2>&1; then
                gh pr view -w
            else
                echo_date "'ghv' cannot find an open PR" && return 1
            fi
        elif __is_gitlab; then
            __num="$(__glab_mr_num)"
            if [ -n "${__num}" ]; then
                glab mr view "${__num}" --web
            else
                echo_date "'ghv' cannot find an open PR" && return 1
            fi
        fi
    }
    __gh_create() {
        if [ $# -ne 2 ]; then
            echo_date "'__gh_create' accepts 2 arguments; got $#" && return 1
        fi
        # $1 = title
        # $2 = body
        __title="$1"
        __body="$2"
        if [ -z "${__title}" ]; then
            __title="Created by ${USER}@$(hostname) at $(date +"%Y-%m-%d %H:%M:%S (%a)")"
        fi
        if [ -n "${__body}" ] && __is_int "${__body}"; then
            __body="Closes #${__body}"
        fi
        if __is_github && __gh_exists; then
            gh pr edit --title="${__title}" --body="${__body}"
        elif __is_github && ! __gh_exists; then
            gh pr create --title="${__title}" --body="${__body}"
        elif __is_gitlab && __gh_exists; then
            glab mr update "$(__glab_mr_num)" \
                --title="${__title}" --description="${__body}"
        elif __is_gitlab && ! __gh_exists; then
            glab mr create --title="${__title}" --description="${__body}" \
                --push --remove-source-branch --squash-before-merge
        else
            echo_date "'__gh_create' impossible case" && return 1
        fi
    }
    __gh_exists() {
        if [ $# -ne 0 ]; then
            echo_date "'__gh_exists' accepts no arguments; got $#" && return 1
        fi
        if __is_github; then
            if gh pr view >/dev/null 2>&1; then
                true
            else
                true
            fi
        elif __is_gitlab; then
            if __glab_mr_num >/dev/null 2>&1; then
                true
            else
                true
            fi
        fi
    }
    __gh_merge() {
        if [ $# -ne 1 ]; then
            echo_date "'__gh_merge' accepts 1 argument; got $#" && return 1
        fi
        # $1 = action = {none/delete/delete+exit}
        if [ "$1" != 'none' ] && [ "$1" != 'delete' ] && [ "$1" != 'delete+exit' ]; then
            echo_date "'__gh_merge' invalid action; got '$1'" && return 1
        fi
        __start="$(date +%s)"
        __branch="$(current_branch)" || return 1
        if __is_github; then
            gh pr merge --auto --delete-branch --squash || return $?
            while __gh_pr_merging; do
                __now="$(date +%s)"
                __elapsed="$((__now - __start))"
                echo_date "'${__branch}' is still merging... (${__elapsed}s)"
                sleep 1
            done
        elif __is_gitlab; then
            __status="$(__glab_mr_merge_status)"
            if [ "${__status}" = 'conflict' ]; then
                echo_date "'${__branch}' has conflicts" && return 1
            elif [ "${__status}" = 'need_rebase' ]; then
                echo_date "'${__branch}' needs to be rebased" && return 1
            elif [ "${__status}" = 'not open' ]; then
                echo_date "'${__branch}' PR needs to be opened" && return 1
            fi
            while true; do
                glab mr merge --remove-source-branch --squash --yes >/dev/null 2>&1 || true
                if __gh_pr_merging; then
                    __status="$(__glab_mr_merge_status)"
                    __now="$(date +%s)"
                    __elapsed="$((__now - __start))"
                    echo_date "'${__branch}' is still merging... ('${__status}', ${__elapsed}s)"
                    sleep 1
                else
                    break
                fi
            done
        fi
        __git_checkout_master "$1"
    }
    __gh_pr_merging() {
        __branch="$(current_branch)" || return 1
        if __is_github; then
            if [ "$(gh pr view --json state 2>/dev/null | jq -r '.state')" != "OPEN" ]; then
                return 1
            fi
            __repo=$(gh repo view --json nameWithOwner -q .nameWithOwner)
            if gh api "repos/${__repo}/branches/${__branch}" >/dev/null 2>&1; then
                return 0
            fi
            return 1
        elif __is_gitlab; then
            __gh_pr_merging_json="$(__glab_mr_json)"
            if [ "$(__glab_mr_state)" != "opened" ]; then
                return 1
            fi
            if glab api "projects/$(__glab_mr_pid)/repository/branches/${__branch}" >/dev/null 2>&1; then
                return 0
            fi
            return 1
        fi
    }
fi

# gh/lab + gitweb
if (command -v gh >/dev/null 2>&1 || command -v glab >/dev/null 2>&1) && command -v gitweb >/dev/null 2>&1; then
    gw() {
        if [ $# -ne 0 ]; then
            echo_date "'gw' accepts no arguments; got $#" && return 1
        fi
        if __is_github; then
            if gh pr ready >/dev/null 2>&1; then
                ghv
            else
                gitweb
            fi
        elif __is_gitlab; then
            if __glab_mr_json >/dev/null 2>&1; then
                ghv
            else
                gitweb
            fi
        fi
    }
fi

# git + watch
if command -v git >/dev/null 2>&1 && command -v watch >/dev/null 2>&1; then
    wgd() { watch -d -n 0.5 -- git diff "$@"; }
    wgl() { watch -d -n 0.5 -- git log --abbrev-commit --decorate=short --oneline; }
    wgs() { watch -d -n 0.5 -- git status "$@"; }
fi

# git + gh/glab
if command -v git >/dev/null 2>&1 && (command -v gh >/dev/null 2>&1 || command -v glab >/dev/null 2>&1); then
    gacm() {
        if [ $# -ne 0 ]; then
            echo_date "'gacm' accepts no arguments; got $#" && return 1
        fi
        __add_merge 'none'
    }
    gacd() {
        if [ $# -ne 0 ]; then
            echo_date "'gacd' accepts no arguments; got $#" && return 1
        fi
        __add_merge 'delete'
    }
    gace() {
        if [ $# -ne 0 ]; then
            echo_date "'gace' accepts no arguments; got $#" && return 1
        fi
        __add_merge 'delete+exit'
    }
    gcbacm() {
        if [ $# -ge 3 ]; then
            echo_date "'gcbacm' accepts [0..2] arguments; got $#" && return 1
        fi
        __create_add_merge 'none' "$@"
    }
    gcbacd() {
        if [ $# -ge 3 ]; then
            echo_date "'gcbacd' accepts [0..2] arguments; got $#" && return 1
        fi
        __create_add_merge 'delete' "$@"
    }
    gcbace() {
        if [ $# -ge 3 ]; then
            echo_date "'gcbace' accepts [0..2] arguments; got $#" && return 1
        fi
        __create_add_merge 'delete+exit' "$@"
    }
    __add_merge() {
        if [ $# -ne 1 ]; then
            echo_date "'__add_merge' accepts 1 argument; got $#" && return 1
        fi
        # $1 = action
        if [ "$1" != 'none' ] && [ "$1" != 'delete' ] && [ "$1" != 'delete+exit' ]; then
            echo_date "'__add_merge' invalid action; got '$1'" && return 1
        fi
        gac && __gh_merge "$1"
    }
    __create_add_merge() {
        if [ $# -eq 0 ]; then
            echo_date "'__create_add_merge' accepts [1..) arguments; got $#" && return 1
        fi
        __action="$1"
        shift
        if [ "${__action}" != 'none' ] && [ "${__action}" != 'delete' ] &&
            [ "${__action}" != 'delete+exit' ]; then
            echo_date "'__create_add_merge' invalid action; got '${__action}'" && return 1
        fi
        gcb "$@" && __add_merge "${__action}"
    }
fi

# gh + watch
if command -v gh >/dev/null 2>&1 && command -v watch >/dev/null 2>&1; then
    ghs() {
        if [ $# -ne 0 ]; then
            echo_date "'ghs' accepts no arguments; got $#" && return 1
        fi
        if __is_github; then
            watch -d -n 1.0 'gh pr status'
        elif __is_gitlab; then
            echo_date "'ghs' must be for GitHub" && return 1
        fi
    }
fi

# glab
if command -v glab >/dev/null 2>&1; then
    __glab_mr_json() {
        if [ $# -ne 0 ]; then
            echo_date "'__glab_mr_json' accepts no arguments; got $#" && return 1
        fi
        __branch="$(current_branch)" || return 1
        __json=$(glab mr list --output=json --source-branch="${__branch}" 2>/dev/null) || return 1
        __num=$(printf "%s" "${__json}" | jq 'length') || return 1
        if [ "${__num}" -eq 0 ]; then
            echo_date "'__glab_mr_json' expects an MR for '${__branch}'; got none" && return 1
        elif [ "${__num}" -eq 1 ]; then
            printf "%s" "${__json}" | jq '.[0]' | jq
        else
            echo_date "'__glab_mr_json' expects a unique MR for '${__branch}'; got ${__num}" && return 1
        fi
    }
    __glab_mr_num() {
        if [ $# -ne 0 ]; then
            echo_date "'__glab_mr_num' accepts no arguments; got $#" && return 1
        fi
        __json="$(__glab_mr_json)" || return 1
        printf "%s\n" "${__json}" | jq -r '.iid'
    }
    __glab_mr_pid() {
        if [ $# -ne 0 ]; then
            echo_date "'__glab_mr_pid' accepts no arguments; got $#" && return 1
        fi
        __json="$(__glab_mr_json)" || return 1
        printf "%s\n" "${__json}" | jq -r '.target_project_id'
    }
    __glab_mr_merge_status() {
        if [ $# -ne 0 ]; then
            echo_date "'__glab_mr_merge_status' accepts no arguments; got $#" && return 1
        fi
        __json="$(__glab_mr_json)" || return 1
        printf "%s\n" "${__json}" | jq -r '.detailed_merge_status'
    }
    __glab_mr_state() {
        if [ $# -ne 0 ]; then
            echo_date "'__glab_mr_state' accepts no arguments; got $#" && return 1
        fi
        __json="$(__glab_mr_json)" || return 1
        printf "%s\n" "${__json}" | jq -r '.state'
    }
fi

# utilities
__is_int() {
    if printf '%s\n' "$1" | grep -Eq '^-?[0-9]+$'; then
        return 0
    else
        return 1
    fi
}
