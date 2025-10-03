#!/usr/bin/env sh
# shellcheck disable=SC2120,SC2317

# echo
echo_date() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"; }

# git
if command -v git >/dev/null 2>&1; then
	gcof() {
		if [ $# -eq 0 ]; then
			git checkout -- .
		else
			if __is_valid_ref "$1"; then
				__gcof_branch="$1"
				shift
				git checkout "${__gcof_branch}" -- "$@"
			else
				git checkout -- "$@"
			fi
		fi
	}
	gcofm() {
		[ $# -eq 0 ] && echo_date "'gcofm' accepts [1..] arguments; got $#" && return 1
		gcof origin/master "$@"
	}
	gcop() { git checkout --patch "$@"; }
	__git_checkout_master() {
		[ $# -ne 1 ] && echo_date "'__git_checkout_master' accepts 1 argument; got $#" && return 1
		# $1 = action = {none/delete/delete+exit}
		case "$1" in
		'none' | 'delete' | 'delete+exit') ;;
		*) echo_date "'__git_checkout_master' invalid action; got '$1'" && return 1 ;;
		esac
		__git_checkout_master_branch="$(__current_branch)" || return $?
		gco master || return $?
		if [ "$1" = 'delete' ] || [ "$1" = 'delete+exit' ]; then
			gbd "${__git_checkout_master_branch}" || return $?
		fi
		if [ "$1" = 'delete+exit' ]; then
			exit
		fi
	}
	__git_create() {
		[ $# -ne 2 ] && echo_date "'__git_create' accepts 2 arguments; got $#" && return 1
		# $1 = title
		# $2 = body/num
		gf || return $?
		if [ "$1" = '' ] && [ "$2" = '' ]; then
			__git_create_branch='dev'
			__git_create_title="$(__auto_msg)"
			__git_create_body='.'
		elif [ "$1" != '' ] && [ "$2" = '' ]; then
			__git_create_title="$1"
			__git_create_branch="$(__to_valid_branch "$1")" || return $?
			__git_create_body='.'
		elif [ "$1" != '' ] && [ "$2" != '' ] && __is_int "$2"; then
			__git_create_title="$1"
			__git_create_branch="$2-$(__to_valid_branch "$1")" || return $?
			__git_create_body="Closes #$2"
		elif [ "$1" != '' ] && [ "$2" != '' ] && ! __is_int "$2"; then
			__git_create_title="$1"
			__git_create_branch="$(__to_valid_branch "$1")" || return $?
			__git_create_body="$2"
		else
			echo_date "'__git_create' impossible case; got '$1' and '$2'" && return 1
		fi
		git checkout -b "${__git_create_branch}" origin/master &&
			__git_commit_empty_msg &&
			__git_push false true 'none' &&
			__gh_create "${__git_create_title}" "${__git_create_body}"
	}
	__git_create_all() {
		[ $# -le 3 ] && echo_date "'__git_create_all' accepts [4..) arguments; got $#" && return 1
		__git_create_all_title="$1"
		__git_create_all_nv="$2"
		__git_create_all_force="$3"
		__git_create_all_action="$4"
		shift 4
		case "${__git_create_all_action}" in
		'none' | 'web' | 'exit' | 'web+exit' | 'merge' | 'merge+exit') ;;
		*) echo_date "'__git_create_all' invalid action; got '${__git_create_all_action}'" && return 1 ;;
		esac
		if [ $# -ge 1 ] && __is_int "$1"; then
			__git_create_all_num="$1"
			shift
		else
			__git_create_all_num=''
		fi
		__git_create "${__git_create_all_title}" "${__git_create_all_num}" &&
			__git_all true "${__git_create_all_nv}" "${__git_create_all_force}" "${__git_create_all_action}" "$@"
	}
	__to_valid_branch() {
		[ $# -ne 1 ] && echo_date "'__to_valid_branch' accepts 1 argument; got $#" && return 1
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
			echo_date "'gbr' cannot be run on 'master'" && return 1
		else
			__gbr_branch="$(__current_branch)" || return 1
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
		# $1 = message
		# $2 = no-verify
		if git diff --cached --quiet && git diff --quiet; then
			return 0
		fi
		if [ "$1" = '' ]; then
			__git_commit_msg="$(__auto_msg)"
		else
			__git_commit_msg="$1"
		fi
		if "$2"; then
			git commit --message="${__git_commit_msg}" --no-verify
		else
			git commit --message="${__git_commit_msg}"
		fi
	}
	__git_commit_empty_msg() {
		[ $# -ne 0 ] && echo_date "'__git_commit_empty_msg' accepts no arguments; got $#" && return 1
		git commit --allow-empty --message="$(__auto_msg)" --no-verify
	}
	__git_commit_until() {
		[ $# -le 1 ] && echo_date "'__git_commit_until' accepts [2..) arguments; got $#" && return 1
		__git_commit_until_msg="$1"
		__git_commit_until_nv="$2"
		shift 2
		for __git_commit_until_i in $(seq 0 4); do
			ga "$@" || return $?
			if __git_commit "${__git_commit_until_msg}" "${__git_commit_until_nv}"; then
				return 0
			fi
		done
		return 1

	}
	# diff
	gd() { git diff "$@"; }
	gdc() { git diff --cached "$@"; }
	gdm() { git diff origin/master "$@"; }
	# fetch
	gf() {
		[ $# -ne 0 ] && echo_date "'gf' accepts no arguments; got $#" && return 1
		git fetch --all --force && __delete_gone_branches
	}
	# log
	gl() {
		__gl_format='format:%C(red)%h%C(reset) |%C(yellow)%d%C(reset) | %s | %Cgreen%cr%C(reset)'
		if [ $# -eq 0 ]; then
			git log --abbrev-commit --decorate=short --max-count=30 --pretty="${__gl_format}"
		elif [ $# -eq 1 ] && [ "$1" = 'all ' ]; then
			git log --abbrev-commit --decorate=short --pretty="${__gl_format}"
		elif [ $# -eq 1 ] && [ "$1" != 'all ' ]; then
			git log --abbrev-commit --decorate=short --max-count="$1" --pretty="${__gl_format}"
		else
			echo_date "'gl' accepts [0..1] arguments; got $#" && return 1
		fi
	}
	# merge
	gma() {
		[ $# -ne 0 ] && echo_date "'gma' accepts no arguments; got $#" && return 1
		git merge --abort
	}
	# mv
	gmv() {
		[ $# -le 1 ] && echo_date "'gmv' accepts [2..) arguments; got $#" && return 1
		git mv "$@"
	}
	# pull
	gpl() {
		[ $# -ne 0 ] && echo_date "'gpl' accepts no arguments; got $#" && return 1
		git pull --force && gf
	}
	# # push
	gp() {
		[ $# -ne 0 ] && echo_date "'gp' accepts no arguments; got $#" && return 1
		__git_push false false 'none'
	}
	gpf() {
		[ $# -ne 0 ] && echo_date "'gpf' accepts no arguments; got $#" && return 1
		__git_push true false 'none'
	}
	gpn() {
		[ $# -ne 0 ] && echo_date "'gpn' accepts no arguments; got $#" && return 1
		__git_push false true 'none'
	}
	gpfn() {
		[ $# -ne 0 ] && echo_date "'gpfn' accepts no arguments; got $#" && return 1
		__git_push true true 'none'
	}
	gpw() {
		[ $# -ne 0 ] && echo_date "'gpw' accepts no arguments; got $#" && return 1
		__git_push false false 'web'
	}
	gpfw() {
		[ $# -ne 0 ] && echo_date "'gpfw' accepts no arguments; got $#" && return 1
		__git_push true false 'web'
	}
	gpnw() {
		[ $# -ne 0 ] && echo_date "'gpnw' accepts no arguments; got $#" && return 1
		__git_push false true 'web'
	}
	gpfnw() {
		[ $# -ne 0 ] && echo_date "'gpfnw' accepts no arguments; got $#" && return 1
		__git_push true true 'web'
	}
	gpe() {
		[ $# -ne 0 ] && echo_date "'gpe' accepts no arguments; got $#" && return 1
		__git_push false false 'exit'
	}
	gpfe() {
		[ $# -ne 0 ] && echo_date "'gpfe' accepts no arguments; got $#" && return 1
		__git_push true false 'exit'
	}
	gpne() {
		[ $# -ne 0 ] && echo_date "'gpne' accepts no arguments; got $#" && return 1
		__git_push false true 'exit'
	}
	gpfne() {
		[ $# -ne 0 ] && echo_date "'gpfne' accepts no arguments; got $#" && return 1
		__git_push true true 'exit'
	}
	gpx() {
		[ $# -ne 0 ] && echo_date "'gpx' accepts no arguments; got $#" && return 1
		__git_push false false 'web+exit'
	}
	gpfx() {
		[ $# -ne 0 ] && echo_date "'gpfx' accepts no arguments; got $#" && return 1
		__git_push true false 'web+exit'
	}
	gpnx() {
		[ $# -ne 0 ] && echo_date "'gpnx' accepts no arguments; got $#" && return 1
		__git_push false true 'web+exit'
	}
	gpfnx() {
		[ $# -ne 0 ] && echo_date "'gpfnx' accepts no arguments; got $#" && return 1
		__git_push true true 'web+exit'
	}
	__git_push() {
		[ $# -ne 3 ] && echo_date "'__git_push' accepts 3 arguments; got $#" && return 1
		# $1 = force
		# $2 = no-verify
		# $3 = action = {none/web/exit/web+exit}
		case "$3" in
		'none' | 'web' | 'exit' | 'web+exit') ;;
		*) echo_date "'__gh_push' invalid action; got '$3'" && return 1 ;;
		esac
		__git_push_current_branch "$1" "$2" || return $?
		if [ "$3" = 'none' ]; then
			:
		elif [ "$3" = 'web' ]; then
			gw
		elif [ "$3" = 'exit' ]; then
			exit
		elif [ "$3" = 'web+exit' ]; then
			gw && exit
		else
			echo_date "'__git_push' impossible case; got '$3'" && return 1
		fi
	}
	__git_push_current_branch() {
		[ $# -ne 2 ] && echo_date "'__git_push_current_branch' accepts 2 arguments; got $#" && return 1
		# $1 = force
		# $2 = no-verify
		if [ "$1" = 'false' ] && [ "$2" = 'false' ]; then
			git push --set-upstream origin "$(__current_branch)"
		elif [ "$1" = 'false' ] && [ "$2" = 'true' ]; then
			git push --set-upstream origin "$(__current_branch)" --no-verify
		elif [ "$1" = 'true' ] && [ "$2" = 'false' ]; then
			git push --force --set-upstream origin "$(__current_branch)"
		elif [ "$1" = 'true' ] && [ "$2" = 'true' ]; then
			git push --force --set-upstream origin "$(__current_branch)" --no-verify
		else
			echo_date "'__git_push_current_branch' impossible case; got '$1' and '$2'" && return 1
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
		[ $# -ne 0 ] && echo_date "'grba' accepts no arguments; got $#" && return 1
		git rebase --abort
	}
	grbc() {
		[ $# -ne 0 ] && echo_date "'grbc' accepts no arguments; got $#" && return 1
		git rebase --continue
	}
	grbs() {
		[ $# -ne 0 ] && echo_date "'grbs' accepts no arguments; got $#" && return 1
		git rebase --skip
	}
	# rebase (squash)
	gsqm() { gf && git reset --soft "$(git merge-base HEAD master)" && gcf "$@"; }
	# remote
	grmv() {
		[ $# -ne 0 ] && echo_date "'grmv' accepts no arguments; got $#" && return 1
		git remote -v
	}
	__is_github() {
		[ $# -ne 0 ] && echo_date "'__is_github' accepts no arguments; got $#" && return 1
		if git remote get-url origin 2>/dev/null | grep -q 'github'; then
			true
		else
			false
		fi
	}
	__is_gitlab() {
		[ $# -ne 0 ] && echo_date "'__is_gitlab' accepts no arguments; got $#" && return 1
		if git remote get-url origin 2>/dev/null | grep -q 'gitlab'; then
			true
		else
			false
		fi
	}
	__repo_name() {
		[ $# -ne 0 ] && echo_date "'__repo_name' accepts no arguments; got $#" && return 1
		basename -s .git "$(git remote get-url origin)"
	}
	# reset
	gr() { git reset "$@"; }
	grhom() { git reset --hard origin/master "$@"; }
	grp() { git reset --patch "$@"; }
	# rev-parse
	__branch_exists() {
		[ $# -ne 1 ] && echo_date "'__branch_exists' accepts 1 argument; got $#" && return 1
		if git rev-parse --verify "$1" >/dev/null 2>&1; then
			true
		else
			false
		fi
	}
	__current_branch() {
		[ $# -ne 0 ] && echo_date "'__current_branch' accepts no arguments; got $#" && return 1
		git rev-parse --abbrev-ref HEAD
	}
	__is_current_branch() {
		[ $# -ne 1 ] && echo_date "'__is_current_branch' accepts 1 argument; got $#" && return 1
		if [ "$(__current_branch)" = "$1" ]; then
			true
		else
			false
		fi
	}
	__is_current_branch_dev() {
		[ $# -ne 0 ] && echo_date "'__is_current_branch_dev' accepts no arguments; got $#" && return 1
		__is_current_branch 'dev'
	}
	__is_current_branch_master() {
		[ $# -ne 0 ] && echo_date "'__is_current_branch_master' accepts no arguments; got $#" && return 1
		__is_current_branch 'master'
	}
	__repo_root() {
		[ $# -ne 0 ] && echo_date "'__repo_root' accepts no arguments; got $#" && return 1
		git rev-parse --show-toplevel
	}
	# status
	__tree_is_clean() {
		[ $# -ne 0 ] && echo_date "'__tree_is_clean' accepts no arguments; got $#" && return 1
		[ -z "$(git status --porcelain)" ]
	}
	# tag
	gta() {
		[ $(($# % 2)) -ne 0 ] && echo_date "'gta' accepts an even number of arguments; got $#" && return 1
		while [ $# -gt 0 ]; do
			# $1 = tag
			# $2 = sha
			git tag -a "$1" "$2" -m "$1" || return $?
			git push --set-upstream origin --tags || return $?
			shift 2
		done
		gl 20
	}
	gtd() {
		git tag --delete "$@" || return $?
		git push --delete origin "$@" || return $?
		gl 20
	}
fi

# gh/glab
if command -v gh >/dev/null 2>&1 || command -v glab >/dev/null 2>&1; then
	ghc() {
		if [ $# -eq 1 ]; then
			__gh_create "$1" '.'
		elif [ $# -eq 2 ]; then
			__gh_create "$1" "$@"
		else
			echo_date "'gcb' accepts [0..2] arguments; got $#" && return 1
		fi
	}
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
		else
			echo_date "'ghic' impossible case" && return 1
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
		else
			echo_date "'ghil' impossible case" && return 1
		fi
	}
	ghiv() {
		if [ $# -eq 0 ]; then
			__ghiv_branch="$(__current_branch)" || return $?
			__ghiv_num="${__ghiv_branch%%-*}"
			__ghiv_msg="'ghiv' cannot be run on a branch without an issue number"
		elif [ $# -eq 1 ]; then
			__ghiv_num="$1"
			__ghiv_msg="'ghiv' issue number must be an integer; got '$1'"
		else
			echo_date "'ghiv' accepts [0..1] arguments; got $#" && return 1
		fi
		if ! [ "${__ghiv_num}" -eq "${__ghiv_num}" ] 2>/dev/null; then
			echo_date "${__ghiv_num}" && return 1
		fi
		if __is_github; then
			gh issue view "${__ghiv_num}" --web
		elif __is_gitlab; then
			glab issue view "${__ghiv_num}" --web
		else
			echo_date "'ghiv' impossible case" && return 1
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
		else
			echo_date "'ghl' impossible case" && return 1
		fi
	}
	ghm() {
		[ $# -ne 0 ] && echo_date "'ghm' accepts no arguments; got $#" && return 1
		__gh_merge 'none'
	}
	ghd() {
		[ $# -ne 0 ] && echo_date "'ghd' accepts no arguments; got $#" && return 1
		__gh_merge 'delete'
	}
	ghx() {
		[ $# -ne 0 ] && echo_date "'ghx' accepts no arguments; got $#" && return 1
		__gh_merge 'delete+exit'
	}
	ghv() {
		[ $# -ne 0 ] && echo_date "'ghv' accepts no arguments; got $#" && return 1
		if __is_github; then
			if gh pr ready >/dev/null 2>&1; then
				gh pr view -w
			else
				echo_date "'ghv' cannot find an open PR for '$(__current_branch)'" && return 1
			fi
		elif __is_gitlab; then
			__num="$(__glab_mr_num)"
			if [ -n "${__num}" ]; then
				glab mr view "${__num}" --web
			else
				echo_date "'ghv' cannot find an open PR for '$(__current_branch)'" && return 1
			fi
		else
			echo_date "'ghv' impossible case" && return 1
		fi
	}
	__gh_create() {
		[ $# -ne 2 ] && echo_date "'__gh_create' accepts 2 arguments; got $#" && return 1
		# $1 = title
		# $2 = body
		if __is_github && __gh_exists; then
			gh pr edit --title="$1" --body="$2"
		elif __is_github && ! __gh_exists; then
			gh pr create --title="$1" --body="$2"
		elif __is_gitlab && __gh_exists; then
			glab mr update "$(__glab_mr_num)" --title="$1" --description="$2"
		elif __is_gitlab && ! __gh_exists; then
			glab mr create --title="$1" --description="$2" \
				--push --remove-source-branch --squash-before-merge
		else
			echo_date "'__gh_create' impossible case" && return 1
		fi
	}
	__gh_exists() {
		[ $# -ne 0 ] && echo_date "'__gh_exists' accepts no arguments; got $#" && return 1
		if __is_github; then
			__gh_exists_branch=$(__current_branch)
			__gh_exists_num="$(gh pr list --head="${__gh_exists_branch}" --json number --jq '. | length')"
			if [ "${__gh_exists_num}" -eq 1 ]; then
				true
			else
				false
			fi
		elif __is_gitlab; then
			if __glab_mr_num >/dev/null 2>&1; then
				true
			else
				false
			fi
		else
			echo_date "'__gh_exists' impossible case" && return 1
		fi
	}
	__gh_merge() {
		[ $# -ne 1 ] && echo_date "'__gh_merge' accepts 1 argument; got $#" && return 1
		# $1 = action = {none/delete/delete+exit}
		if [ "$1" != 'none' ] && [ "$1" != 'delete' ] &&
			[ "$1" != 'delete+exit' ]; then
			echo_date "'__gh_merge' invalid action; got '$1'" && return 1
		fi
		if ! __gh_exists; then
			echo_date "'__gh_merge' cannot find an open PR for '$(__current_branch)'" && return 1
		fi
		__gh_merge_start="$(date +%s)"
		if __is_github; then
			gh pr merge --auto --delete-branch --squash || return $?
			while __gh_pr_merging; do
				__gh_merge_elapsed="$(($(date +%s) - __gh_merge_start))"
				echo_date "'$(__repo_name)/$(__current_branch)' is still merging... (${__gh_merge_elapsed}s)"
				sleep 1
			done
		elif __is_gitlab; then
			__gh_merge_status="$(__glab_mr_merge_status)"
			if [ "${__gh_merge_status}" = 'conflict' ] ||
				[ "${__gh_merge_status}" = 'need_rebase' ] ||
				[ "${__gh_merge_status}" = 'not open' ]; then
				echo_date "'$(__current_branch)' cannot be merged; got ${__gh_merge_status}" && return 1
			fi
			while true; do
				glab mr merge --remove-source-branch --squash --yes >/dev/null 2>&1 || true
				if __gh_pr_merging; then
					__gh_merge_elapsed="$(($(date +%s) - __gh_merge_start))"
					echo_date "'$(__repo_name)/$(__current_branch)' is still merging... ('$(__glab_mr_merge_status)', ${__gh_merge_elapsed}s)"
					sleep 1
				else
					break
				fi
			done
		else
			echo_date "'__gh_merge' impossible case" && return 1
		fi
		__git_checkout_master "$1"
	}
	__gh_pr_merging() {
		__gh_pr_merging_branch="$(__current_branch)" || return 1
		if __is_github; then
			if [ "$(gh pr view --json state 2>/dev/null | jq -r '.state')" != "OPEN" ]; then
				return 1
			fi
			__gh_pr_merging_repo=$(gh repo view --json nameWithOwner -q .nameWithOwner)
			if gh api "repos/${__gh_pr_merging_repo}/branches/${__gh_pr_merging_branch}" >/dev/null 2>&1; then
				return 0
			fi
			return 1
		elif __is_gitlab; then
			__gh_pr_merging_json="$(__glab_mr_json)"
			if [ "$(__glab_mr_state)" != "opened" ]; then
				return 1
			fi
			if glab api "projects/$(__glab_mr_pid)/repository/branches/${__gh_pr_merging_branch}" >/dev/null 2>&1; then
				return 0
			fi
			return 1
		else
			echo_date "'__gh_pr_merging' impossible case" && return 1
		fi
	}
fi

# gh/lab + gitweb
if (command -v gh >/dev/null 2>&1 || command -v glab >/dev/null 2>&1) && command -v gitweb >/dev/null 2>&1; then
	gw() {
		[ $# -ne 0 ] && echo_date "'gw' accepts no arguments; got $#" && return 1
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
		else
			echo_date "'gw' impossible case" && return 1
		fi
	}
fi

# git + watch
if command -v git >/dev/null 2>&1 && command -v watch >/dev/null 2>&1; then
	wgd() { watch -d -n 0.5 -- git diff "$@"; }
	wgl() { watch -d -n 0.5 -- git log --abbrev-commit --decorate=short --oneline; }
	wgs() { watch -d -n 0.5 -- git status "$@"; }
fi

# gh + watch
if command -v gh >/dev/null 2>&1 && command -v watch >/dev/null 2>&1; then
	ghs() {
		[ $# -ne 0 ] && echo_date "'ghs' accepts no arguments; got $#" && return 1
		if __is_github; then
			watch -d -n 1.0 'gh pr status'
		elif __is_gitlab; then
			echo_date "'ghs' must be for GitHub" && return 1
		else
			echo_date "'ghs' impossible case" && return 1
		fi
	}
fi

# glab
if command -v glab >/dev/null 2>&1; then
	__glab_mr_json() {
		[ $# -ne 0 ] && echo_date "'__glab_mr_json' accepts no arguments; got $#" && return 1
		__glab_mr_json_branch="$(__current_branch)" || return 1
		__glab_mr_json_json=$(glab mr list --output=json --source-branch="${__glab_mr_json_branch}" 2>/dev/null) || return 1
		__glab_mr_json_num=$(printf "%s" "${__glab_mr_json_json}" | jq 'length') || return 1
		if [ "${__glab_mr_json_num}" -eq 0 ]; then
			echo_date "'__glab_mr_json' expects an MR for '${__glab_mr_json_branch}'; got none" && return 1
		elif [ "${__glab_mr_json_num}" -eq 1 ]; then
			printf "%s" "${__glab_mr_json_json}" | jq '.[0]' | jq
		else
			echo_date "'__glab_mr_json' expects a unique MR for '${__glab_mr_json_branch}'; got ${__glab_mr_json_num}" && return 1
		fi
	}
	__glab_mr_num() {
		[ $# -ne 0 ] && echo_date "'__glab_mr_num' accepts no arguments; got $#" && return 1
		__glab_mr_num_json="$(__glab_mr_json)" || return 1
		printf "%s\n" "${__glab_mr_num_json}" | jq -r '.iid'
	}
	__glab_mr_pid() {
		[ $# -ne 0 ] && echo_date "'__glab_mr_pid' accepts no arguments; got $#" && return 1
		__glab_mr_pid_json="$(__glab_mr_json)" || return 1
		printf "%s\n" "${__glab_mr_pid_json}" | jq -r '.target_project_id'
	}
	__glab_mr_merge_status() {
		[ $# -ne 0 ] && echo_date "'__glab_mr_merge_status' accepts no arguments; got $#" && return 1
		__glab_mr_merge_status_json="$(__glab_mr_json)" || return 1
		printf "%s\n" "${__glab_mr_merge_status_json}" | jq -r '.detailed_merge_status'
	}
	__glab_mr_state() {
		[ $# -ne 0 ] && echo_date "'__glab_mr_state' accepts no arguments; got $#" && return 1
		__glab_mr_state_json="$(__glab_mr_json)" || return 1
		printf "%s\n" "${__glab_mr_state_json}" | jq -r '.state'
	}
fi

# utilities
__auto_msg() {
	[ $# -ne 0 ] && echo_date "'__auto_msg' accepts no arguments; got $#" && return 1
	echo "$(date +"%Y-%m-%d %H:%M:%S (%a)") > $(hostname) > ${USER}"
}
__is_int() {
	[ $# -ne 1 ] && echo_date "'__is_int' accepts 1 argument; got $#" && return 1
	if printf '%s\n' "$1" | grep -Eq '^-?[0-9]+$'; then
		true
	else
		false
	fi
}
