#!/usr/bin/env sh

if command -v git >/dev/null 2>&1; then
	# add
	ga() { git add "$@"; }
	gaa() { git add -A; }
	gap() { git add -p "$@"; }
	# add + commit + push
	gac() { gaa && gc "$@"; }
	gaca() { gaa && gca "$@"; }
	gacan() { gaa && gcan "$@"; }
	gacf() { gaa && gcf "$@"; }
	gacn() { gaa && gcn "$@"; }
	gacnf() { gaa && gcnf "$@"; }
	gacnr() { gaa && gcnr "$@"; }
	gacr() { gaa && gcr "$@"; }
	gac2() { __gac2 && gp; }
	gac2f() { __gac2 && gpf; }
	__gac2() {
		gaa
		if ! gcnow; then
			gaa
			gcnow
		fi
	}
	# branch
	gb() { git branch "$@"; }
	gba() { gb -a "$@"; }
	gbd() {
		__branch=$(__branch_or_dev "$@")
		if gbexists "${__branch}"; then
			git branch -D "${__branch}"
		fi
	}
	gbdr() {
		git branch -r --color=never |
			fzf |
			sed -En 's/origin\/(.*)/\1/p' |
			xargs -n 1 git push -d origin
	}
	gbexists() {
		if git rev-parse --verify "$@" >/dev/null 2>&1; then
			true
		else
			false
		fi
	}
	gbk() {
		__branch=$(__branch_or_dev "$@")
		if gbexists "${__branch}"; then
			git branch -D "${__branch}"
		fi
	}
	gbm() { git branch -m "$@"; }
	__branch_or_dev() {
		if [ "$#" -eq 0 ]; then
			echo dev
		else
			echo "$@"
		fi
	}
	# checkout
	gco() {
		if [ "$#" -eq 0 ]; then
			git checkout dev
		elif [ "$#" -eq 1 ]; then
			git checkout "$1"
		else
			git checkout "$@"
		fi
	}
	gcob() { git checkout -b "$(__branch_or_dev "$@")"; }
	gcobr() { gbk "$@" && gcob "$@"; }
	gcobt() { git checkout -b "$1" -t "origin/$1"; }
	gcom() { git checkout master && git pull --force; }
	gcomk() { gcom && gbk "$@"; }
	gcomr() { gcom && gcobr "$@"; }
	gcop() { git checkout --patch; }
	# cherry-pick
	alias gcp='git cherry-pick'
	# clone
	gcl() { git clone --recurse-submodules "$@"; }
	# commit
	gcnow() { git commit -m "Saved at $(date +"%Y-%m-%d %H:%M:%S (%a)")"; }
	# commit + push
	__git_commit() {
		unset __amend __no_verify __reuse __force
		while test $# != 0; do
			case "$1" in
			-a)
				__amend=1
				shift
				;;
			-n)
				__no_verify=1
				shift
				;;
			-r)
				__reuse=1
				shift
				;;
			-f)
				__force=1
				shift
				;;
			*) break ;;
			esac
		done
		if [ -n "${__amend}" ] && [ -n "${__reuse}" ]; then
			echo "Expected at most one of --amend or --reuse; got both"
		elif [ -n "${__amend}" ] && [ -z "${__reuse}" ]; then
			# __amend, not reuse
			if [ -n "${__force}" ]; then
				if [ -n "${__no_verify}" ] && [ $# -eq 0 ]; then
					git commit -n --amend
				elif [ -n "${__no_verify}" ] && [ $# -eq 1 ]; then
					git commit -nm "$1" --amend
				elif [ -z "${__no_verify}" ] && [ $# -eq 0 ]; then
					git commit --amend
				elif [ -z "${__no_verify}" ] && [ $# -eq 1 ]; then
					git commit -m "$1" --amend
				else
					echo "Since --amend, expected at most 1 argument; got $#"
				fi
				gpf
			else
				echo "Since --amend, expected --force"
			fi
		elif [ -z "${__amend}" ] && [ -n "${__reuse}" ]; then
			# reuse, not amend
			if [ $# -ge 1 ]; then
				echo "Since --reuse, expected no arguments; got $#"
			elif [ -z "${__force}" ]; then
				echo "Since --reuse, expected --force"
			else
				if [ -n "${__no_verify}" ]; then
					git commit -n --amend --no-edit
				else
					git commit --amend --no-edit
				fi
				gpf
			fi
		else
			# not amend, not reuse
			if [ -n "${__no_verify}" ] && [ $# -eq 0 ]; then
				git commit -n
			elif [ -n "${__no_verify}" ] && [ $# -eq 1 ]; then
				git commit -nm "$1"
			elif [ -z "${__no_verify}" ] && [ $# -eq 0 ]; then
				git commit
			elif [ -z "${__no_verify}" ] && [ $# -eq 1 ]; then
				git commit -m "$1"
			else
				echo "Basic case expected at most 1 argument; got $#"
			fi
			if [ -n "${__force}" ]; then
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
	gcnr() { __git_commit -n -r -f "$@"; }
	gcr() { __git_commit -r -f "$@"; }
	# diff
	gd() { git diff "$@"; }
	gdc() { git diff --cached "$@"; }
	gdm() { git diff origin/master "$@"; }
	# fetch
	gf() { git fetch --all; }
	gfm() { git fetch origin master:master; }
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
	grb() { gf && git rebase "$@"; }
	grba() { git rebase --abort; }
	grbc() { git rebase --continue; }
	grbi() { gfm && git rebase -i "$@"; }
	grbim() { gfm && git rebase -i origin/master; }
	grbm() { gfm && git rebase -s recursive -X theirs origin/master; }
	grbs() { git rebase --skip; }
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
	gcurr() { git rev-parse --abbrev-ref HEAD; }
	groot() { git rev-parse --show-toplevel; }
	# rm
	alias grm='git rm'
	alias grmc='git rm --cached'
	alias grmf='git rm -f'
	alias grmr='git rm -r'
	alias grmrf='git rm -rf'
	# status
	gs() { git status "$@"; }
	# stash
	alias gst='git stash'
	alias gstd='git stash drop'
	alias gstp='git stash pop'
	# tag
	gta() { git tag -a "$1" "$2" -m "$1" && git push -u origin --tags; }
	gtd() { git tag -d "$@" && git push -d origin "$@"; }

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
		gacnrw() { gacnr "$@" && gitweb; }
		gacrw() { gacr "$@" && gitweb; }
		gac2fw() { gac2f "$@" && gitweb; }
		gac2w() { gac2 "$@" && gitweb; }
		# commit
		gcnoww() { gcnow "$@" && gitweb; }
		# commit + push
		gcw() { gc "$@" && gitweb; }
		gcaw() { gca "$@" && gitweb; }
		gcanw() { gcan "$@" && gitweb; }
		gcfw() { gcf "$@" && gitweb; }
		gcnw() { gcn "$@" && gitweb; }
		gcnfw() { gcnf "$@" && gitweb; }
		gcnrw() { gcnr "$@" && gitweb; }
		gcrw() { gcr "$@" && gitweb; }
	fi
	# push
	alias gpw='gp && gitweb'
	alias gpfw='gpf && gitweb'

	# watchexec
	if command -v watch >/dev/null 2>&1; then
		wgd() { watch -d -n 0.1 -- git diff "$@"; }
		wgs() { watch -d -n 0.1 -- git status "$@"; }
	fi
fi
