#!/usr/bin/env sh

# shellcheck disable=SC2120,SC2317

if command -v git >/dev/null 2>&1; then
	# add
	ga() {
		if [ $# -eq 0 ]; then
			git add -A
		else
			git add "$@"
		fi
		return $?
	}
	gap() {
		if [ $# -eq 0 ]; then
			git add -pA
		else
			git add -p "$@"
		fi
	}
	# add + commit + push
	gac() {
		__git_add_commit_push 0 0 0 "$@"
		return $?
	}
	gacn() {
		__git_add_commit_push 1 0 0 "$@"
		return $?
	}
	gacf() {
		__git_add_commit_push 0 1 0 "$@"
		return $?
	}
	gacnf() {
		__git_add_commit_push 1 1 0 "$@"
		return $?
	}
	gacw() {
		__git_add_commit_push 0 0 1 "$@"
		return $?
	}
	gacnw() {
		__git_add_commit_push 1 0 1 "$@"
		return $?
	}
	gacfw() {
		__git_add_commit_push 0 1 1 "$@"
		return $?
	}
	gacnfw() {
		__git_add_commit_push 1 1 1 "$@"
		return $?
	}
	__git_add_commit_push() {
		if [ "$#" -ge 3 ]; then
			__git_acp_no_verify="$1"
			__git_acp_force="$2"
			__git_acp_gitweb="$3"
			shift 3

			__git_acp_count_file=0
			__git_acp_count_non_file=0
			__git_acp_message=""
			__git_acp_file_names=""
			__git_acp_file_args=""

			for arg in "$@"; do
				if [ "${__git_acp_count_non_file}" -eq 0 ] && { [ -f "$arg" ] || [ -d "$arg" ]; }; then
					__git_acp_file_args="${__git_acp_file_args} \"$arg\""
					__git_acp_file_names="${__git_acp_file_names}${__git_acp_file_names:+ }$arg"
					__git_acp_count_file=$((__git_acp_count_file + 1))
				else
					__git_acp_count_non_file=$((__git_acp_count_non_file + 1))
					__git_acp_message="$arg"
				fi
			done

			__git_acp_file_list=""
			for f in ${__git_acp_file_names}; do
				__git_acp_file_list="${__git_acp_file_list}'${f}',"
			done
			__git_acp_file_list="${__git_acp_file_list%,}"

			if [ "${__git_acp_count_file}" -eq 0 ] && [ "${__git_acp_count_non_file}" -eq 0 ]; then
				ga || return $?
				__git_commit_push "${__git_acp_no_verify}" "" "${__git_acp_force}" "${__git_acp_gitweb}" || {
					ga && __git_commit_push "${__git_acp_no_verify}" "" "${__git_acp_force}" "${__git_acp_gitweb}"
				}
				return $?
			elif [ "${__git_acp_count_file}" -eq 0 ] && [ "${__git_acp_count_non_file}" -eq 1 ]; then
				ga || return $?
				__git_commit_push "${__git_acp_no_verify}" "${__git_acp_message}" "${__git_acp_force}" "${__git_acp_gitweb}" || {
					ga && __git_commit_push "${__git_acp_no_verify}" "${__git_acp_message}" "${__git_acp_force}" "${__git_acp_gitweb}"
				}
				return $?
			elif [ "${__git_acp_count_file}" -ge 1 ] && [ "${__git_acp_count_non_file}" -eq 0 ]; then
				eval "ga ${__git_acp_file_args}" || return $?
				__git_commit_push "${__git_acp_no_verify}" "" "${__git_acp_force}" "${__git_acp_gitweb}"
				return $?
			elif [ "${__git_acp_count_file}" -ge 1 ] && [ "${__git_acp_count_non_file}" -eq 1 ]; then
				eval "ga ${__git_acp_file_args}" || return $?
				__git_commit_push "${__git_acp_no_verify}" "${__git_acp_message}" "${__git_acp_force}" "${__git_acp_gitweb}"
				return $?
			else
				echo "'__git_add_commit_push' accepts any number of files followed by [0..1] messages; got ${__git_acp_count_file} file(s) ${__git_acp_file_list:-'(none)'} and ${__git_acp_count_non_file} message(s)" >&2
				return 1
			fi
		else
			echo "'__git_add_commit_push' requires at least 3 arguments" >&2
			return 1
		fi
	}
	# branch
	gb() {
		if [ $# -eq 0 ]; then
			git branch -alv --sort=-committerdate
			return $?
		else
			echo "'gb' accepts no arguments"
			return 1
		fi
	}
	gbd() {
		unset __gbd_branch
		if [ $# -eq 0 ]; then
			if __is_current_branch_master; then
				__gbd_branch='dev'
			else
				echo "'gbd' off 'master' requires 1 argument 'branch'"
				return 1
			fi
		elif [ $# -eq 1 ]; then
			__gbd_branch="$1"
		else
			echo "'gbd' accepts [0..1] arguments"
			return 1
		fi
		git branch -D "${__gbd_branch}"
		return $?
	}
	gbdr() {
		unset __gbdr_branch
		if [ $# -eq 0 ]; then
			__gbdr_branch="$(__select_remote_branch)"
		elif [ $# -eq 1 ]; then
			__gbdr_branch="$1"
		else
			echo "'gbdr' accepts [0..1] arguments"
			return 1
		fi
		git push origin -d "${__gbdr_branch}"
		return $?
	}
	gbm() { git branch -m "$1"; }
	__select_remote_branch() {
		git branch -r --color=never | awk '!/->/' | fzf | sed -E 's|^[[:space:]]*origin/||'
	}
	# checkout
	gcm() {
		if [ $# -eq 0 ]; then
			gco master
			return $?
		else
			echo "'gcm' accepts no arguments"
			return 1
		fi
	}
	gcmd() {
		unset __gcmd_branch
		if [ $# -eq 0 ]; then
			if __is_current_branch_master; then
				echo "'gcmd' cannot be run on master"
				return 1
			else
				__gcmd_branch="$(__current_branch)"
				gcof && gco master && gbd "${__gcmd_branch}"
				return $?
			fi
		else
			echo "'gcmd' accepts no arguments"
			return 1
		fi
	}
	gco() {
		unset __gco_branch
		if [ $# -eq 0 ]; then
			if __is_current_branch_master; then
				__gco_branch='dev'
			elif __is_current_branch_dev; then
				__gco_branch='master'
			else
				echo "'gco' requires 1 argument 'branch'"
				return 1
			fi
		elif [ $# -eq 1 ]; then
			__gco_branch="$1"
		else
			echo "'gco' accepts [0..1] arguments"
			return 1
		fi
		git checkout "${__gco_branch}" && git pull --force
		return $?
	}
	gcob() {
		unset __gcob_branch
		if [ $# -eq 0 ]; then
			if __is_current_branch_master; then
				__gcob_branch='dev'
			else
				echo "'gcob' off 'master' requires 1 argument 'branch'"
				return 1
			fi
		elif [ $# -eq 1 ]; then
			__gcob_branch="$1"
		else
			echo "'gcob' accepts [0..1] arguments"
			return 1
		fi
		git checkout -b "${__gcob_branch}"
		return $?
	}
	gcobt() {
		unset __gcobt_branch
		if [ $# -eq 0 ]; then
			__gcobt_branch="$(__select_remote_branch)"
		elif [ $# -eq 1 ]; then
			__gcobt_branch="$1"
		else
			echo "'gcobt' accepts [0..1] arguments"
			return 1
		fi
		if ! __is_current_branch_master; then
			gco master
		fi
		git checkout -b "${__gcobt_branch}" -t "origin/${__gcobt_branch}"
		return $?
	}
	gcof() {
		unset __gcof_branch
		if [ $# -eq 0 ]; then
			git checkout -- .
			return $?
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
	gcop() {
		if [ $# -eq 0 ]; then
			git checkout --patch
			return $?
		else
			echo "'gcop' accepts no arguments"
			return 1
		fi
	}
	# checkout + branch
	gbr() {
		unset __gbr_branch
		if [ $# -eq 0 ]; then
			if __is_current_branch_master; then
				echo "'gcobr' cannot be run on master"
				return 1
			else
				__gbr_branch="$(__current_branch)"
				gcof && gco master && gbd "${__gbr_branch}" && gcob "${__gbr_branch}"
				return $?
			fi
		else
			echo "'gcobr' accepts [0..1] arguments"
			return
		fi
	}
	# cherry-pick
	gcp() {
		git cherry-pick "$@"
	}
	# clone
	gcl() {
		if [ $# -eq 1 ]; then
			git clone --recurse-submodules "$1"
		else
			echo "'gcl' accepts [0..1] arguments"
			return 1
		fi
	}
	# commit
	__git_commit() {
		if [ $# -eq 2 ]; then
			__git_commit_no_verify="$1"
			__git_commit_message="$2"
			if [ -z "${__git_commit_message}" ]; then
				__git_commit_message="$(__git_commit_auto_message)"
			fi
			if [ "${__git_commit_no_verify}" -eq 0 ]; then
				git commit -m "${__git_commit_message}"
				return $?
			elif [ "${__git_commit_no_verify}" -eq 1 ]; then
				git commit --no-verify -m "${__git_commit_message}"
				return $?
			else
				echo "'__git_commit' accepts {0, 1} for the 'no-verify' flag; got ${__git_commit_no_verify}"
				return 1
			fi
		else
			echo "'__git_commit' requires 2 arguments"
			return 1
		fi
	}
	__git_commit_auto_message() { echo "Commited by ${USER}@$(hostname) at $(date +"%Y-%m-%d %H:%M:%S (%a)")"; }
	# commit + push
	gc() {
		if [ $# -le 1 ]; then
			__git_commit_push 0 "${1:-}" 0 0
			return $?
		else
			echo "'gc' accepts [0..1] arguments"
			return 1
		fi
	}
	gcn() {
		if [ $# -le 1 ]; then
			__git_commit_push 1 "${1:-}" 0 0
			return $?
		else
			echo "'gcn' accepts [0..1] arguments"
			return 1
		fi
	}
	gcf() {
		if [ $# -le 1 ]; then
			__git_commit_push 0 "${1:-}" 1 0
			return $?
		else
			echo "'gcf' accepts [0..1] arguments"
			return 1
		fi
	}
	gcnf() {
		if [ $# -le 1 ]; then
			__git_commit_push 1 "${1:-}" 1 0
			return $?
		else
			echo "'gcnf' accepts [0..1] arguments"
			return 1
		fi
	}
	gcw() {
		if [ $# -le 1 ]; then
			__git_commit_push 0 "${1:-}" 0 1
			return $?
		else
			echo "'gcw' accepts [0..1] arguments"
			return 1
		fi
	}
	gcnw() {
		if [ $# -le 1 ]; then
			__git_commit_push 1 "${1:-}" 0 1
			return $?
		else
			echo "'gcnw' accepts [0..1] arguments"
			return 1
		fi
	}
	gcfw() {
		if [ $# -le 1 ]; then
			__git_commit_push 0 "${1:-}" 1 1
			return $?
		else
			echo "'gcfw' accepts [0..1] arguments"
			return 1
		fi
	}
	gcnfw() {
		if [ $# -le 1 ]; then
			__git_commit_push 1 "${1:-}" 1 1
			return $?
		else
			echo "'gcnfw' accepts [0..1] arguments"
			return 1
		fi
	}
	__git_commit_push() {
		if [ "$#" -eq 4 ]; then
			__git_commit_push_no_verify="$1"
			__git_commit_push_message="$2"
			__git_commit_push_force="$3"
			__git_commit_push_gitweb="$4"
			__git_commit "${__git_commit_push_no_verify}" "${__git_commit_push_message}" || return $?
			__git_push "${__git_commit_push_force}" "${__git_commit_push_gitweb}"
			return $?
		else
			echo "'__git_commit_push' requires 4 arguments"
			return 1
		fi
	}
	# diff
	gd() { git diff "$@"; }
	gdc() { git diff --cached "$@"; }
	gdm() { git diff origin/master "$@"; }
	# fetch
	gf() {
		if [ $# -eq 0 ]; then
			git fetch --all
			return $?
		else
			echo "'gf' accepts no arguments"
			return 1
		fi
	}
	# log
	gl() {
		if [ $# -eq 0 ]; then
			git log --abbrev-commit --decorate=short --pretty=format:'%C(red)%h%C(reset) |%C(yellow)%d%C(reset) | %s | %Cgreen%cr%C(reset)'
			return $?
		else
			echo "'gl' accepts no arguments"
			return 1
		fi
	}
	# mv
	gmv() {
		if [ $# -eq 2 ]; then
			git mv "$1" "$2"
			return $?
		else
			echo "'gmv' requires 2 arguments"
			return 1
		fi
	}
	# pull
	gpl() {
		if [ $# -eq 0 ]; then
			git pull --force
			return $?
		else
			echo "'gpl' accepts no arguments"
			return 1
		fi
	}
	# push
	gp() {
		if [ $# -eq 0 ]; then
			__git_push 0 0
			return $?
		else
			echo "'gp' accepts no arguments"
			return 1
		fi
	}
	gpf() {
		if [ $# -eq 0 ]; then
			__git_push 1 0
			return $?
		else
			echo "'gpf' accepts no arguments"
			return 1
		fi
	}
	gpw() {
		if [ $# -eq 0 ]; then
			__git_push 0 1
			return $?
		else
			echo "'gpw' accepts no arguments"
			return 1
		fi
	}
	gpfw() {
		if [ $# -eq 0 ]; then
			__git_push 1 1
			return $?
		else
			echo "'gpfw' accepts no arguments"
			return 1
		fi
	}
	__git_push() {
		if [ $# -eq 2 ]; then
			__git_push_force="$1"
			__git_push_gitweb="$2"
			if [ "${__git_push_force}" -eq 0 ] && [ "${__git_push_gitweb}" -eq 0 ]; then
				git push -u origin "$(__current_branch)" || return $?
			elif [ "${__git_push_force}" -eq 0 ] && [ "${__git_push_gitweb}" -eq 1 ]; then
				git push -u origin "$(__current_branch)" || return $?
				gitweb || return $?
			elif [ "${__git_push_force}" -eq 1 ] && [ "${__git_push_gitweb}" -eq 0 ]; then
				git push -fu origin "$(__current_branch)" || return $?
			elif [ "${__git_push_force}" -eq 1 ] && [ "${__git_push_gitweb}" -eq 1 ]; then
				git push -fu origin "$(__current_branch)" || return $?
				gitweb || return $?
			else
				echo "'__git_push' accepts {0, 1} for the 'force' and 'gitweb' flags; got ${__git_push_force} and ${__git_push_gitweb}"
				return 1
			fi
		else
			echo "'__git_push' requires 2 arguments"
			return 1
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
			echo "'grb' accepts [0..1] arguments"
			return 1
		fi
		gf && git rebase -s recursive -X theirs "${__grb_branch}"
		return $?
	}
	grba() {
		if [ $# -eq 0 ]; then
			git rebase --abort
			return $?
		else
			echo "'grba' accepts no arguments"
			return 1
		fi
	}
	grbc() {
		if [ $# -eq 0 ]; then
			git rebase --continue
			return $?
		else
			echo "'grbc' accepts no arguments"
			return 1
		fi
	}
	grbs() {
		if [ $# -eq 0 ]; then
			git rebase --skip
			return $?
		else
			echo "'grbs' accepts no arguments"
			return 1
		fi
	}
	# rebase (squash)
	gsqm() {
		gf
		git reset --soft "$(git merge-base HEAD master)"
		gcf "$@"
	}
	# reset
	alias gr='git reset'
	alias grp='git reset --patch'
	# rev-parse
	repo_root() { git rev-parse --show-toplevel; }
	__branch_exists() {
		if git rev-parse --verify "$@" >/dev/null 2>&1; then
			true
		else
			false
		fi
	}
	__current_branch() { git rev-parse --abbrev-ref HEAD; }
	__is_current_branch() {
		if [ "$(__current_branch)" = "$1" ]; then
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
	gs() { git status "$@"; }
	# stash
	alias gst='git stash'
	alias gstd='git stash drop'
	alias gstp='git stash pop'
	# tag
	gta() { git tag -a "$1" "$2" -m "$1" && git push -u origin --tags; }
	gtd() { git tag -d "$@" && git push -d origin "$@"; }
	# watchexec
	if command -v watch >/dev/null 2>&1; then
		wgd() { watch -d -n 0.1 -- git diff "$@"; }
		wgs() { watch -d -n 0.1 -- git status "$@"; }
	fi
	# gitweb
	if command -v gitweb >/dev/null 2>&1; then
		gw() { gitweb; }
	fi
fi
