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
	gac() { __git_all true false false 'none' "$@"; }
	gacn() { __git_all true true false 'none' "$@"; }
	gacf() { __git_all true false true 'none' "$@"; }
	gacnf() { __git_all true true true 'none' "$@"; }
	gacw() { __git_all true false false 'web' "$@"; }
	gacnw() { __git_all true true false 'web' "$@"; }
	gacfw() { __git_all true false true 'web' "$@"; }
	gacnfw() { __git_all true true true 'web' "$@"; }
	gace() { __git_all true false false 'exit' "$@"; }
	gacne() { __git_all true true false 'exit' "$@"; }
	gacfe() { __git_all true false true 'exit' "$@"; }
	gacnfe() { __git_all true true true 'exit' "$@"; }
	gacwe() { __git_all true false false 'web+exit' "$@"; }
	gacnwe() { __git_all true true false 'web+exit' "$@"; }
	gacfwe() { __git_all true false true 'web+exit' "$@"; }
	gacnfwe() { __git_all true true true 'web+exit' "$@"; }
	gacm() { __git_all true false false 'merge' "$@"; }
	gacnm() { __git_all true true false 'merge' "$@"; }
	gacfm() { __git_all true false true 'merge' "$@"; }
	gacnfm() { __git_all true true true 'merge' "$@"; }
	gacx() { __git_all true false false 'merge+exit' "$@"; }
	gacnx() { __git_all true true false 'merge+exit' "$@"; }
	gacfx() { __git_all true false true 'merge+exit' "$@"; }
	gacnfx() { __git_all true true true 'merge+exit' "$@"; }
	gc() {
		[ $# -ge 2 ] && echo_date "'gc' accepts [0..1] arguments; got $#" && return 1
		__git_all false false false 'none' "$@"
	}
	gcn() {
		[ $# -ge 2 ] && echo_date "'gcn' accepts [0..1] arguments; got $#" && return 1
		__git_all false true false 'none' "$@"
	}
	gcf() {
		[ $# -ge 2 ] && echo_date "'gcf' accepts [0..1] arguments; got $#" && return 1
		__git_all false false true 'none' "$@"
	}
	gcnf() {
		[ $# -ge 2 ] && echo_date "'gcnf' accepts [0..1] arguments; got $#" && return 1
		__git_all false true true 'none' "$@"
	}
	gcw() {
		[ $# -ge 2 ] && echo_date "'gcw' accepts [0..1] arguments; got $#" && return 1
		__git_all false false false 'web' "$@"
	}
	gcnw() {
		[ $# -ge 2 ] && echo_date "'gcnw' accepts [0..1] arguments; got $#" && return 1
		__git_all false true false 'web' "$@"
	}
	gcfw() {
		[ $# -ge 2 ] && echo_date "'gcfw' accepts [0..1] arguments; got $#" && return 1
		__git_all false false true 'web' "$@"
	}
	gcnfw() {
		[ $# -ge 2 ] && echo_date "'gcnfw' accepts [0..1] arguments; got $#" && return 1
		__git_all false true true 'web' "$@"
	}
	gce() {
		[ $# -ge 2 ] && echo_date "'gce' accepts [0..1] arguments; got $#" && return 1
		__git_all false false false 'exit' "$@"
	}
	gcne() {
		[ $# -ge 2 ] && echo_date "'gcne' accepts [0..1] arguments; got $#" && return 1
		__git_all false true false 'exit' "$@"
	}
	gcfe() {
		[ $# -ge 2 ] && echo_date "'gcfe' accepts [0..1] arguments; got $#" && return 1
		__git_all false false true 'exit' "$@"
	}
	gcnfe() {
		[ $# -ge 2 ] && echo_date "'gcnfe' accepts [0..1] arguments; got $#" && return 1
		__git_all false true true 'exit' "$@"
	}
	gcwe() {
		[ $# -ge 2 ] && echo_date "'gcwe' accepts [0..1] arguments; got $#" && return 1
		__git_all false false false 'web+exit' "$@"
	}
	gcnwe() {
		[ $# -ge 2 ] && echo_date "'gcnwe' accepts [0..1] arguments; got $#" && return 1
		__git_all false true false 'web+exit' "$@"
	}
	gcfwe() {
		[ $# -ge 2 ] && echo_date "'gcfwe' accepts [0..1] arguments; got $#" && return 1
		__git_all false false true 'web+exit' "$@"
	}
	gcnfwe() {
		[ $# -ge 2 ] && echo_date "'gcnfwe' accepts [0..1] arguments; got $#" && return 1
		__git_all false true true 'web+exit' "$@"
	}
	gcm() {
		[ $# -ge 2 ] && echo_date "'gcm' accepts [0..1] arguments; got $#" && return 1
		__git_all false false false 'merge' "$@"
	}
	gcnm() {
		[ $# -ge 2 ] && echo_date "'gcnm' accepts [0..1] arguments; got $#" && return 1
		__git_all false true false 'merge' "$@"
	}
	gcfm() {
		[ $# -ge 2 ] && echo_date "'gcfm' accepts [0..1] arguments; got $#" && return 1
		__git_all false false true 'merge' "$@"
	}
	gcnfm() {
		[ $# -ge 2 ] && echo_date "'gcnfm' accepts [0..1] arguments; got $#" && return 1
		__git_all false true true 'merge' "$@"
	}
	gcx() {
		[ $# -ge 2 ] && echo_date "'gcx' accepts [0..1] arguments; got $#" && return 1
		__git_all false false false 'merge+exit' "$@"
	}
	gcnx() {
		[ $# -ge 2 ] && echo_date "'gcnx' accepts [0..1] arguments; got $#" && return 1
		__git_all false true false 'merge+exit' "$@"
	}
	gcfx() {
		[ $# -ge 2 ] && echo_date "'gcfx' accepts [0..1] arguments; got $#" && return 1
		__git_all false false true 'merge+exit' "$@"
	}
	gcnfx() {
		[ $# -ge 2 ] && echo_date "'gcnfx' accepts [0..1] arguments; got $#" && return 1
		__git_all false true true 'merge+exit' "$@"
	}
	__git_all() {
		[ $# -le 3 ] && echo_date "'__git_all' accepts [4..) arguments; got $#" && return 1
		__git_all_add="$1"
		__git_all_nv="$2"
		__git_all_force="$3"
		__git_all_action="$4"
		shift 4
		case "${__git_all_action}" in
		'none' | 'web' | 'exit' | 'web+exit' | 'merge' | 'merge+exit') ;;
		*) echo_date "'__git_all' invalid action; got '${__git_all_action}'" && return 1 ;;
		esac
		if "${__git_all_add}"; then
			if [ $# -eq 0 ]; then
				__git_commit_until "${__git_all_nv}" "$(__auto_msg)" || return $?
			else
				__git_all_last=''
				for __git_commit_arg in "$@"; do
					__git_all_last="${__git_commit_arg}"
				done
				if [ -f "${__git_all_last}" ]; then
					__git_commit_until "${__git_all_nv}" "$(__auto_msg)" || return $?
				else
					__git_all_i=0
					while [ $((__git_all_i += 1)) -lt "$#" ]; do # https://stackoverflow.com/a/69952637
						set -- "$@" "$1"
						shift
					done
					shift
					__git_commit_until "${__git_all_nv}" "${__git_all_last}" "$@" || return $?
				fi
			fi
		else
			if [ $# -eq 0 ]; then
				__git_commit_until "${__git_all_nv}" "$(__git_commit_until)" || return $?
			elif [ $# -eq 1 ]; then
				__git_commit_until "${__git_all_nv}" "$1" || return $?
			else
				echo_date "'__git_all' in the 'no add' case accepts [0..1] arguments; got '$#'" && return 1
			fi
		fi
		if [ "${__git_all_action}" = 'none' ] ||
			[ "${__git_all_action}" = 'web' ] ||
			[ "${__git_all_action}" = 'exit' ] ||
			[ "${__git_all_action}" = 'web+exit' ]; then
			__git_push "${__git_all_force}" "${__git_all_action}"
		elif [ "${__git_all_action}" = 'merge' ]; then
			__git_push "${__git_all_force}" 'none' && __gh_merge 'delete'
		elif [ "${__git_all_action}" = 'merge+exit' ]; then
			__git_push "${__git_all_force}" 'none' && __gh_merge 'delete+exit'
		else
			echo_date "'__git_all' impossible case; got '${__git_all_action}'" && return 1
		fi
	}
	# branch
	gb() {
		[ $# -ne 0 ] && echo_date "'gb' accepts no arguments; got $#" && return 1
		git branch --all --list --sort=-committerdate --verbose
	}
	gbd() {
		if [ $# -eq 0 ]; then
			__select_local_branches | while IFS= read -r __gbd_branch; do
				__git_delete "${__gbd_branch}"
			done
		else
			for __gbd_branch in "$@"; do
				__git_delete "${__gbd_branch}"
			done
		fi
	}
	gbdr() {
		gf || return $?
		if [ $# -eq 0 ]; then
			__select_remote_branches | xargs -r -I{} git push --delete origin "{}"
		else
			git push --delete origin "$@"
		fi
	}
	gbm() { git branch -m "$1"; }
	__delete_gone_branches() {
		[ $# -ne 0 ] && echo_date "'__delete_gone_branches' accepts no arguments; got $#" && return 1
		git branch -vv | awk '/: gone]/{print $1}' | xargs -r git branch -D
	}
	__git_delete() {
		[ $# -ne 1 ] && echo_date "'__git_delete' accepts 1 argument; got $#" && return 1
		if __branch_exists "$1" && [ "$(current_branch)" != "$1" ]; then
			git branch --delete --force "$!"
		fi
	}
	__select_local_branch() {
		[ $# -ne 0 ] && echo_date "'__select_local_branch' accepts no arguments; got $#" && return 1
		git branch --format="%(refname:short)" | fzf
	}
	__select_local_branches() {
		[ $# -ne 0 ] && echo_date "'__select_local_branches' accepts no arguments; got $#" && return 1
		git branch --format="%(refname:short)" | fzf --multi
	}
	__select_remote_branch() {
		[ $# -ne 0 ] && echo_date "'__select_remote_branch' accepts no arguments; got $#" && return 1
		git branch --color=never --remotes | awk '!/->/' | fzf | sed -E 's|^[[:space:]]*origin/||'
	}
	__select_remote_branches() {
		[ $# -ne 0 ] && echo_date "'__select_remote_branches' accepts no arguments; got $#" && return 1
		git branch --color=never --remotes | awk '!/->/' | fzf --multi | sed -E 's|^[[:space:]]*origin/||'
	}
	# checkout
	gcb() {
		if [ $# -eq 0 ]; then
			__git_create '' ''
		elif [ $# -eq 1 ]; then
			__git_create "$1" ''
		elif [ $# -eq 2 ]; then
			__git_create "$1" "$2"
		else
			echo_date "'gcb' accepts [0..2] arguments; got $#" && return 1
		fi
	}
	gcac() {
		[ $# -eq 0 ] && echo_date "'gcac' accepts [1..) arguments; got $#" && return 1
		__gcac_title="$1" && shift && __git_create_all "${__gcac_title}" false false 'none' "$@"
	}
	gcacn() {
		[ $# -eq 0 ] && echo_date "'gcacn' accepts [1..) arguments; got $#" && return 1
		__gcacn_title="$1" && shift && __git_create_all "${__gcacn_title}" true false 'none' "$@"
	}
	gcacf() {
		[ $# -eq 0 ] && echo_date "'gcacf' accepts [1..) arguments; got $#" && return 1
		__gcacf_title="$1" && shift && __git_create_all "${__gcacf_title}" false true 'none' "$@"
	}
	gcacnf() {
		[ $# -eq 0 ] && echo_date "'gcacnf' accepts [1..) arguments; got $#" && return 1
		__gcacnf_title="$1" && shift && __git_create_all "${__gcacnf_title}" true true 'none' "$@"
	}
	gcacw() {
		[ $# -eq 0 ] && echo_date "'gcacw' accepts [1..) arguments; got $#" && return 1
		__gcacw_title="$1" && shift && __git_create_all "${__gcacw_title}" false false 'web' "$@"
	}
	gcacnw() {
		[ $# -eq 0 ] && echo_date "'gcacnw' accepts [1..) arguments; got $#" && return 1
		__gcacnw_title="$1" && shift && __git_create_all "${__gcacnw_title}" true false 'web' "$@"
	}
	gcacfw() {
		[ $# -eq 0 ] && echo_date "'gcacfw' accepts [1..) arguments; got $#" && return 1
		__gcacfw_title="$1" && shift && __git_create_all "${__gcacfw_title}" false true 'web' "$@"
	}
	gcacnfw() {
		[ $# -eq 0 ] && echo_date "'gcacnfw' accepts [1..) arguments; got $#" && return 1
		__gcacnfw_title="$1" && shift && __git_create_all "${__gcacnfw_title}" true true 'web' "$@"
	}
	gcace() {
		[ $# -eq 0 ] && echo_date "'gcace' accepts [1..) arguments; got $#" && return 1
		__gcace_title="$1" && shift && __git_create_all "${__gcace_title}" false false 'exit' "$@"
	}
	gcacne() {
		[ $# -eq 0 ] && echo_date "'gcacne' accepts [1..) arguments; got $#" && return 1
		__gcacne_title="$1" && shift && __git_create_all "${__gcacne_title}" true false 'exit' "$@"
	}
	gcacfe() {
		[ $# -eq 0 ] && echo_date "'gcacfe' accepts [1..) arguments; got $#" && return 1
		__gcacfe_title="$1" && shift && __git_create_all "${__gcacfe_title}" false true 'exit' "$@"
	}
	gcacnfe() {
		[ $# -eq 0 ] && echo_date "'gcacnfe' accepts [1..) arguments; got $#" && return 1
		__gcacnfe_title="$1" && shift && __git_create_all "${__gcacnfe_title}" true true 'exit' "$@"
	}
	gcacwe() {
		[ $# -eq 0 ] && echo_date "'gcacwe' accepts [1..) arguments; got $#" && return 1
		__gcacwe_title="$1" && shift && __git_create_all "${__gcacwe_title}" false false 'web+exit' "$@"
	}
	gcacnwe() {
		[ $# -eq 0 ] && echo_date "'gcacnwe' accepts [1..) arguments; got $#" && return 1
		__gcacnwe_title="$1" && shift && __git_create_all "${__gcacnwe_title}" true false 'web+exit' "$@"
	}
	gcacfwe() {
		[ $# -eq 0 ] && echo_date "'gcacfwe' accepts [1..) arguments; got $#" && return 1
		__gcacfwe_title="$1" && shift && __git_create_all "${__gcacfwe_title}" false true 'web+exit' "$@"
	}
	gcacnfwe() {
		[ $# -eq 0 ] && echo_date "'gcacnfwe' accepts [1..) arguments; got $#" && return 1
		__gcacnfwe_title="$1" && shift && __git_create_all "${__gcacnfwe_title}" true true 'web+exit' "$@"
	}
	gcacm() {
		[ $# -eq 0 ] && echo_date "'gcacm' accepts [1..) arguments; got $#" && return 1
		__gcacm_title="$1" && shift && __git_create_all "${__gcacm_title}" false false 'merge' "$@"
	}
	gcacnm() {
		[ $# -eq 0 ] && echo_date "'gcacnm' accepts [1..) arguments; got $#" && return 1
		__gcacnm_title="$1" && shift && __git_create_all "${__gcacnm_title}" true false 'merge' "$@"
	}
	gcacfm() {
		[ $# -eq 0 ] && echo_date "'gcacfm' accepts [1..) arguments; got $#" && return 1
		__gcacfm_title="$1" && shift && __git_create_all "${__gcacfm_title}" false true 'merge' "$@"
	}
	gcacnfm() {
		[ $# -eq 0 ] && echo_date "'gcacnfm' accepts [1..) arguments; got $#" && return 1
		__gcacnfm_title="$1" && shift && __git_create_all "${__gcacnfm_title}" true true 'merge' "$@"
	}
	gcacx() {
		[ $# -eq 0 ] && echo_date "'gcacx' accepts [1..) arguments; got $#" && return 1
		__gcacx_title="$1" && shift && __git_create_all "${__gcacx_title}" false false 'merge+exit' "$@"
	}
	gcacnx() {
		[ $# -eq 0 ] && echo_date "'gcacnx' accepts [1..) arguments; got $#" && return 1
		__gcacnx_title="$1" && shift && __git_create_all "${__gcacnx_title}" true false 'merge+exit' "$@"
	}
	gcacfx() {
		[ $# -eq 0 ] && echo_date "'gcacfx' accepts [1..) arguments; got $#" && return 1
		__gcacfx_title="$1" && shift && __git_create_all "${__gcacfx_title}" false true 'merge+exit' "$@"
	}
	gcacnfx() {
		[ $# -eq 0 ] && echo_date "'gcacnfx' accepts [1..) arguments; got $#" && return 1
		__gcacnfx_title="$1" && shift && __git_create_all "${__gcacnfx_title}" true true 'merge+exit' "$@"
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
	gm() {
		[ $# -ne 0 ] && echo_date "'gm' accepts no arguments; got $#" && return 1
		__git_checkout_master 'none'
	}
	gmd() {
		[ $# -ne 0 ] && echo_date "'gmd' accepts no arguments; got $#" && return 1
		__git_checkout_master 'delete'
	}
	gmx() {
		[ $# -ne 0 ] && echo_date "'gmx' accepts no arguments; got $#" && return 1
		__git_checkout_master 'delete+exit'
	}
	gco() {
		if [ $# -eq 0 ]; then
			__gco_target="$(__select_local_branch)" || return $?
		elif [ $# -eq 1 ]; then
			__gco_target="$1"
		else
			echo_date "'gco' accepts [0..1] arguments; got $#" && return 1
		fi
		__gco_current="$(current_branch)" || return $?
		if [ "${__gco_current}" != "${__gco_target}" ]; then
			git checkout "${__gco_target}" || return $?
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
		__git_checkout_master_branch="$(current_branch)" || return $?
		gco master
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
			__git_create_body="Closes $2"
		elif [ "$1" != '' ] && [ "$2" != '' ] && ! __is_int "$2"; then
			__git_create_title="$1"
			__git_create_branch="$(__to_valid_branch "$1")" || return $?
			__git_create_body="$2"
		else
			echo_date "'__git_create' impossible case; got '$1' and '$2'" && return 1
		fi
		git checkout -b "${__git_create_branch}" origin/master &&
			__git_commit_empty_msg &&
			__git_push false 'none' &&
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
			__branch="$(current_branch)" || return 1
			gcof && gcm && gcb "${__branch}"
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
		# $1 = no-verify
		# $2 = message
		if git diff --cached --quiet && git diff --quiet; then
			return 0
		fi
		if [ "$2" = '' ]; then
			__git_commit_msg="$(__auto_msg)"
		else
			__git_commit_msg="$2"
		fi
		if "$1"; then
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
		__git_commit_until_nv="$1"
		__git_commit_until_msg="$2"
		shift 2
		for __git_commit_until_i in $(seq 0 4); do
			ga "$@" || return $?
			if __git_commit "${__git_commit_until_nv}" "${__git_commit_until_msg}"; then
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
		[ $# -ne 0 ] && echo_date "'gl' accepts no arguments; got $#" && return 1
		git log --abbrev-commit --decorate=short --pretty=format:'%C(red)%h%C(reset) |%C(yellow)%d%C(reset) | %s | %Cgreen%cr%C(reset)'
	}
	# merge
	gma() {
		[ $# -ne 0 ] && echo_date "'gma' accepts no arguments; got $#" && return 1
		git merge --abort
	}
	# mv
	gmv() {
		[ $# -ne 2 ] && echo_date "'gmv' accepts 2 arguments; got $#" && return 1
		git mv "$1" "$2"
	}
	# pull
	gpl() {
		[ $# -ne 0 ] && echo_date "'gpl' accepts no arguments; got $#" && return 1
		git pull --force && gf
	}
	# # push
	gp() {
		[ $# -ne 0 ] && echo_date "'gp' accepts no arguments; got $#" && return 1
		__git_push false 'none'
	}
	gpf() {
		[ $# -ne 0 ] && echo_date "'gpf' accepts no arguments; got $#" && return 1
		__git_push true 'none'
	}
	gpw() {
		[ $# -ne 0 ] && echo_date "'gpw' accepts no arguments; got $#" && return 1
		__git_push false 'web'
	}
	gpfw() {
		[ $# -ne 0 ] && echo_date "'gpfw' accepts no arguments; got $#" && return 1
		__git_push true 'web'
	}
	gpe() {
		[ $# -ne 0 ] && echo_date "'gpe' accepts no arguments; got $#" && return 1
		__git_push false 'exit'
	}
	gpfe() {
		[ $# -ne 0 ] && echo_date "'gpfe' accepts no arguments; got $#" && return 1
		__git_push true 'exit'
	}
	gpwe() {
		[ $# -ne 0 ] && echo_date "'gpwe' accepts no arguments; got $#" && return 1
		__git_push false 'web+exit'
	}
	gpfwe() {
		[ $# -ne 0 ] && echo_date "'gpfwe' accepts no arguments; got $#" && return 1
		__git_push true 'web+exit'
	}
	__git_push() {
		[ $# -ne 2 ] && echo_date "'__git_push' accepts 2 arguments; got $#" && return 1
		# $1 = force
		# $2 = action = {none/web/exit/web+exit}
		case "$2" in
		'none' | 'web' | 'exit' | 'web+exit') ;;
		*) echo_date "'__gh_push' invalid action; got '$2'" && return 1 ;;
		esac
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
			echo_date "'__git_push' impossible case; got '$2'" && return 1
		fi
	}
	__git_push_current_branch() {
		[ $# -ne 1 ] && echo_date "'__git_push_current_branch' accepts 1 argument; got $#" && return 1
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
			__branch='origin/master'
		elif [ $# -eq 1 ]; then
			__branch="$1"
		else
			echo_date "'grb' accepts [0..1] arguments; got $#" && return 1
		fi
		gf && git rebase --strategy=recursive --strategy-option=theirs "${__branch}"
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
	# reset
	gr() { git reset "$@"; }
	grhom() { git reset --hard origin/master "$@"; }
	grp() { git reset --patch "$@"; }
	# rev-parse
	current_branch() {
		[ $# -ne 0 ] && echo_date "'current_branch' accepts no arguments; got $#" && return 1
		git rev-parse --abbrev-ref HEAD
	}
	repo_root() {
		[ $# -ne 0 ] && echo_date "'repo_root' accepts no arguments; got $#" && return 1
		git rev-parse --show-toplevel
	}
	__branch_exists() {
		[ $# -ne 1 ] && echo_date "'__branch_exists' accepts 1 argument; got $#" && return 1
		if git rev-parse --verify "$1" >/dev/null 2>&1; then
			true
		else
			false
		fi
	}
	__is_current_branch() {
		[ $# -ne 0 ] && echo_date "'__is_current_branch' accepts no arguments; got $#" && return 1
		if [ "$(current_branch)" = "$1" ]; then
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
	# rm
	grm() { git rm "$@"; }
	grmc() { git rm --cached "$@"; }
	grmf() { git rm -f "$@"; }
	grmr() { git rm -r "$@"; }
	grmrf() { git rm -rf "$@"; }
	# show-ref
	__is_valid_ref() {
		[ $# -ne 1 ] && echo_date "'__is_valid_ref' accepts 1 argument; got $#" && return 1
		git show-ref --verify --quiet "refs/heads/$1" ||
			git show-ref --verify --quiet "refs/remotes/$1" ||
			git show-ref --verify --quiet "refs/tags/$1" ||
			git rev-parse --verify --quiet "$1" >/dev/null
	}
	# status
	gs() {
		[ $# -ge 2 ] && echo_date "'gs' accepts [0..1] arguments; got $#" && return 1
		git status "$@"
	}
	__tree_is_clean() {
		[ $# -ne 0 ] && echo_date "'__tree_is_clean' accepts no arguments; got $#" && return 1
		[ -z "$(git status --porcelain)" ]
	}
	# stash
	gst() { git stash "$@"; }
	gstd() { git stash drop "$@"; }
	gstp() { git stash pop "$@"; }
	# submodules
	gsu() {
		[ $# -ne 0 ] && echo_date "'gsub_update' accepts no arguments; got $#" && return 1
		git submodule foreach --recursive 'git checkout master && git pull --ff-only'
	}
	# tag
	gta() {
		[ $(($# % 2)) -ne 0 ] && echo_date "'gta' accepts an even number of arguments; got $#" && return 1
		while [ $# -gt 0 ]; do
			# $1 = tag
			# $2 = sha
			git tag -a "$1" "$2" -m "$1" && git push --set-upstream origin --tags
			shift 2
		done
	}
	gtd() { git tag --delete "$@" && git push --delete origin "$@"; }
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
				echo_date "'ghv' cannot find an open PR for '$(current_branch)'" && return 1
			fi
		elif __is_gitlab; then
			__num="$(__glab_mr_num)"
			if [ -n "${__num}" ]; then
				glab mr view "${__num}" --web
			else
				echo_date "'ghv' cannot find an open PR for '$(current_branch)'" && return 1
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
			__gh_exists_num="$(gh pr list --json number --jq '. | length')"
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
			echo_date "'__gh_merge' cannot find an open PR for '$(current_branch)'" && return 1
		fi
		__gh_merge_start="$(date +%s)"
		if __is_github; then
			gh pr merge --auto --delete-branch --squash || return $?
			while __gh_pr_merging; do
				__gh_elapsed="$(($(date +%s) - __gh_merge_start))"
				echo_date "'$(current_branch)' is still merging... (${__gh_elapsed}s)"
				sleep 1
			done
		elif __is_gitlab; then
			__gh_status="$(__glab_mr_merge_status)"
			if [ "${__gh_status}" = 'conflict' ] ||
				[ "${__gh_status}" = 'need_rebase' ] ||
				[ "${__gh_status}" = 'not open' ]; then
				echo_date "'$(current_branch)' cannot be merged; got ${__gh_status}" && return 1
			fi
			while true; do
				glab mr merge --remove-source-branch --squash --yes >/dev/null 2>&1 || true
				if __gh_pr_merging; then
					__gh_elapsed="$(($(date +%s) - __gh_merge_start))"
					echo_date "'$(current_branch)' is still merging... ('$(__glab_mr_merge_status)', ${__gh_elapsed}s)"
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
		[ $# -ne 0 ] && echo_date "'__glab_mr_num' accepts no arguments; got $#" && return 1
		__json="$(__glab_mr_json)" || return 1
		printf "%s\n" "${__json}" | jq -r '.iid'
	}
	__glab_mr_pid() {
		[ $# -ne 0 ] && echo_date "'__glab_mr_pid' accepts no arguments; got $#" && return 1
		__json="$(__glab_mr_json)" || return 1
		printf "%s\n" "${__json}" | jq -r '.target_project_id'
	}
	__glab_mr_merge_status() {
		[ $# -ne 0 ] && echo_date "'__glab_mr_merge_status' accepts no arguments; got $#" && return 1
		__json="$(__glab_mr_json)" || return 1
		printf "%s\n" "${__json}" | jq -r '.detailed_merge_status'
	}
	__glab_mr_state() {
		[ $# -ne 0 ] && echo_date "'__glab_mr_state' accepts no arguments; got $#" && return 1
		__json="$(__glab_mr_json)" || return 1
		printf "%s\n" "${__json}" | jq -r '.state'
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
