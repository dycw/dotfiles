#!/usr/bin/env sh

if command -v git >/dev/null 2>&1; then
	# add
	alias ga='git add'
	gaa() { git add -A; }
	alias gap='git add -p'
	# add + commit + push
	gac() {
		if [ $# -le 1 ]; then
			gaa && gc "$@" && gp
		else
			echo "Expected 0 or 1 argument; got $#"
		fi
	}
	alias gaca='gaa && git commit --amend --no-edit && gpf'
	alias gacan='gaa && git commit -n --amend --no-edit && gpf'
	gacf() {
		if [ $# -eq 0 ]; then
			gaa && git commit && gpf
		elif [ $# -eq 1 ]; then
			gaa && git commit -m "$1" && gpf
		else
			echo "Expected 0 or 1 argument; got $#"
		fi
	}
	gacn() {
		if [ $# -eq 0 ]; then
			gaa && git commit -n && gp
		elif [ $# -eq 1 ]; then
			gaa && git commit -nm "$1" && gp
		else
			echo "Expected 0 or 1 argument; got $#"
		fi
	}
	gacnf() {
		if [ $# -eq 0 ]; then
			gaa && git commit -n && gpf
		elif [ $# -eq 1 ]; then
			gaa && git commit -nm "$1" && gpf
		else
			echo "Expected 0 or 1 argument; got $#"
		fi
	}
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
	# commit
	gc() {
		if [ $# -eq 0 ]; then
			git commit && gp
		elif [ $# -eq 1 ]; then
			git commit -m "$1" && gp
		else
			echo "Expected 0 or 1 argument; got $#"
		fi
	}
	gca() {
		if [ $# -eq 1 ]; then
			git commit -m "$1" --amend && gpf
		else
			echo "Expected exactly 1 argument; got $#"
		fi
	}
	gcan() {
		if [ $# -eq 1 ]; then
			git commit -nm "$1" --amend && gpf
		else
			echo "Expected exactly 1 argument; got $#"
		fi
	}
	gcf() {
		if [ $# -eq 0 ]; then
			git commit && gpf
		elif [ $# -eq 1 ]; then
			git commit -m "$1" && gpf
		else
			echo "Expected 0 or 1 argument; got $#"
		fi
	}
	gcn() {
		if [ $# -eq 0 ]; then
			git commit -n && gp
		elif [ $# -eq 1 ]; then
			git commit -nm "$1" && gp
		else
			echo "Expected 0 or 1 argument; got $#"
		fi
	}
	gcnf() {
		if [ $# -eq 0 ]; then
			git commit -n && gpf
		elif [ $# -eq 1 ]; then
			git commit -nm "$1" && gpf
		else
			echo "Expected 0 or 1 argument; got $#"
		fi
	}
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
	gpf() { gp -f; }
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
		alias gacaw='gaa && git commit --amend --no-edit && gpf && gitweb'
		alias gacanw='gaa && git commit -n --amend --no-edit && gpf && gitweb'
		gacw() {
			if [ $# -eq 0 ]; then
				gaa && git commit && gp && gitweb
			elif [ $# -eq 1 ]; then
				gaa && git commit -m "$1" && gp && gitweb
			else
				echo "Expected 0 or 1 argument; got $#"
			fi
		}
		gacfw() {
			if [ $# -eq 0 ]; then
				gaa && git commit && gpf && gitweb
			elif [ $# -eq 1 ]; then
				gaa && git commit -m "$1" && gpf && gitweb
			else
				echo "Expected 0 or 1 argument; got $#"
			fi
		}
		gacnw() {
			if [ $# -eq 0 ]; then
				gaa && git commit -n && gp && gitweb
			elif [ $# -eq 1 ]; then
				gaa && git commit -nm "$1" && gp && gitweb
			else
				echo "Expected 0 or 1 argument; got $#"
			fi
		}
		gacnfw() {
			if [ $# -eq 0 ]; then
				gaa && git commit -n && gpf && gitweb
			elif [ $# -eq 1 ]; then
				gaa && git commit -nm "$1" && gpf && gitweb
			else
				echo "Expected 0 or 1 argument; got $#"
			fi
		}
	fi
	# push
	alias gpw='gp && gitweb'
	alias gpfw='gpf && gitweb'
fi
