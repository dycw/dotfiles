#!/usr/bin/env sh
# shellcheck disable=SC2120,SC2317

# echo
echo_date() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"; }

# git
if command -v git >/dev/null 2>&1; then
	# rev-parse
	__is_current_branch() {
		[ $# -ne 1 ] && echo_date "'__is_current_branch' accepts 1 argument; got $#" && return 1
		if [ "$(__current_branch)" = "$1" ]; then
			true
		else
			false
		fi
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
