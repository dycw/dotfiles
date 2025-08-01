#!/usr/bin/env sh
# shellcheck disable=SC2120,SC2317

# echo
echo_date() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"; }

# git
if command -v git >/dev/null 2>&1; then
	# add
	ga() {
		if [ $# -eq 0 ]; then
			git add -A || return $?
		else
			git add "$@" || return $?
		fi
	}
	gap() {
		if [ $# -eq 0 ]; then
			git add -pA || return $?
		else
			git add -p "$@" || return $?
		fi
	}
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
			echo_date "'__git_add_commit_push' requires at least 3 arguments" && return 1
		fi
		__no_verify="$1"
		__force="$2"
		__web="$3"
		shift 3

		__count_file=0
		__count_non_file=0
		__message=""
		__file_names=""
		__file_args=""

		for arg in "$@"; do
			if [ "${__count_non_file}" -eq 0 ] && { [ -f "$arg" ] || [ -d "$arg" ]; }; then
				__file_args="${__file_args} \"$arg\""
				__file_names="${__file_names}${__file_names:+ }$arg"
				__count_file=$((__count_file + 1))
			else
				__count_non_file=$((__count_non_file + 1))
				__message="$arg"
			fi
		done

		__file_list=""
		for f in ${__file_names}; do
			__file_list="${__file_list}'${f}',"
		done
		__file_list="${__file_list%,}"

		if [ "${__count_file}" -eq 0 ] && [ "${__count_non_file}" -eq 0 ]; then
			ga
			if ! __git_commit_push "${__no_verify}" "" "${__force}" "${__web}"; then
				ga
				__git_commit_push "${__no_verify}" "" "${__force}" "${__web}"
			fi
		elif [ "${__count_file}" -eq 0 ] && [ "${__count_non_file}" -eq 1 ]; then
			ga
			if ! __git_commit_push "${__no_verify}" "${__message}" "${__force}" "${__web}"; then
				ga
				__git_commit_push "${__no_verify}" "${__message}" "${__force}" "${__web}"
			fi
		elif [ "${__count_file}" -ge 1 ] && [ "${__count_non_file}" -eq 0 ]; then
			eval "ga ${__file_args}"
			__git_commit_push "${__no_verify}" "" "${__force}" "${__web}"
		elif [ "${__count_file}" -ge 1 ] && [ "${__count_non_file}" -eq 1 ]; then
			eval "ga ${__file_args}"
			__git_commit_push "${__no_verify}" "${__message}" "${__force}" "${__web}"
		else
			echo_date "'__git_add_commit_push' accepts any number of files followed by [0..1] messages; got ${__count_file} file(s) ${__file_list:-'(none)'} and ${__count_non_file} message(s)" && return 1
		fi
	}
	# branch
	gb() {
		if [ $# -ne 0 ]; then
			echo_date "'gb' accepts no arguments" && return 1
		fi
		git branch -alv --sort=-committerdate
	}
	gbd() {
		if [ $# -eq 0 ]; then
			__branch="$(__select_local_branch)"
		elif [ $# -eq 1 ]; then
			__branch="$1"
		else
			echo_date "'gbd' accepts [0..1] arguments" && return 1
		fi
		if __branch_exists "${__branch}"; then
			git branch -D "${__branch}"
		fi
	}
	gbdr() {
		if [ $# -eq 0 ]; then
			__branch="$(__select_remote_branch)"
		elif [ $# -eq 1 ]; then
			__branch="$1"
		else
			echo_date "'gbdr' accepts [0..1] arguments" && return 1
		fi
		gf
		git push origin -d "${__branch}"
	}
	gbm() { git branch -m "$1"; }
	__delete_gone_branches() {
		git branch -vv | awk '/: gone]/{print $1}' | xargs -r git branch -D
	}
	__select_local_branch() {
		git branch --format="%(refname:short)" | fzf
	}
	__select_remote_branch() {
		git branch -r --color=never | awk '!/->/' | fzf | sed -E 's|^[[:space:]]*origin/||'
	}
	# checkout
	gcm() {
		if [ $# -ne 0 ]; then
			echo_date "'gcm' accepts no arguments" && return 1
		fi
		gco master
	}
	gcmd() {
		if [ $# -ne 0 ]; then
			echo_date "'gcmd' accepts no arguments" && return 1
		fi
		if __is_current_branch_master; then
			gcof
			gcm
		else
			__branch="$(current_branch)"
			gcof
			gcm
			gbd "${__branch}"
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
		git checkout "${__branch}"
		gpl
	}
	gcob() {
		unset __title __num __desc
		if [ $# -eq 0 ]; then
			if ! __is_current_branch_master; then
				echo_date "'gcob' off 'master' requires 1 argument 'branch'" && return 1
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
		gf
		git checkout -b "${__branch}" origin/master
		if (command -v gh >/dev/null 2>&1) && [ $# -eq 1 ] && [ -n "${__title}" ]; then
			gp
			__git_commit_empty_auto_message
			gp
			ghc "${__title}"
		elif (command -v gh >/dev/null 2>&1) && [ $# -eq 2 ] && [ -n "${__title}" ] && [ -n "${__num}" ]; then
			gp
			__git_commit_empty_auto_message
			gp
			ghc "${__title}" "${__num}"
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
			gf
			git checkout -b "${__branch}" -t "origin/${__branch}"
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
				git checkout "${__branch}" -- "$@" || return $?
			else
				git checkout -- "$@" || return $?
			fi
		fi
	}
	gcofm() {
		if [ $# -eq 0 ]; then
			echo_date "'gcofm' requires [1..] arguments" && return 1
		fi
		gcof origin/master "$@" || return $?
	}
	gcop() {
		git checkout --patch "$@" && return 1
	}
	__to_valid_branch() {
		echo "$1" |
			tr '[:upper:]' '[:lower:]' |
			sed -E 's/[^a-z0-9]+/-/g' |
			sed -E 's/^-+|-+$//g' |
			cut -c1-80
	}
	# checkout + branch
	gbr() {
		if [ $# -ne 0 ]; then
			echo_date "'gbr' accepts no arguments" && return 1
		elif __is_current_branch_master; then
			echo_date "'gbr' cannot be run on master" && return 1
		else
			__gbr_branch="$(current_branch)" # do not name '__branch'
			gcof
			gcm
			gcob "${__gbr_branch}"
		fi
	}
	# cherry-pick
	gcp() { git cherry-pick "$@"; }
	# clone
	gcl() {
		if [ $# -eq 0 ] || [ $# -ge 3 ]; then
			echo_date "'gcl' accepts [1..2] arguments" && return 1
		fi
		git clone --recurse-submodules "$@"
	}
	# commit
	__git_commit() {
		if [ $# -ne 2 ]; then
			echo_date "'__git_commit' requires 2 arguments" && return 1
		fi
		__no_verify="$1"
		__message="$2"
		if [ -z "${__message}" ]; then
			__message="$(__git_commit_auto_message)"
		fi
		if [ "${__no_verify}" -eq 0 ]; then
			git commit -m "${__message}"
		elif [ "${__no_verify}" -eq 1 ]; then
			git commit --no-verify -m "${__message}"
		else
			echo_date "'_' accepts {0, 1} for the 'no-verify' flag; got ${__no_verify}" && return 1
		fi
	}
	__git_commit_auto_message() {
		echo "<${USER}/$(hostname)/$(date +"%Y%m%dT%H%M%S (%a)")>"
	}
	__git_commit_empty_auto_message() {
		git commit --allow-empty -m "$(__git_commit_auto_message)" --no-verify
	}
	# commit + push
	gc() {
		if [ $# -le 1 ]; then
			__git_commit_push 0 "${1:-}" 0 0 || return $?
		else
			echo_date "'gc' accepts [0..1] arguments" && return 1
		fi
	}
	gcn() {
		if [ $# -le 1 ]; then
			__git_commit_push 1 "${1:-}" 0 0 || return $?
		else
			echo_date "'gcn' accepts [0..1] arguments" && return 1
		fi
	}
	gcf() {
		if [ $# -le 1 ]; then
			__git_commit_push 0 "${1:-}" 1 0 || return $?
		else
			echo_date "'gcf' accepts [0..1] arguments" && return 1
		fi
	}
	gcnf() {
		if [ $# -le 1 ]; then
			__git_commit_push 1 "${1:-}" 1 0 || return $?
		else
			echo_date "'gcnf' accepts [0..1] arguments" && return 1
		fi
	}
	gcw() {
		if [ $# -le 1 ]; then
			__git_commit_push 0 "${1:-}" 0 1 || return $?
		else
			echo_date "'gcw' accepts [0..1] arguments" && return 1
		fi
	}
	gcnw() {
		if [ $# -le 1 ]; then
			__git_commit_push 1 "${1:-}" 0 1 || return $?
		else
			echo_date "'gcnw' accepts [0..1] arguments" && return 1
		fi
	}
	gcfw() {
		if [ $# -le 1 ]; then
			__git_commit_push 0 "${1:-}" 1 1 || return $?
		else
			echo_date "'gcfw' accepts [0..1] arguments" && return 1
		fi
	}
	gcnfw() {
		if [ $# -le 1 ]; then
			__git_commit_push 1 "${1:-}" 1 1 || return $?
		else
			echo_date "'gcnfw' accepts [0..1] arguments" && return 1
		fi
	}
	__git_commit_push() {
		if [ "$#" -eq 4 ]; then
			__git_commit_push_no_verify="$1"
			__git_commit_push_message="$2"
			__git_commit_push_force="$3"
			__git_commit_push_web="$4"
			__git_commit "${__git_commit_push_no_verify}" "${__git_commit_push_message}" || return $?
			__git_push "${__git_commit_push_force}" "${__git_commit_push_web}" || return $?
		else
			echo_date "'__git_commit_push' requires 4 arguments" && return 1
		fi
	}
	# diff
	gd() { git diff "$@"; }
	gdc() { git diff --cached "$@"; }
	gdm() { git diff origin/master "$@"; }
	# fetch
	gf() {
		if [ $# -eq 0 ]; then
			git fetch --all --force && __delete_gone_branches || return $?
		else
			echo_date "'gf' accepts no arguments" && return 1
		fi
	}
	# log
	gl() {
		if [ $# -eq 0 ]; then
			git log --abbrev-commit --decorate=short --pretty=format:'%C(red)%h%C(reset) |%C(yellow)%d%C(reset) | %s | %Cgreen%cr%C(reset)' || return $?
		else
			echo_date "'gl' accepts no arguments" && return 1
		fi
	}
	# merge
	gma() {
		if [ $# -eq 0 ]; then
			git merge --abort || return $?
		else
			echo_date "'gma' requires 0 arguments" && return 1
		fi
	}
	# mv
	gmv() {
		if [ $# -eq 2 ]; then
			git mv "$1" "$2" || return $?
		else
			echo_date "'gmv' requires 2 arguments" && return 1
		fi
	}
	# pull
	gpl() {
		if [ $# -eq 0 ]; then
			git pull --force || return $?
			gf || return $?
		else
			echo_date "'gpl' accepts no arguments" && return 1
		fi
	}
	# push
	gp() {
		if [ $# -eq 0 ]; then
			__git_push 0 0 || return $?
		else
			echo_date "'gp' accepts no arguments" && return 1
		fi
	}
	gpf() {
		if [ $# -eq 0 ]; then
			__git_push 1 0 || return $?
		else
			echo_date "'gpf' accepts no arguments" && return 1
		fi
	}
	gpw() {
		if [ $# -eq 0 ]; then
			__git_push 0 1 || return $?
		else
			echo_date "'gpw' accepts no arguments" && return 1
		fi
	}
	gpfw() {
		if [ $# -eq 0 ]; then
			__git_push 1 1 || return $?
		else
			echo_date "'gpfw' accepts no arguments" && return 1
		fi
	}
	__git_push() {
		if [ $# -eq 2 ]; then
			__git_push_force="$1"
			__git_push_web="$2"
			__git_push_current_branch "${__git_push_force}" || return $?
			if [ "${__git_push_web}" -eq 0 ]; then
				:
			elif [ "${__git_push_web}" -eq 1 ]; then
				gw || return $?
			else
				echo_date "'__git_push' accepts {0, 1} for the 'web' flag; got ${__git_push_web}" && return 1
			fi
		else
			echo_date "'__git_push' requires 2 arguments" && return 1
		fi
	}
	__git_push_current_branch() {
		if [ $# -eq 1 ]; then
			__git_push_current_branch_force="$1"
			if [ "${__git_push_force}" -eq 0 ]; then
				git push -u origin "$(current_branch)" || return $?
			elif [ "${__git_push_force}" -eq 1 ]; then
				git push -fu origin "$(current_branch)" || return $?
			else
				echo_date "'__git_push_current_branch' accepts {0, 1} for the 'force' flag; got ${__git_push_current_branch_force}" && return 1
			fi
		else
			echo_date "'__git_push_current_branch' requires 1 arguments" && return 1
		fi
	}
	# rebase
	grb() {
		unset __grb_branch
		if [ $# -eq 0 ]; then
			__grb_branch='origin/master'
		elif [ $# -eq 1 ]; then
			__grb_branch="$1"
		else
			echo_date "'grb' accepts [0..1] arguments" && return 1
		fi
		gf || return $?
		git rebase -s recursive -X theirs "${__grb_branch}" || return $?
	}
	grba() {
		if [ $# -eq 0 ]; then
			git rebase --abort || return $?
		else
			echo_date "'grba' accepts no arguments" && return 1
		fi
	}
	grbc() {
		if [ $# -eq 0 ]; then
			git rebase --continue || return $?
		else
			echo_date "'grbc' accepts no arguments" && return 1
		fi
	}
	grbs() {
		if [ $# -eq 0 ]; then
			git rebase --skip || return $?
		else
			echo_date "'grbs' accepts no arguments" && return 1
		fi
	}
	# rebase (squash)
	gsqm() {
		gf || return $?
		git reset --soft "$(git merge-base HEAD master)" || return $?
		gcf "$@" || return $?
	}
	# reset
	alias gr='git reset'
	alias grp='git reset --patch'
	# rev-parse
	current_branch() {
		if [ $# -eq 0 ]; then
			git rev-parse --abbrev-ref HEAD || return $?
		else
			echo_date "'current_branch' accepts no arguments" && return 1
		fi
	}
	repo_root() {
		if [ $# -eq 0 ]; then
			git rev-parse --show-toplevel || return $?
		else
			echo_date "'repo_root' accepts no arguments" && return 1
		fi
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
	alias grm='git rm'
	alias grmc='git rm --cached'
	alias grmf='git rm -f'
	alias grmr='git rm -r'
	alias grmrf='git rm -rf'
	# show-ref
	__is_valid_ref() {
		git show-ref --verify --quiet "refs/heads/$1" ||
			git show-ref --verify --quiet "refs/remotes/$1" ||
			git show-ref --verify --quiet "refs/tags/$1" ||
			git rev-parse --verify --quiet "$1" >/dev/null
	}
	# status
	gs() {
		if [ $# -eq 0 ]; then
			git status || return $?
		elif [ $# -eq 1 ]; then
			git status "$1" || return $?
		else
			echo_date "'gs' accepts [0..1] arguments" && return 1
		fi
	}
	__tree_is_clean() { [ -z "$(git status --porcelain)" ]; }
	# stash
	alias gst='git stash'
	alias gstd='git stash drop'
	alias gstp='git stash pop'
	# tag
	gta() { git tag -a "$1" "$2" -m "$1" && git push -u origin --tags; }
	gtd() { git tag -d "$@" && git push -d origin "$@"; }
fi

# gh
if command -v gh >/dev/null 2>&1; then
	ghc() {
		if [ $# -le 2 ]; then
			__gh_pr_create_or_edit create "${1:-}" "${2:-}" 0 || return $?
		else
			echo_date "'ghc' accepts [0..2] arguments" && return 1
		fi
	}
	ghcv() {
		if [ $# -le 2 ]; then
			__gh_pr_create_or_edit create "${1:-}" "${2:-}" 1 || return $?
		else
			echo_date "'ghcv' accepts [0..2] arguments" && return 1
		fi
	}
	ghcm() {
		if [ $# -ge 1 ] && [ $# -le 2 ]; then
			ghc "$@" || return $?
			ghm || return $?
		else
			echo_date "'ghcm' accepts [1..2] arguments" && return 1
		fi
	}
	ghe() {
		if [ $# -ge 1 ] && [ $# -le 2 ]; then
			__gh_pr_create_or_edit edit "${1:-}" "${2:-}" 0 || return $?
		else
			echo_date "'ghe' accepts [1..2] arguments" && return 1
		fi
	}
	ghev() {
		if [ $# -ge 1 ] && [ $# -le 2 ]; then
			__gh_pr_create_or_edit edit "${1:-}" "${2:-}" 1 || return $?
		else
			echo_date "'ghev' accepts [1..2] arguments" && return 1
		fi
	}
	ghic() {
		if [ $# -eq 1 ]; then
			gh issue create -t="$1" -b='.' || return $?
		elif [ $# -eq 2 ]; then
			gh issue create -t="$1" -l="$2" -b='.' || return $?
		elif [ $# -eq 3 ]; then
			gh issue create -t="$1" -l="$2" -b="$3" || return $?
		else
			echo_date "'ghic' accepts [1..3] arguments" && return 1
		fi
	}
	ghil() {
		if [ $# -eq 0 ]; then
			gh issue list || return $?
		else
			echo_date "'ghil' accepts no arguments" && return 1
		fi
	}
	ghiv() {
		unset __ghiv_branch __ghiv_num
		if [ $# -eq 0 ]; then
			__ghiv_branch="$(current_branch)" || return $?
			__ghiv_num="${__ghiv_branch%%-*}"
			if [ "${__ghiv_num}" -eq "${__ghiv_num}" ] 2>/dev/null; then
				gh issue view "${__ghiv_num}" -w || return $?
			else
				echo_date "'ghiv' cannot be run on a branch without an issue number" && return 1
			fi
		elif [ $# -eq 1 ]; then
			__ghiv_num="$1"
			if [ "$1" -eq "$1" ] 2>/dev/null; then
				gh issue view "$1" -w || return $?
			else
				echo_date "'ghiv' requries an integer" && return 1
			fi
		else
			echo_date "'ghiv' accepts [0..1] arguments" && return 1
		fi

	}
	ghm() {
		if [ $# -eq 0 ]; then
			__gh_pr_merge 0 0 || return $?
		else
			echo_date "'ghm' accepts no arguments" && return 1
		fi
	}
	ghmd() {
		if [ $# -eq 0 ]; then
			__gh_pr_merge 1 0 || return $?
		else
			echo_date "'ghmd' accepts no arguments" && return 1
		fi
	}
	ghmv() {
		if [ $# -eq 0 ]; then
			__gh_pr_merge 0 1 || return $?
		else
			echo_date "'ghmv' accepts no arguments" && return 1
		fi
	}
	ghmdv() {
		if [ $# -eq 0 ]; then
			__gh_pr_merge 1 1 || return $?
		else
			echo_date "'ghmdv' accepts no arguments" && return 1
		fi
	}
	ghv() {
		if [ $# -eq 0 ]; then
			if gh pr ready >/dev/null 2>&1; then
				gh pr view -w || return $?
			else
				echo_date "'ghv' cannot find an open PR" && return 1
			fi
		else
			echo_date "'ghv' accepts no arguments" && return 1
		fi
	}
	__gh_pr_create_or_edit() {
		if [ $# -eq 4 ]; then
			__gh_pr_create_or_edit_verb="$1"
			__gh_pr_create_or_edit_title="$2"
			__gh_pr_create_or_edit_body="$3"
			__gh_pr_create_or_edit_web="$4"
			if [ -z "${__gh_pr_create_or_edit_title}" ]; then
				__gh_pr_create_or_edit_title="Created by ${USER}@$(hostname) at $(date +"%Y-%m-%d %H:%M:%S (%a)")"
			fi
			if [ -n "${__gh_pr_create_or_edit_body}" ] && __is_int "${__gh_pr_create_or_edit_body}"; then
				__gh_pr_create_or_edit_body="Closes #${__gh_pr_create_or_edit_body}"
			fi
			gh pr "${__gh_pr_create_or_edit_verb}" -t="${__gh_pr_create_or_edit_title}" -b="${__gh_pr_create_or_edit_body}" || return $?
			if [ "${__gh_pr_create_or_edit_web}" -eq 0 ]; then
				:
			elif [ "${__gh_pr_create_or_edit_web}" -eq 1 ]; then
				ghv || return $?
			else
				echo_date "'__gh_pr_create_or_edit_web' accepts {0, 1} for the 'web' flag; got ${__gh_pr_create_or_edit_web}" && return 1
			fi
		else
			echo_date "'__gh_pr_create_or_edit_web' requires 4 arguments" && return 1
		fi
	}
	__gh_pr_merge() {
		if [ $# -eq 2 ]; then
			__gh_pr_merge_delete="$1"
			__gh_pr_merge_view="$2"
			__gh_pr_merge_branch="$(current_branch)"
			gh pr merge -s --auto || return $?
			if [ "${__gh_pr_merge_delete}" -eq 0 ]; then
				:
			elif [ "${__gh_pr_merge_delete}" -eq 1 ]; then
				if __branch_exists __gh_pr_merge_branch; then
					gcmd || return $?
				fi
			else
				echo_date "'__gh_pr_merge' accepts {0, 1} for the 'delete' flag; got ${__gh_pr_merge_delete}" && return 1
			fi
			if [ "${__gh_pr_merge_view}" -eq 0 ]; then
				:
			elif [ "${__gh_pr_merge_view}" -eq 1 ]; then
				ghv || return $?
			else
				echo_date "'__git_pr_merge' accepts {0, 1} for the 'view' flag; got ${__gh_pr_merge_view}" && return 1
			fi
		else
			echo_date "'__gh_pr_merge' requires 2 arguments" && return 1
		fi
	}
fi

# gh + gitweb
if command -v gh >/dev/null 2>&1 && command -v gitweb >/dev/null 2>&1; then
	gw() {
		if [ $# -eq 0 ]; then
			if gh pr ready >/dev/null 2>&1; then
				ghv || return $?
			else
				gitweb || return $?
			fi
		else
			echo_date "'gw' accepts no arguments" && return 1
		fi
	}
fi

# git + gh
if command -v git >/dev/null 2>&1 && command -v gh >/dev/null 2>&1; then
	gacc() {
		if [ $# -le 2 ]; then
			__git_add_gh_pr_create "${1:-}" "${2:-}" 0 || return $?
		else
			echo_date "'gacc' accepts [0..2] arguments" && return 1
		fi
	}
	gaccv() {
		if [ $# -le 2 ]; then
			__git_add_gh_pr_create "${1:-}" "${2:-}" 1 || return $?
		else
			echo_date "'gaccv' accepts [0..2] arguments" && return 1
		fi
	}
	gaccmd() {
		if [ $# -ge 1 ] && [ $# -le 2 ]; then
			gac || return $?
			ghc "$@" || return $?
			ghm || return $?
			gcmd || return $?
		else
			echo_date "'gaccmd' accepts [1..2] arguments" && return 1
		fi
	}
	__git_add_gh_pr_create() {
		if [ $# -eq 3 ]; then
			__git_add_gh_pr_create_first="$1"
			__git_add_gh_pr_create_second="$2"
			__git_add_gh_pr_create_view="$3"
			gac || return $?
			if [ -z "${__git_add_gh_pr_create_first}" ] && [ -z "${__git_add_gh_pr_create_second}" ]; then
				ghc || return $?
			elif [ -n "${__git_add_gh_pr_create_first}" ] && [ -z "${__git_add_gh_pr_create_second}" ]; then
				ghc "${__git_add_gh_pr_create_first}" || return $?
			elif [ -n "${__git_add_gh_pr_create_first}" ] && [ -n "${__git_add_gh_pr_create_second}" ]; then
				ghc "${__git_add_gh_pr_create_first}" "${__git_add_gh_pr_create_second}" || return $?
			else
				echo_date "'__git_add_gh_pr_create' is missing first but got second ${__git_add_gh_pr_create_second}" && return 1
			fi
			if [ "${__git_add_gh_pr_create_view}" -eq 0 ]; then
				:
			elif [ "${__git_add_gh_pr_create_view}" -eq 1 ]; then
				ghv || return $?
			else
				echo_date "'__git_add_gh_pr_create' accepts {0, 1} for the 'view' flag; got ${__git_add_gh_pr_create_view}" && return 1
			fi
		else
			echo_date "'__git_add_gh_pr_create' requires 3 arguments" && return 1
		fi
	}
fi

# git + watch
if command -v git >/dev/null 2>&1 && command -v watch >/dev/null 2>&1; then
	wgd() { watch -d -n 0.5 -- git diff "$@"; }
	wgl() { watch -d -n 0.5 -- git log --abbrev-commit --decorate=short --oneline; }
	wgs() { watch -d -n 0.5 -- git status "$@"; }
fi

# github + watch
if command -v gh >/dev/null 2>&1 && command -v watch >/dev/null 2>&1; then
	ghs() {
		if [ $# -eq 0 ]; then
			watch -d -n 1.0 'gh pr status' || return $?
		else
			echo_date "'ghs' accepts no arguments" && return 1
		fi
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
