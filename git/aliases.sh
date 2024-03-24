#!/usr/bin/env sh

if command -v git >/dev/null 2>&1; then
	# add
	alias ga='git add'
	alias gaa='git add -A'
	alias gap='git add -p'
	# add + commit + push
	gac() {
		if [ $# -eq 0 ]; then
			git add -A && git commit && git push -u origin "$(gcurr)"
		elif [ $# -eq 1 ]; then
			git add -A && git commit -m "$1" && git push -u origin "$(gcurr)"
		else
			echo "Expected 0 or 1 argument; got $#"
		fi
	}
	gacf() {
		if [ $# -eq 0 ]; then
			git add -A && git commit && git push -fu origin "$(gcurr)"
		elif [ $# -eq 1 ]; then
			git add -A && git commit -m "$1" && git push -fu origin "$(gcurr)"
		else
			echo "Expected 0 or 1 argument; got $#"
		fi
	}
	gacn() {
		if [ $# -eq 0 ]; then
			git add -A && git commit --no-verify && git push -u origin "$(gcurr)"
		elif [ $# -eq 1 ]; then
			git add -A && git commit -m "$1" --no-verify && git push -u origin "$(gcurr)"
		else
			echo "Expected 0 or 1 argument; got $#"
		fi
	}
	gacnf() {
		if [ $# -eq 0 ]; then
			git add -A && git commit --no-verify && git push -fu origin "$(gcurr)"
		elif [ $# -eq 1 ]; then
			git add -A && git commit -m "$1" --no-verify && git push -fu origin "$(gcurr)"
		else
			echo "Expected 0 or 1 argument; got $#"
		fi
	}
	# branch
	alias gb='git branch'
	alias gba='git branch -a'
	alias gbd='git branch -d'
	alias gbdd='git branch -D dev'
	# checkout
	alias gco='git checkout'
	alias gcob='git checkout -b'
	alias gcobd='git checkout -b dev'
	gcobt() { git checkout -b "$1" -t "origin/$1"; }
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
			git commit && git push -u origin "$(gcurr)"
		elif [ $# -eq 1 ]; then
			git commit -m "$1" && git push -u origin "$(gcurr)"
		else
			echo "Expected 0 or 1 argument; got $#"
		fi
	}
	gcf() {
		if [ $# -eq 0 ]; then
			git commit && git push -fu origin "$(gcurr)"
		elif [ $# -eq 1 ]; then
			git commit -m "$1" && git push -fu origin "$(gcurr)"
		else
			echo "Expected 0 or 1 argument; got $#"
		fi
	}
	gcn() {
		if [ $# -eq 0 ]; then
			git commit --no-verify && git push -u origin "$(gcurr)"
		elif [ $# -eq 1 ]; then
			git commit -m "$1" --no-verify && git push -u origin "$(gcurr)"
		else
			echo "Expected 0 or 1 argument; got $#"
		fi
	}
	gcnf() {
		if [ $# -eq 0 ]; then
			git commit --no-verify && git push -fu origin "$(gcurr)"
		elif [ $# -eq 1 ]; then
			git commit -m "$1" --no-verify && git push -fu origin "$(gcurr)"
		else
			echo "Expected 0 or 1 argument; got $#"
		fi
	}
	# diff
	alias gd='git diff'
	alias gdc='git diff --cached'
	alias gdm='git diff origin/master'
	# log
	alias gl='git log --oneline --decorate --graph'
	# mv
	alias gmv='git mv'
	# pull
	alias gpl='git pull --force'
	# push
	alias gp='git push -u origin "$(gcurr)"'
	alias gpf='git push -fu origin "$(gcurr)"'
	# rebase
	alias grb='git rebase'
	alias grbi='git rebase -i'
	alias grbim='git rebase -i origin/master'
	alias grbm='git rebase -s recursive -X theirs origin/master'
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
		gacw() {
			if [ $# -eq 0 ]; then
				git add -A && git commit && git push -u origin "$(gcurr)" && gitweb
			elif [ $# -eq 1 ]; then
				git add -A && git commit -m "$1" && git push -u origin "$(gcurr)" && gitweb
			else
				echo "Expected 0 or 1 argument; got $#"
			fi
		}
		gacfw() {
			if [ $# -eq 0 ]; then
				git add -A && git commit && git push -fu origin "$(gcurr)" && gitweb
			elif [ $# -eq 1 ]; then
				git add -A && git commit -m "$1" && git push -fu origin "$(gcurr)" && gitweb
			else
				echo "Expected 0 or 1 argument; got $#"
			fi
		}
		gacnw() {
			if [ $# -eq 0 ]; then
				git add -A && git commit --no-verify && git push -u origin "$(gcurr)" && gitweb
			elif [ $# -eq 1 ]; then
				git add -A && git commit -m "$1" --no-verify && git push -u origin "$(gcurr)" && gitweb
			else
				echo "Expected 0 or 1 argument; got $#"
			fi
		}
		gacnfw() {
			if [ $# -eq 0 ]; then
				git add -A && git commit --no-verify && git push -fu origin "$(gcurr)" && gitweb
			elif [ $# -eq 1 ]; then
				git add -A && git commit -m "$1" --no-verify && git push -fu origin "$(gcurr)" && gitweb
			else
				echo "Expected 0 or 1 argument; got $#"
			fi
		}
	fi
	# push
	alias gpw='git push -u origin "$(gcurr)" && gitweb'
	alias gpfw='git push -fu origin "$(gcurr)" && gitweb'
fi
