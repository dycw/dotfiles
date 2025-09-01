#!/usr/bin/env sh
# shellcheck disable=SC2120,SC2317

# echo
echo_date() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"; }

# git
if command -v git >/dev/null 2>&1; then
	# add
	ga() {
		if [ $# -eq 0 ]; then
			git add -A
		else
			git add "$@"
		fi
	}
	gap() {
		if [ $# -eq 0 ]; then
			git add -pA
		else
			git add -p "$@"
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

		if [ "${__gacp_count_file}" -eq 0 ] && [ "${__gacp_count_non_file}" -eq 0 ]; then
			ga
			if ! __git_commit_push "${__gacp_no_verify}" "" "${__gacp_force}" "${__gacp_web}"; then
				ga
				__git_commit_push "${__gacp_no_verify}" "" "${__gacp_force}" "${__gacp_web}"
			fi
		elif [ "${__gacp_count_file}" -eq 0 ] && [ "${__gacp_count_non_file}" -eq 1 ]; then
			ga
			if ! __git_commit_push "${__gacp_no_verify}" "${__gacp_message}" "${__gacp_force}" "${__gacp_web}"; then
				ga
				__git_commit_push "${__gacp_no_verify}" "${__gacp_message}" "${__gacp_force}" "${__gacp_web}"
			fi
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
			echo_date "'gb' accepts no arguments" && return 1
		fi
		git branch -alv --sort=-committerdate
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
			git branch -D "${__gbd_branch}"
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
		gf && git push origin -d "${__gbdr_branch}"
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
			gcof && gcm
		else
			__gcmd_branch="$(current_branch)"
			gcof && gcm && gbd "${__gcmd_branch}"
		fi
	}
	gco() {
		if [ $# -eq 0 ]; then
			__gco_branch="$(__select_local_branch)"
		elif [ $# -eq 1 ]; then
			__gco_branch="$1"
		else
			echo_date "'gco' accepts [0..1] arguments" && return 1
		fi
		git checkout "${__gco_branch}" && gpl
	}
	gcob() {
		if [ $# -eq 0 ]; then
			if ! __is_current_branch_master; then
				echo_date "'gcob' off 'master' accepts 1 argument" && return 1
			fi
			unset __gcob_title __gcob_num __gcob_desc
			__gcob_branch='dev'
		elif [ $# -eq 1 ]; then
			unset __gcob_num __gcob_desc
			__gcob_title="$1"
			__gcob_branch="$(__to_valid_branch "${__gcob_title}")"
		elif [ $# -eq 2 ]; then
			__gcob_title="$1"
			__gcob_num="$2"
			__gcob_desc="$(__to_valid_branch "${__gcob_title}")"
			__gcob_branch="$2-${__gcob_desc}"
		else
			echo_date "'gcob' accepts [0..2] arguments" && return 1
		fi
		gf && git checkout -b "${__gcob_branch}" origin/master && return $?
		if (command -v gh >/dev/null 2>&1) && [ $# -eq 1 ] && [ -n "${__gcob_title}" ]; then
			gp && __git_commit_empty_auto_message && gp && ghc "${__gcob_title}"
		elif (command -v gh >/dev/null 2>&1) && [ $# -eq 2 ] && [ -n "${__gcob_title}" ] && [ -n "${__gcob_num}" ]; then
			gp && __git_commit_empty_auto_message && gp && ghc "${__gcob_title}" "${__gcob_num}"
		fi
	}
	gcobt() {
		if [ $# -eq 0 ]; then
			__gcobt_branch="$(__select_remote_branch)"
		elif [ $# -eq 1 ]; then
			__gcobt_branch="$1"
		else
			echo_date "'gcobt' accepts [0..1] arguments" && return 1
		fi
		if __is_current_branch_master; then
			gf && git checkout -b "${__gcobt_branch}" -t "origin/${__gcobt_branch}"
		else
			gco master
		fi
	}
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
		if [ $# -eq 0 ]; then
			echo_date "'gcofm' accepts [1..] arguments" && return 1
		fi
		gcof origin/master "$@"
	}
	gcop() {
		git checkout --patch "$@"
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
			__gbr_branch="$(current_branch)"
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
		__gc_no_verify="$1"
		__gc_message="$2"
		if [ -z "${__gc_message}" ]; then
			__gc_message="$(__git_commit_auto_message)"
		fi
		if [ "${__gc_no_verify}" -eq 0 ]; then
			git commit -m "${__gc_message}"
		elif [ "${__gc_no_verify}" -eq 1 ]; then
			git commit --no-verify -m "${__gc_message}"
		else
			echo_date "'_' accepts {0, 1} for the 'no-verify' flag; got ${__gc_no_verify}" && return 1
		fi
	}
	__git_commit_auto_message() {
		echo "$(date +"%Y-%m-%d %H:%M:%S (%a)") > $(hostname) > ${USER}"
	}
	__git_commit_empty_auto_message() {
		git commit --allow-empty -m "$(__git_commit_auto_message)" --no-verify
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
			echo_date "'gf' accepts no arguments" && return 1
		fi
		git fetch --all --force && __delete_gone_branches
	}
	# log
	gl() {
		if [ $# -ne 0 ]; then
			echo_date "'gl' accepts no arguments" && return 1
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
			echo_date "'gpl' accepts no arguments" && return 1
		fi
		git pull --force
		gf
	}
	# push
	gp() {
		if [ $# -ne 0 ]; then
			echo_date "'gp' accepts no arguments" && return 1
		fi
		__git_push 0 0
	}
	gpf() {
		if [ $# -ne 0 ]; then
			echo_date "'gpf' accepts no arguments" && return 1
		fi
		__git_push 1 0
	}
	gpw() {
		if [ $# -ne 0 ]; then
			echo_date "'gpw' accepts no arguments" && return 1
		fi
		__git_push 0 1
	}
	gpfw() {
		if [ $# -ne 0 ]; then
			echo_date "'gpfw' accepts no arguments" && return 1
		fi
		__git_push 1 1
	}
	__git_push() {
		if [ $# -ne 2 ]; then
			echo_date "'__git_push' accepts 2 arguments" && return 1
		fi
		__git_push_force="$1"
		__git_push_web="$2"
		__git_push_current_branch "${__git_push_force}" || return $?
		if [ "${__git_push_web}" -eq 0 ]; then
			:
		elif [ "${__git_push_web}" -eq 1 ]; then
			gw
		else
			echo_date "'__git_push' accepts {0, 1} for the 'web' flag; got ${__git_push_web}" && return 1
		fi
	}
	__git_push_current_branch() {
		if [ $# -ne 1 ]; then
			echo_date "'__git_push_current_branch' accepts 1 argument" && return 1
		fi
		__git_push_current_branch_force="$1"
		if [ "${__git_push_force}" -eq 0 ]; then
			git push -u origin "$(current_branch)"
		elif [ "${__git_push_force}" -eq 1 ]; then
			git push -fu origin "$(current_branch)"
		else
			echo_date "'__git_push_current_branch' accepts {0, 1} for the 'force' flag; got ${__git_push_current_branch_force}" && return 1
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
		gf && git rebase -s recursive -X theirs "${__grb_branch}"
	}
	grba() {
		if [ $# -ne 0 ]; then
			echo_date "'grba' accepts no arguments" && return 1
		fi
		git rebase --abort
	}
	grbc() {
		if [ $# -ne 0 ]; then
			echo_date "'grbc' accepts no arguments" && return 1
		fi
		git rebase --continue
	}
	grbs() {
		if [ $# -ne 0 ]; then
			echo_date "'grbs' accepts no arguments" && return 1
		fi
		git rebase --skip
	}
	# rebase (squash)
	gsqm() { gf && git reset --soft "$(git merge-base HEAD master)" && gcf "$@"; }
	# reset
	gr() { git reset "$@"; }
	grp() { git reset --patch "$@"; }
	# rev-parse
	current_branch() {
		if [ $# -ne 0 ]; then
			echo_date "'current_branch' accepts no arguments" && return 1
		fi
		git rev-parse --abbrev-ref HEAD
	}
	repo_root() {
		if [ $# -ne 0 ]; then
			echo_date "'repo_root' accepts no arguments" && return 1
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
			echo_date "'__tree_is_clean' accepts no arguments" && return 1
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
			echo_date "'gsub_update' accepts no arguments" && return 1
		fi
		git submodule foreach --recursive 'git checkout master && git pull --ff-only'
	}
	# tag
	gta() {
		if [ $# -ne 2 ]; then
			echo_date "'gta' accepts 2 arguments" && return 1
		fi
		__gta_tag="$1"
		__gta_sha="$2"
		git tag -a "${__gta_tag}" "${__gta_sha}" -m "${__gta_tag}" &&
			git push -u origin --tags
	}
	gtd() { git tag -d "$@" && git push -d origin "$@"; }
fi

# gh
if command -v gh >/dev/null 2>&1; then
	ghc() {
		if [ $# -ge 3 ]; then
			echo_date "'ghc' accepts [0..2] arguments" && return 1
		fi
		__gh_pr_create_or_edit create "${1:-}" "${2:-}" 0
	}
	ghcv() {
		if [ $# -ge 2 ]; then
			echo_date "'ghcv' accepts [0..2] arguments" && return 1
		fi
		__gh_pr_create_or_edit create "${1:-}" "${2:-}" 1
	}
	ghcm() {
		if [ $# -eq 0 ] || [ $# -ge 3 ]; then
			echo_date "'ghcm' accepts [1..2] arguments" && return 1
		fi
		ghc "$@" && ghm
	}
	ghe() {
		if [ $# -eq 0 ] || [ $# -ge 3 ]; then
			echo_date "'ghe' accepts [1..2] arguments" && return 1
		fi
		__gh_pr_create_or_edit edit "${1:-}" "${2:-}" 0
	}
	ghev() {
		if [ $# -eq 0 ] || [ $# -ge 3 ]; then
			echo_date "'ghev' accepts [1..2] arguments" && return 1
		fi
		__gh_pr_create_or_edit edit "${1:-}" "${2:-}" 1
	}
	ghic() {
		if [ $# -eq 1 ]; then
			gh issue create -t="$1" -b='.'
		elif [ $# -eq 2 ]; then
			gh issue create -t="$1" -l="$2" -b='.'
		elif [ $# -eq 3 ]; then
			gh issue create -t="$1" -l="$2" -b="$3"
		else
			echo_date "'ghic' accepts [1..3] arguments" && return 1
		fi
	}
	ghil() {
		if [ $# -ne 0 ]; then
			echo_date "'ghil' accepts no arguments" && return 1
		fi
		gh issue list
	}
	ghiv() {
		if [ $# -eq 0 ]; then
			__ghiv_branch="$(current_branch)"
			__ghiv_num="${__ghiv_branch%%-*}"
			if [ "${__ghiv_num}" -eq "${__ghiv_num}" ] 2>/dev/null; then
				gh issue view "${__ghiv_num}" -w
			else
				echo_date "'ghiv' cannot be run on a branch without an issue number" && return 1
			fi
		elif [ $# -eq 1 ]; then
			unset __ghiv_branch
			__ghiv_num="$1"
			if [ "${__ghiv_num}" -eq "${__ghiv_num}" ] 2>/dev/null; then
				gh issue view "${__ghiv_num}" -w
			else
				echo_date "'ghiv' requries an integer" && return 1
			fi
		else
			echo_date "'ghiv' accepts [0..1] arguments" && return 1
		fi

	}
	ghm() {
		if [ $# -ne 0 ]; then
			echo_date "'ghm' accepts no arguments" && return 1
		fi
		__gh_pr_merge 0 0
	}
	ghmd() {
		if [ $# -ne 0 ]; then
			echo_date "'ghmd' accepts no arguments" && return 1
		fi
		__gh_pr_merge 1 0
	}
	ghmv() {
		if [ $# -ne 0 ]; then
			echo_date "'ghmv' accepts no arguments" && return 1
		fi
		__gh_pr_merge 0 1
	}
	ghmdv() {
		if [ $# -ne 0 ]; then
			echo_date "'ghmdv' accepts no arguments" && return 1
		fi
		__gh_pr_merge 1 1
	}
	ghv() {
		if [ $# -ne 0 ]; then
			echo_date "'ghv' accepts no arguments" && return 1
		fi
		if gh pr ready >/dev/null 2>&1; then
			gh pr view -w
		else
			echo_date "'ghv' cannot find an open PR" && return 1
		fi
	}
	__gh_pr_create_or_edit() {
		if [ $# -ne 4 ]; then
			echo_date "'__gh_pr_create_or_edit_web' accepts 4 arguments" && return 1
		fi
		__gh_pr_ce_verb="$1"
		__gh_pr_ce_title="$2"
		__gh_pr_ce_body="$3"
		__gh_pr_ce_web="$4"
		if [ -z "${__gh_pr_ce_title}" ]; then
			__gh_pr_ce_title="Created by ${USER}@$(hostname) at $(date +"%Y-%m-%d %H:%M:%S (%a)")"
		fi
		if [ -n "${__gh_pr_ce_body}" ] && __is_int "${__gh_pr_ce_body}"; then
			__gh_pr_ce_body="Closes #${__gh_pr_ce_body}"
		fi
		gh pr "${__gh_pr_ce_verb}" -t="${__gh_pr_ce_title}" -b="${__gh_pr_ce_body}" || return $?
		if [ "${__gh_pr_ce_web}" -eq 0 ]; then
			:
		elif [ "${__gh_pr_ce_web}" -eq 1 ]; then
			ghv
		else
			echo_date "'__gh_pr_create_or_edit' accepts {0, 1} for the 'web' flag; got ${__gh_pr_ce_web}" && return 1
		fi
	}
	__gh_pr_merge() {
		if [ $# -ne 2 ]; then
			echo_date "'__gh_pr_merge' accepts 2 arguments" && return 1
		fi
		__gh_pr_m_delete="$1"
		__gh_pr_m_view="$2"
		__gh_pr_m_branch="$(current_branch)"
		gh pr merge -s --auto || return $?
		if [ "${__gh_pr_m_delete}" -eq 0 ]; then
			:
		elif [ "${__gh_pr_m_delete}" -eq 1 ]; then
			__gh_pr_await_merged "${__gl_mr_m_branch}" && gcmd || return $?
		else
			echo_date "'__gh_pr_merge' accepts {0, 1} for the 'delete' flag; got ${__gh_pr_m_delete}" && return 1
		fi
		if [ "${__gh_pr_m_view}" -eq 0 ]; then
			:
		elif [ "${__gh_pr_m_view}" -eq 1 ]; then
			ghv
		else
			echo_date "'__git_pr_merge' accepts {0, 1} for the 'view' flag; got ${__gh_pr_m_view}" && return 1
		fi
	}
	__gh_pr_merging() {
		__gh_pr_m_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || return 1
		if [ -z "${__gh_pr_m_branch}" ]; then
			return 1
		fi
		__gh_pr_m_json=$(gh pr view --json state 2>/dev/null) || return 1
		__gh_pr_m_state=$(printf "%s" "$__gh_pr_m_json" | jq -r '.state')
		if [ "${__gh_pr_m_state}" = 'CLOSED' ]; then
			return 1
		fi
		__gh_pr_m_repo=$(gh repo view --json nameWithOwner -q .nameWithOwner)
		if gh api "repos/${__gh_pr_m_repo}/branches/${__gh_pr_m_branch}" >/dev/null 2>&1; then
			return 0
		fi
		return 1
	}
	__gh_pr_await_merged() {
		if [ $# -ne 1 ]; then
			echo_date "'__gh_pr_await_merged' accepts 1 argument"
		fi
		while __gh_pr_merging; do
			echo_date "'$1' is still merging..."
			sleep 1
		done
		echo_date "'$1' has finished merging"
	}
fi

# gh + gitweb
if command -v gh >/dev/null 2>&1 && command -v gitweb >/dev/null 2>&1; then
	gw() {
		if [ $# -ne 0 ]; then
			echo_date "'gw' accepts no arguments" && return 1
		fi
		if gh pr ready >/dev/null 2>&1; then
			ghv
		else
			gitweb
		fi
	}
fi

# git + watch
if command -v git >/dev/null 2>&1 && command -v watch >/dev/null 2>&1; then
	wgd() { watch -d -n 0.5 -- git diff "$@"; }
	wgl() { watch -d -n 0.5 -- git log --abbrev-commit --decorate=short --oneline; }
	wgs() { watch -d -n 0.5 -- git status "$@"; }
fi

# git + gh
if command -v git >/dev/null 2>&1 && command -v gh >/dev/null 2>&1; then
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
		gac &&
			ghc "$@" &&
			ghm &&
			gcmd
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
			echo_date "'ghs' accepts no arguments" && return 1
		fi
		watch -d -n 1.0 'gh pr status'
	}
fi

# glab
if command -v glab >/dev/null 2>&1; then
	glc() {
		if [ $# -ne 1 ]; then
			echo_date "'glc' accepts 1 argument" && return 1
		fi
		glab mr create --description='.' --title "$1"
	}
	glm() {
		if [ $# -ne 0 ]; then
			echo_date "'glm' accepts 0 arguments" && return 1
		fi
		glab mr merge --remove-source-branch --squash --yes
	}
	glmd() {
		if [ $# -ne 0 ]; then
			echo_date "'glmd' accepts 0 arguments" && return 1
		fi
		__glmd_branch="$(current_branch)"
		glm && __gl_mr_await_merged "${__glmd_branch}" && gcmd
	}
	__gl_mr_merging() {
		__gl_mr_m_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || return 1
		if [ -z "${__gl_mr_m_branch}" ]; then
			return 1
		fi
		__gl_mr_m_json_all=$(glab mr list --source-branch "${__gl_mr_m_branch}" --output=json 2>/dev/null) || return 1
		__gl_mr_m_num=$(printf "%s" "${__gl_mr_m_json_all}" | jq 'length')
		if [ "${__gl_mr_m_num}" -ne 1 ]; then
			echo_date "'__gl_mr_merging' expects a unique MR" && return 1
		fi
		__gl_mr_m_json1=$(printf "%s" "${__gl_mr_m_json_all}" | jq '.[0]')
		__gl_mr_m_state=$(printf "%s" "${__gl_mr_m_json1}" | jq -r '.state')
		echo "__gl_mr_m_state=$__gl_mr_m_state"
		if [ "${__gl_mr_m_state}" != 'opened' ]; then
			echo "__gl_mr_m_state=$__gl_mr_m_state>>1"
			return 1
		fi
		if git ls-remote --exit-code origin "${__gl_mr_m_branch}" >/dev/null 2>&1; then
			return 0
		fi
		return 1
	}
	__gl_mr_await_merged() {
		if [ $# -ne 1 ]; then
			echo_date "'__gl_mr_await_merged' accepts 1 argument"
		fi
		while __gl_mr_merging; do
			echo_date "'$1' is still merging..."
			sleep 1
		done
		echo_date "'$1' has finished merging"
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
