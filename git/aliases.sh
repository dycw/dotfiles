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
	# add + commit + push
	gac() { __git_add_commit_push 0 0 0 "$@"; }
	gacn() { __git_add_commit_push 1 0 0 "$@"; }
	gacf() { __git_add_commit_push 0 1 0 "$@"; }
	gacnf() { __git_add_commit_push 1 1 0 "$@"; }
	gacw() { __git_add_commit_push 0 0 1 "$@"; }
	gacnw() { __git_add_commit_push 1 0 1 "$@"; }
	gacfw() { __git_add_commit_push 0 1 1 "$@"; }
	gacnfw() { __git_add_commit_push 1 1 1 "$@"; }
	__git_add_commit_push() {
		if [ $# -le 2 ]; then
			echo_date "'__git_add_commit_push' accepts [3..) arguments" && return 1
		fi
		__gacp_no_verify="$1"
		__gacp_force="$2"
		__gacp_web="$3"
		shift 3

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
			until __git_commit_push "${__gacp_no_verify}" "" "${__gacp_force}" "${__gacp_web}"; do
				ga
				__gacp_attempts=$((__gacp_attempts + 1))
				if [ "${__gacp_attempts}" -ge 5 ]; then
					return 1
				fi
			done
		elif [ "${__gacp_count_file}" -eq 0 ] && [ "${__gacp_count_non_file}" -eq 1 ]; then
			ga
			until __git_commit_push "${__gacp_no_verify}" "${__gacp_message}" "${__gacp_force}" "${__gacp_web}"; do
				ga
				__gacp_attempts=$((__gacp_attempts + 1))
				if [ "${__gacp_attempts}" -ge 5 ]; then
					return 1
				fi
			done
		elif [ "${__gacp_count_file}" -ge 1 ] && [ "${__gacp_count_non_file}" -eq 0 ]; then
			eval "ga ${__gacp_file_args}"
			__git_commit_push "${__gacp_no_verify}" "" "${__gacp_force}" "${__gacp_web}"
		elif [ "${__gacp_count_file}" -ge 1 ] && [ "${__gacp_count_non_file}" -eq 1 ]; then
			eval "ga ${__gacp_file_args}"
			__git_commit_push "${__gacp_no_verify}" "${__gacp_message}" "${__gacp_force}" "${__gacp_web}"
		else
			echo_date "'__git_add_commit_push' accepts any number of files followed by [0..1] messages; got ${__gacp_count_file} file(s) ${__gacp_file_list:-'(none)'} and ${__gacp_count_non_file} message(s)" && return 1
		fi
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
			__gbd_branch="$(__select_local_branch)"
		elif [ $# -eq 1 ]; then
			__gbd_branch="$1"
		else
			echo_date "'gbd' accepts [0..1] arguments" && return 1
		fi
		if __branch_exists "${__gbd_branch}"; then
			git branch --delete --force "${__gbd_branch}"
		fi
	}
	gbdr() {
		if [ $# -eq 0 ]; then
			__gbdr_branch="$(__select_remote_branch)"
		elif [ $# -eq 1 ]; then
			__gbdr_branch="$1"
		else
			echo_date "'gbdr' accepts [0..1] arguments" && return 1
		fi
		gf && git push --delete origin "${__gbdr_branch}"
	}
	gbm() { git branch -m "$1"; }
	__delete_gone_branches() {
		git branch -vv | awk '/: gone]/{print $1}' | xargs -r git branch -D
	}
	__select_local_branch() {
		git branch --format="%(refname:short)" | fzf
	}
	__select_remote_branch() {
		git branch --color=never --remotes | awk '!/->/' | fzf | sed -E 's|^[[:space:]]*origin/||'
	}
	# checkout
	gcm() {
		if [ $# -ne 0 ]; then
			echo_date "'gcm' accepts no arguments; got $#" && return 1
		fi
		gco master
	}
	gcmd() {
		if [ $# -ne 0 ]; then
			echo_date "'gcmd' accepts no arguments; got $#" && return 1
		fi
		if __is_current_branch_master; then
			gcof && gcm
		else
			__gcmd_branch="$(current_branch)" || return 1
			gcof && gcm && gbd "${__gcmd_branch}"
		fi
	}
	gco() {
		if [ $# -eq 0 ]; then
			__branch="$(__select_local_branch)"
		elif [ $# -eq 1 ]; then
			__branch="$1"
		else
			echo_date "'gco' accepts [0..1] arguments" && return 1
		fi
		git checkout "${__branch}" && gpl
	}
	gcob() {
		unset __title __num
		if [ $# -eq 0 ]; then
			if ! __is_current_branch_master; then
				echo_date "'gcob' off 'master' accepts 1 argument" && return 1
			fi
			__branch='dev'
		elif [ $# -eq 1 ]; then
			__title="$1"
			__branch="$(__to_valid_branch "${__title}")"
		elif [ $# -eq 2 ]; then
			__title="$1"
			__num="$2"
			__desc="$(__to_valid_branch "${__title}")"
			__branch="$2-${__desc}"
		else
			echo_date "'gcob' accepts [0..2] arguments" && return 1
		fi
		gf && git checkout -b "${__branch}" origin/master || return $?
		if [ $# -eq 1 ] && [ -n "${__title}" ]; then
			gp && __git_commit_empty_auto_message && gp && ghc "${__title}"
		elif [ $# -eq 2 ] && [ -n "${__title}" ] && [ -n "${__num}" ]; then
			gp && __git_commit_empty_auto_message && gp && ghc "${__title}" "${__num}"
		fi
	}
	gcobt() {
		if [ $# -eq 0 ]; then
			__branch="$(__select_remote_branch)"
		elif [ $# -eq 1 ]; then
			__branch="$1"
		else
			echo_date "'gcobt' accepts [0..1] arguments" && return 1
		fi
		if __is_current_branch_master; then
			gf && git checkout -b "${__branch}" --track="origin/${__branch}"
		else
			gco master
		fi
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
			echo_date "'gcofm' accepts [1..] arguments" && return 1
		fi
		gcof origin/master "$@"
	}
	gcop() { git checkout --patch "$@"; }
	__to_valid_branch() {
		if [ $# -ne 1 ]; then
			echo_date "'__to_valid_branch' accepts 1 argument" && return 1
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
			gcof && gcm && gcob "${__gbr_branch}"
		fi
	}
	# cherry-pick
	gcp() { git cherry-pick "$@"; }
	# clone
	gcl() { git clone --recurse-submodules "$@"; }
	# commit
	__git_commit() {
		if [ $# -ne 2 ]; then
			echo_date "'__git_commit' accepts 2 arguments" && return 1
		fi
		if git diff --cached --quiet && git diff --quiet; then
			return 0
		fi
		__gc_no_verify="$1"
		__gc_message="$2"
		if [ -z "${__gc_message}" ]; then
			__gc_message="$(__git_commit_auto_message)"
		fi
		if [ "${__gc_no_verify}" -eq 0 ]; then
			git commit --message="${__gc_message}"
		elif [ "${__gc_no_verify}" -eq 1 ]; then
			git commit --message="${__gc_message}" --no-verify
		else
			echo_date "'_' accepts {0, 1} for the 'no-verify' flag; got ${__gc_no_verify}" && return 1
		fi
	}
	__git_commit_auto_message() {
		echo "$(date +"%Y-%m-%d %H:%M:%S (%a)") > $(hostname) > ${USER}"
	}
	__git_commit_empty_auto_message() {
		git commit --allow-empty --message="$(__git_commit_auto_message)" --no-verify
	}
	# commit + push
	gc() {
		if [ $# -ge 2 ]; then
			echo_date "'gc' accepts [0..1] arguments" && return 1
		fi
		__git_commit_push 0 "${1:-}" 0 0
	}
	gcn() {
		if [ $# -ge 2 ]; then
			echo_date "'gcn' accepts [0..1] arguments" && return 1
		fi
		__git_commit_push 1 "${1:-}" 0 0
	}
	gcf() {
		if [ $# -ge 2 ]; then
			echo_date "'gcf' accepts [0..1] arguments" && return 1
		fi
		__git_commit_push 0 "${1:-}" 1 0
	}
	gcnf() {
		if [ $# -ge 2 ]; then
			echo_date "'gcnf' accepts [0..1] arguments" && return 1
		fi
		__git_commit_push 1 "${1:-}" 1 0
	}
	gcw() {
		if [ $# -ge 2 ]; then
			echo_date "'gcw' accepts [0..1] arguments" && return 1
		fi
		__git_commit_push 0 "${1:-}" 0 1
	}
	gcnw() {
		if [ $# -ge 2 ]; then
			echo_date "'gcnw' accepts [0..1] arguments" && return 1
		fi
		__git_commit_push 1 "${1:-}" 0 1
	}
	gcfw() {
		if [ $# -ge 2 ]; then
			echo_date "'gcfw' accepts [0..1] arguments" && return 1
		fi
		__git_commit_push 0 "${1:-}" 1 1
	}
	gcnfw() {
		if [ $# -ge 2 ]; then
			echo_date "'gcnfw' accepts [0..1] arguments" && return 1
		fi
		__git_commit_push 1 "${1:-}" 1 1
	}
	__git_commit_push() {
		if [ "$#" -ne 4 ]; then
			echo_date "'__git_commit_push' accepts 4 arguments" && return 1
		fi
		__gcp_no_verify="$1"
		__gcp_message="$2"
		__gcp_force="$3"
		__gcp_web="$4"
		__git_commit "${__gcp_no_verify}" "${__gcp_message}" &&
			__git_push "${__gcp_force}" "${__gcp_web}"
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
			echo_date "'gma' accepts 0 arguments" && return 1
		fi
		git merge --abort
	}
	# mv
	gmv() {
		if [ $# -ne 2 ]; then
			echo_date "'gmv' accepts 2 arguments" && return 1
		fi
		git mv "$1" "$2"
	}
	# pull
	gpl() {
		if [ $# -ne 0 ]; then
			echo_date "'gpl' accepts no arguments; got $#" && return 1
		fi
		git pull --force
		gf
	}
	# push
	gp() {
		if [ $# -ne 0 ]; then
			echo_date "'gp' accepts no arguments; got $#" && return 1
		fi
		__git_push 0 0
	}
	gpf() {
		if [ $# -ne 0 ]; then
			echo_date "'gpf' accepts no arguments; got $#" && return 1
		fi
		__git_push 1 0
	}
	gpw() {
		if [ $# -ne 0 ]; then
			echo_date "'gpw' accepts no arguments; got $#" && return 1
		fi
		__git_push 0 1
	}
	gpfw() {
		if [ $# -ne 0 ]; then
			echo_date "'gpfw' accepts no arguments; got $#" && return 1
		fi
		__git_push 1 1
	}
	__git_push() {
		if [ $# -ne 2 ]; then
			echo_date "'__git_push' accepts 2 arguments" && return 1
		fi
		__gp_force="$1"
		__gp_web="$2"
		__git_push_current_branch "${__gp_force}" || return $?
		if [ "${__gp_web}" -eq 0 ]; then
			:
		elif [ "${__gp_web}" -eq 1 ]; then
			gw
		else
			echo_date "'__git_push' accepts {0, 1} for the 'web' flag; got ${__gp_web}" && return 1
		fi
	}
	__git_push_current_branch() {
		if [ $# -ne 1 ]; then
			echo_date "'__git_push_current_branch' accepts 1 argument" && return 1
		fi
		__gpcb_force="$1"
		if [ "${__gpcb_force}" -eq 0 ]; then
			git push --set-upstream origin "$(current_branch)"
		elif [ "${__gpcb_force}" -eq 1 ]; then
			git push --force --set-upstream origin "$(current_branch)"
		else
			echo_date "'__git_push_current_branch' accepts {0, 1} for the 'force' flag; got ${__gpcb_force}" && return 1
		fi
	}
	# rebase
	grb() {
		if [ $# -eq 0 ]; then
			__grb_branch='origin/master'
		elif [ $# -eq 1 ]; then
			__grb_branch="$1"
		else
			echo_date "'grb' accepts [0..1] arguments" && return 1
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
			echo_date "'grmv' accepts 0 arguments" && return 1
		fi
		git remote -v
	}
	__repo_host() {
		if [ $# -ne 0 ]; then
			echo_date "'__repo_host' accepts 0 arguments" && return 1
		fi
		__rh_url=$(git remote get-url origin 2>/dev/null)
		if echo "$__rh_url" | grep -q "github"; then
			echo "github"
		elif echo "$__rh_url" | grep -q "gitlab"; then
			echo "gitlab"
		else
			echo_date "'__repo_host' must return 'github' or 'gitlab'; got '$__rh_url'" && return 1
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
		if git rev-parse --verify "$@" >/dev/null 2>&1; then
			true
		else
			false
		fi
	}
	__is_current_branch() {
		if [ "$(current_branch)" = "$1" ]; then
			true
		else
			false
		fi
	}
	__is_current_branch_dev() { __is_current_branch 'dev'; }
	__is_current_branch_master() { __is_current_branch 'master'; }
	# rm
	grm() { git rm "$@"; }
	grmc() { git rm --cached "$@"; }
	grmf() { git rm -f "$@"; }
	grmr() { git rm -r "$@"; }
	grmrf() { git rm -rf "$@"; }
	# show-ref
	__is_valid_ref() {
		if [ $# -ne 1 ]; then
			echo_date "'__is_valid_ref' accepts 1 argument" && return 1
		fi
		git show-ref --verify --quiet "refs/heads/$1" ||
			git show-ref --verify --quiet "refs/remotes/$1" ||
			git show-ref --verify --quiet "refs/tags/$1" ||
			git rev-parse --verify --quiet "$1" >/dev/null
	}
	# status
	gs() {
		if [ $# -ge 2 ]; then
			echo_date "'gs' accepts [0..1] arguments" && return 1
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
		done
	}
	gtd() { git tag --delete "$@" && git push --delete origin "$@"; }
fi

# gh/glab
if command -v gh >/dev/null 2>&1 || command -v glab >/dev/null 2>&1; then
	ghc() {
		if [ $# -ge 3 ]; then
			echo_date "'ghc' accepts [0..2] arguments" && return 1
		fi
		__gh_pr_create_or_edit create "${1:-}" "${2:-}"
	}
	ghcm() {
		if [ $# -eq 0 ] || [ $# -ge 3 ]; then
			echo_date "'ghcm' accepts [1..2] arguments" && return 1
		fi
		ghc "$@" && ghm
	}
	ghcmd() {
		if [ $# -eq 0 ] || [ $# -ge 3 ]; then
			echo_date "'ghcmd' accepts [1..2] arguments" && return 1
		fi
		ghc "$@" && ghm && gcmd
	}
	ghe() {
		if [ $# -eq 0 ] || [ $# -ge 3 ]; then
			echo_date "'ghe' accepts [1..2] arguments" && return 1
		fi
		__gh_pr_create_or_edit edit "${1:-}" "${2:-}"
	}
	ghic() {
		if [ $# -eq 0 ] || [ $# -ge 4 ]; then
			echo_date "'ghic' accepts [1..3] arguments" && return 1
		fi
		__host="$(__repo_host)" || return $?
		if [ "${__host}" = 'github' ] && [ $# -eq 1 ]; then
			gh issue create --title="$1" --body='.'
		elif [ "${__host}" = 'github' ] && [ $# -eq 2 ]; then
			gh issue create --title="$1" --label="$2" --body='.'
		elif [ "${__host}" = 'github' ] && [ $# -eq 3 ]; then
			gh issue create --title="$1" --label="$2" --body="$3"
		elif [ "${__host}" = 'gitlab' ] && [ $# -eq 1 ]; then
			glab issue create --title="$1" --description='.'
		elif [ "${__host}" = 'gitlab' ] && [ $# -eq 2 ]; then
			glab issue create --title="$1" --label="$2" --description='.'
		elif [ "${__host}" = 'gitlab' ] && [ $# -eq 3 ]; then
			glab issue create --title="$1" --label="$2" --description="$3"
		else
			echo_date "'ghic' must be for GitHub/GitLab; got '${__host}'" && return 1
		fi
	}
	ghil() {
		if [ $# -ne 0 ]; then
			echo_date "'ghil' accepts no arguments; got $#" && return 1
		fi
		__host="$(__repo_host)" || return $?
		if [ "${__host}" = 'github' ]; then
			gh issue list
		elif [ "${__host}" = 'gitlab' ]; then
			glab issue list
		else
			echo_date "'ghil' must be for GitHub/GitLab; got '${__host}'" && return 1
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
		__host="$(__repo_host)" || return $?
		if [ "${__host}" = 'github' ]; then
			gh issue view "${__num}" --web
		elif [ "${__host}" = 'gitlab' ]; then
			glab issue view "${__num}" --web
		else
			echo_date "'ghiv' must be for GitHub/GitLab; got '${__host}'" && return 1
		fi
	}
	ghl() {
		if [ $# -ne 0 ]; then
			echo_date "'ghl' accepts no arguments; got $#" && return 1
		fi
		__ghl_host="$(__repo_host)" || return 1
		if [ "${__ghl_host}" = 'github' ]; then
			gh pr list
		elif [ "${__ghl_host}" = 'gitlab' ]; then
			glab mr list
		else
			echo_date "'ghl' must be for GitHub/GitLab; got '${__host}'" && return 1
		fi
	}
	ghm() {
		if [ $# -ne 0 ]; then
			echo_date "'ghm' accepts no arguments; got $#" && return 1
		fi
		__gh_pr_merge 0
	}
	ghmd() {
		if [ $# -ne 0 ]; then
			echo_date "'ghmd' accepts no arguments; got $#" && return 1
		fi
		__gh_pr_merge 1
	}
	ghv() {
		if [ $# -ne 0 ]; then
			echo_date "'ghv' accepts no arguments; got $#" && return 1
		fi
		__host="$(__repo_host)" || return 1
		if [ "${__host}" = 'github' ]; then
			if gh pr ready >/dev/null 2>&1; then
				gh pr view -w
			else
				echo_date "'ghv' cannot find an open PR" && return 1
			fi
		elif [ "${__host}" = 'gitlab' ]; then
			__num="$(__glab_mr_num)"
			if [ -n "${__num}" ]; then
				glab mr view "${__num}" --web
			else
				echo_date "'ghv' cannot find an open PR" && return 1
			fi
		else
			echo_date "'ghv' must be for GitHub/GitLab
            got '${__host}'" && return 1
		fi
	}
	__gh_pr_create_or_edit() {
		if [ $# -ne 3 ]; then
			echo_date "'__gh_pr_create_or_edit' accepts 3 arguments" && return 1
		fi
		__verb="$1"
		__title="$2"
		__body="$3"
		__host="$(__repo_host)" || return 1
		if [ -z "${__title}" ]; then
			__title="Created by ${USER}@$(hostname) at $(date +"%Y-%m-%d %H:%M:%S (%a)")"
		fi
		if [ -n "${__body}" ] && __is_int "${__body}"; then
			__body="Closes #${__body}"
		fi
		if [ "${__host}" = 'github' ]; then
			gh pr "${__verb}" --title="${__title}" --body="${__body}"
		elif [ "${__host}" = 'gitlab' ]; then
			if [ "${__verb}" = 'edit' ]; then
				glab mr update "$(__glab_mr_num)" \
					--title="${__title}" --description="${__body}"
			else
				glab mr "${__verb}" \
					--title="${__title}" --description="${__body}" \
					--push --remove-source-branch --squash-before-merge
			fi
		else
			echo_date "'__gh_pr_create_or_edit' must be for GitHub/GitLab; got '${__host}'" && return 1
		fi
	}
	__gh_pr_merge() {
		if [ $# -ne 1 ]; then
			echo_date "'__gh_pr_merge' accepts 1 argument" && return 1
		fi
		__delete="$1"
		__host="$(__repo_host)" || return 1
		__branch="$(current_branch)" || return 1
		if [ "${__host}" = 'github' ]; then
			gh pr merge --auto --delete-branch --squash || return $?
		elif [ "${__host}" = 'gitlab' ]; then
			__status="$(__glab_mr_merge_status)"
			if [ "${__status}" = 'conflict' ]; then
				echo_date "'${__branch}' has conflicts" && return 1
			elif [ "${__status}" = 'need_rebase' ]; then
				echo_date "'${__branch}' needs to be rebased" && return 1
			elif [ "${__status}" = 'not open' ]; then
				echo_date "'${__branch}' PR needs to be opened" && return 1
			fi
			__start="$(date +%s)"
			while true; do
				__elapsed="$(($(date +%s) - __start))"
				__status="$(__glab_mr_merge_status)"
				if [ "${__status}" = 'mergeable' ]; then
					glab mr merge --remove-source-branch --squash --yes
				fi
				echo_date "'${__branch}' is still merging (${__status}; ${__elapsed}s)..."
				sleep 1
			done
		else
			echo_date "'__gh_pr_merge' must be for GitHub/GitLab; got '${__host}'" && return 1
		fi
		if [ "${__delete}" -eq 0 ]; then
			:
		elif [ "${__delete}" -eq 1 ]; then
			__gh_pr_await_merged "${__branch}" && gcmd || return $?
		else
			echo_date "'__gh_pr_merge' accepts {0, 1} for the 'delete' flag; got ${__delete}" && return 1
		fi
	}
	__gh_pr_merging() {
		__gh_pr_merging_host="$(__repo_host)" || return 1
		__gh_pr_merging_branch="$(current_branch)" || return 1
		if [ "${__gh_pr_merging_host}" = 'github' ]; then
			if [ "$(gh pr view --json state 2>/dev/null | jq -r '.state')" != "OPEN" ]; then
				return 1
			fi
			__gh_pr_merging_repo=$(gh repo view --json nameWithOwner -q .nameWithOwner)
			if gh api "repos/${__gh_pr_merging_repo}/branches/${__gh_pr_merging_branch}" >/dev/null 2>&1; then
				return 0
			fi
			return 1
		elif [ "${__gh_pr_merging_host}" = 'gitlab' ]; then
			__gh_pr_merging_json="$(__glab_mr_json)"
			if [ "$(__glab_mr_state)" != "opened" ]; then
				return 1
			fi
			if glab api "projects/$(__glab_mr_pid)/repository/branches/${__gh_pr_merging_branch}" >/dev/null 2>&1; then
				return 0
			fi
			return 1
		else
			echo_date "'__gh_pr_merging' must be for GitHub/GitLab; got '${__gh_pr_merging_host}'" && return 1
		fi
	}
	__gh_pr_await_merged() {
		if [ $# -ne 1 ]; then
			echo_date "'__gh_pr_await_merged' accepts 1 argument" && return 1
		fi
		while __gh_pr_merging; do
			echo_date "'$1' is still merging..."
			sleep 1
		done
		echo_date "'$1' has finished merging"
	}
fi

# gh/lab + gitweb
if (command -v gh >/dev/null 2>&1 || command -v glab >/dev/null 2>&1) && command -v gitweb >/dev/null 2>&1; then
	gw() {
		if [ $# -ne 0 ]; then
			echo_date "'gw' accepts no arguments; got $#" && return 1
		fi
		__gw_host="$(__repo_host)" || return 1
		if [ "${__gw_host}" = 'github' ]; then
			if gh pr ready >/dev/null 2>&1; then
				ghv
			else
				gitweb
			fi
		elif [ "${__gw_host}" = 'gitlab' ]; then
			if __glab_mr_json >/dev/null 2>&1; then
				ghv
			else
				gitweb
			fi
		else
			echo_date "'gw' must be for GitHub/GitLab; got '${__gw_host}'" && return 1
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
	gacc() {
		if [ $# -ge 3 ]; then
			echo_date "'gacc' accepts [0..2] arguments" && return 1
		fi
		__git_add_gh_pr_create "${1:-}" "${2:-}" 0
	}
	gaccv() {
		if [ $# -ge 3 ]; then
			echo_date "'gaccv' accepts [0..2] arguments" && return 1
		fi
		__git_add_gh_pr_create "${1:-}" "${2:-}" 1
	}
	gaccmd() {
		if [ $# -eq 0 ] || [ $# -ge 3 ]; then
			echo_date "'gaccmd' accepts [1..2] arguments" && return 1
		fi
		gac && ghcmd "$@"
	}
	__git_add_gh_pr_create() {
		if [ $# -ne 3 ]; then
			echo_date "'__git_add_gh_pr_create' accepts 3 arguments" && return 1
		fi
		__ga_gh_pr_c_first="$1"
		__ga_gh_pr_c_second="$2"
		__ga_gh_pr_c_view="$3"
		gac || return $?
		if [ -z "${__ga_gh_pr_c_first}" ] && [ -z "${__ga_gh_pr_c_second}" ]; then
			ghc || return $?
		elif [ -n "${__ga_gh_pr_c_first}" ] && [ -z "${__ga_gh_pr_c_second}" ]; then
			ghc "${__ga_gh_pr_c_first}" || return $?
		elif [ -n "${__ga_gh_pr_c_first}" ] && [ -n "${__ga_gh_pr_c_second}" ]; then
			ghc "${__ga_gh_pr_c_first}" "${__ga_gh_pr_c_second}" || return $?
		else
			echo_date "'__git_add_gh_pr_create' is missing first but got second ${__ga_gh_pr_c_second}" && return 1
		fi
		if [ "${__ga_gh_pr_c_view}" -eq 0 ]; then
			:
		elif [ "${__ga_gh_pr_c_view}" -eq 1 ]; then
			ghv
		else
			echo_date "'__git_add_gh_pr_create' accepts {0, 1} for the 'view' flag; got ${__ga_gh_pr_c_view}" && return 1
		fi
	}
fi

# gh + watch
if command -v gh >/dev/null 2>&1 && command -v watch >/dev/null 2>&1; then
	ghs() {
		if [ $# -ne 0 ]; then
			echo_date "'ghs' accepts no arguments; got $#" && return 1
		fi
		__ghs_host="$(__repo_host)" || return 1
		if [ "${__ghs_host}" = 'github' ]; then
			watch -d -n 1.0 'gh pr status'
		else
			echo_date "'ghs' must be for GitHub; got '${__ghs_host}'" && return 1
		fi
	}
fi

# glab
if command -v glab >/dev/null 2>&1; then
	__glab_mr_json() {
		if [ $# -ne 0 ]; then
			echo_date "'__glab_mr_json' accepts 0 arguments; got $#" && return 1
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
			echo_date "'__glab_mr_num' accepts 0 arguments; got $#" && return 1
		fi
		__json="$(__glab_mr_json)" || return 1
		printf "%s\n" "${__json}" | jq -r '.iid'
	}
	__glab_mr_pid() {
		if [ $# -ne 0 ]; then
			echo_date "'__glab_mr_pid' accepts 0 arguments; got $#" && return 1
		fi
		__json="$(__glab_mr_json)" || return 1
		printf "%s\n" "${__json}" | jq -r '.target_project_id'
	}
	__glab_mr_merge_status() {
		if [ $# -ne 0 ]; then
			echo_date "'__glab_mr_merge_status' accepts 0 arguments; got $#" && return 1
		fi
		__json="$(__glab_mr_json)" || return 1
		printf "%s\n" "${__json}" | jq -r '.detailed_merge_status'
	}
	__glab_mr_state() {
		if [ $# -ne 0 ]; then
			echo_date "'__glab_mr_state' accepts 0 arguments; got $#" && return 1
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
