#!/usr/bin/env sh

if command -v git >/dev/null 2>&1; then
	# add
	alias ga='git add'
	gaa() { git add -A; }
	alias gap='git add -p'
	# add + commit + push
	gac() { gaa && __git_commit "$@"; }
	gaca() { gaa && __git_commit -a -f "$@"; }
	gacan() { gaa && __git_commit -a -n -f "$@"; }
	gacf() { gaa && __git_commit -f "$@"; }
	gacn() { gaa && __git_commit -n "$@"; }
	gacnf() { gaa && __git_commit -n -f "$@"; }
	# branch
	alias gb='git branch'
	alias gba='git branch -a'
	alias gbd='git branch -d'
	alias gbdd='git branch -D'
	# checkout
	alias gco='git checkout'
	alias gcob='git checkout -b'
	alias gcobd='git checkout -b dev'
	gcobt() {
		if [ $# -eq 1 ]; then
			git checkout -b "$1" -t "origin/$1"
		else
			echo "Expected exactly 1 argument; got $#"
		fi
	}
	alias gcom='git checkout master'
	alias gcomp='git checkout master && git pull --force'
	alias gcompd='git checkout master && git pull --force && git branch -D dev'
	alias gcompr='git checkout master && git pull --force && git branch -D dev && git checkout -b dev'
	alias gcop='git checkout --patch'
	# cherry-pick
	alias gcp='git cherry-pick'
	# clone
	alias gcl='git clone'
	# commit + push
	__git_commit() {
		while test $# != 0; do
			case "$1" in
			-a)
				amend=1
				shift
				;;
			-n)
				no_verify=1
				shift
				;;
			-f)
				force=1
				shift
				;;
			*) break ;;
			esac
		done
		if [ -n "${amend}" ]; then
			if [ -n "${force}" ]; then
				if [ -n "${no_verify}" ] && [ $# -eq 0 ]; then
					git commit -n --amend --no-edit
				elif [ -n "${no_verify}" ] && [ $# -eq 1 ]; then
					git commit -nm "$1" --amend
				elif [ -z "${no_verify}" ] && [ $# -eq 0 ]; then
					git commit --amend --no-edit
				elif [ -z "${no_verify}" ] && [ $# -eq 1 ]; then
					git commit -m "$1" --amend
				else
					echo "Expected 0 or 1 argument; got $#"
				fi
			else
				echo "Expected --force; since --amend was given"
			fi
			gpf
		else
			if [ -n "${no_verify}" ] && [ $# -eq 0 ]; then
				git commit -n
			elif [ -n "${no_verify}" ] && [ $# -eq 1 ]; then
				git commit -nm "$1"
			elif [ -z "${no_verify}" ] && [ $# -eq 0 ]; then
				git commit
			elif [ -z "${no_verify}" ] && [ $# -eq 1 ]; then
				git commit -m "$1"
			else
				echo "Expected 0 or 1 argument; got $#"
			fi
			if [ -n "${force}" ]; then
				gpf
			else
				gp
			fi
		fi
	}
	gc() { __git_commit "$@"; }
	gca() { __git_commit -a -f "$@"; }
	gcan() { __git_commit -a -n -f "$@"; }
	gcf() { __git_commit -f "$@"; }
	gcn() { __git_commit -n "$@"; }
	gcnf() { __git_commit -n -f "$@"; }
	# diff
	alias gd='git diff'
	alias gdc='git diff --cached'
	alias gdm='git diff origin/master'
	# fetch
	alias gf='__git_fetch'
	__git_fetch() { git fetch --all; }
	# log
	alias gl='git log --oneline --decorate --graph'
	# mv
	alias gmv='git mv'
	# pull
	alias gpl='git pull --force'
	# push
	gp() { git push -u origin "$(gcurr)"; }
	gpf() { git push -fu origin "$(gcurr)"; }
	# rebase
	alias grb='__git_fetch && git rebase'
	alias grbi='__git_fetch && git rebase -i'
	grbih() { __git_fetch && git rebase -i HEAD~"$1"; }
	alias grbim='__git_fetch && git rebase -i origin/master'
	alias grbm='__git_fetch && git rebase -s recursive -X theirs origin/master'
	# reset
	alias gr='git reset'
	alias grp='git reset --patch'
	# rev-parse
	gcurr() { git rev-parse --abbrev-ref HEAD; }
	groot() { git rev-parse --show-toplevel; }
	# rm
	alias grm='git rm'
	alias grmc='git rm --cached'
	alias grmf='git rm -f'
	alias grmr='git rm -r'
	alias grmrf='git rm -rf'
	# status
	alias gs='git status'
	# stash
	alias gst='git stash'
	alias gstd='git stash drop'
	alias gstp='git stash pop'
	# tag
	gta() { git tag -a "$1" "$2" -m "$1" && git push -u origin --tags; }
	gtd() { git tag -d "$1" && git push -d origin "$1"; }

	# gitweb
	if command -v gitweb >/dev/null 2>&1; then
		alias gw='gitweb'
		# add + commit + push
		gacw() { gac "$@" && gitweb; }
		gacaw() { gaca "$@" && gitweb; }
		gacanw() { gacan "$@" && gitweb; }
		gacfw() { gacf "$@" && gitweb; }
		gacnw() { gacn "$@" && gitweb; }
		gacnfw() { gacnf "$@" && gitweb; }
		# commit + push
		gcw() { __git_commit "$@" && gitweb; }
		gcaw() { __git_commit -a -f "$@" && gitweb; }
		gcanw() { __git_commit -a -n -f "$@" && gitweb; }
		gcfw() { __git_commit -f "$@" && gitweb; }
		gcnw() { __git_commit -n "$@" && gitweb; }
		gcnfw() { __git_commit -n -f "$@" && gitweb; }
	fi
	# push
	alias gpw='gp && gitweb'
	alias gpfw='gpf && gitweb'
fi
