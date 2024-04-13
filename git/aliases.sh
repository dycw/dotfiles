#!/usr/bin/env sh

if command -v git >/dev/null 2>&1; then
	# add
	alias ga='git add'
	gaa() { git add -A; }
	alias gap='git add -p'
	# add + commit + push
	gac() { gaa && gc "$@"; }
	gaca() { gaa && gca "$@"; }
	gacan() { gaa && gcan "$@"; }
	gacf() { gaa && gcaf "$@"; }
	gacn() { gaa && gcn "$@"; }
	gacnf() { gaa && gcnf "$@"; }
	gacr() { gaa && gcr "$@"; }
	# branch
	alias gb='git branch'
	alias gba='git branch -a'
	gbd() { git branch -d "$1"; }
	gbexists() {
		if git rev-parse --verify "$1" >/dev/null 2>&1; then
			true
		else
			false
		fi
	}
	gbk() {
		if gbexists "$1"; then
			git branch -D "$1"
		fi
	}
	gbkd() { gbk dev; }
	# checkout
	gco() { git checkout "$1"; }
	gcob() { git checkout -b "$1"; }
	gcobd() { gcob dev; }
	gcobr() { gbk "$1" && gcob "$1"; }
	gcobrd() { gcobr dev; }
	gcobt() { git checkout -b "$1" -t "origin/$1"; }
	gcod() { gco dev; }
	gcom() { git checkout master && git pull --force; }
	gcomk() { gcom && gbk "$1"; }
	gcomkd() { gcomk dev; }
	gcomr() { gcom && gcobr "$1"; }
	gcomrd() { gcomr dev; }
	gcop() { git checkout --patch; }
	# cherry-pick
	alias gcp='git cherry-pick'
	# clone
	gcl() { git clone --recurse-submodules "$@"; }
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
			-r)
				reuse=1
				shift
				;;
			-f)
				force=1
				shift
				;;
			*) break ;;
			esac
		done
		if [ -n "${amend}" ] && [ -n "${reuse}" ]; then
			echo "Expected at most one of --amend or --reuse; got both"
		elif [ -n "${amend}" ] && [ -z "${reuse}" ]; then
			# amend, not reuse
			if [ -n "${force}" ]; then
				if [ -n "${no_verify}" ] && [ $# -eq 0 ]; then
					git commit -n --amend
				elif [ -n "${no_verify}" ] && [ $# -eq 1 ]; then
					git commit -nm "$1" --amend
				elif [ -z "${no_verify}" ] && [ $# -eq 0 ]; then
					git commit --amend
				elif [ -z "${no_verify}" ] && [ $# -eq 1 ]; then
					git commit -m "$1" --amend
				else
					echo "Since --amend, expected at most 1 argument; got $#"
				fi
				gpf
			else
				echo "Since --amend, expected --force"
			fi
		elif [ -z "${amend}" ] && [ -n "${reuse}" ]; then
			# reuse, not amend
			if [ $# -ge 1 ]; then
				echo "Since --reuse, expected no arguments; got $#"
			elif [ -z "${force}" ]; then
				echo "Since --reuse, expected --force"
			else
				if [ -n "${no_verify}" ]; then
					git commit -n --amend --no-edit
				else
					git commit --amend --no-edit
				fi
				gpf
			fi
		else
			# not amend, not reuse
			if [ -n "${no_verify}" ] && [ $# -eq 0 ]; then
				git commit -n
			elif [ -n "${no_verify}" ] && [ $# -eq 1 ]; then
				git commit -nm "$1"
			elif [ -z "${no_verify}" ] && [ $# -eq 0 ]; then
				git commit
			elif [ -z "${no_verify}" ] && [ $# -eq 1 ]; then
				git commit -m "$1"
			else
				echo "Basic case expected at most 1 argument; got $#"
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
	gcr() { __git_commit -r -f; }
	# diff
	alias gd='git diff'
	alias gdc='git diff --cached'
	alias gdm='git diff origin/master'
	# fetch
	gf() { git fetch --all; }
	# log
	alias gl='git log --oneline --decorate --graph'
	# mv
	alias gmv='git mv'
	# pull
	gpl() { git pull --force; }
	# push
	gp() { git push -u origin "$(gcurr)"; }
	gpf() { git push -fu origin "$(gcurr)"; }
	# rebase
	grb() { gf && git rebase "$1"; }
	grbi() { gf && git rebase -i "$1"; }
	grbim() { gf && git rebase -i origin/master; }
	grbm() { gf && git rebase -s recursive -X theirs origin/master; }
	# rebase (squash)
	gsqm() {
		gf
		git reset --soft "$(git merge-base HEAD master)"
		gcf "$1"
	}
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
		gacrw() { gacr "$@" && gitweb; }
		# commit + push
		gcw() { gc "$@" && gitweb; }
		gcaw() { gca "$@" && gitweb; }
		gcanw() { gcan "$@" && gitweb; }
		gcfw() { gcf "$@" && gitweb; }
		gcnw() { gcn "$@" && gitweb; }
		gcnfw() { gcnf "$@" && gitweb; }
		gcrw() { gc "$@" && gitweb; }
	fi
	# push
	alias gpw='gp && gitweb'
	alias gpfw='gpf && gitweb'
fi
