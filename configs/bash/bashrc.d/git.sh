# shellcheck shell=sh disable=SC2015,SC2016,SC2164
if command -v git >/dev/null 2>&1; then
	# Auto-generate g<alias> wrappers from the dotfiles git config directly so
	# they work even before update-dotfiles has wired up the global [include].
	_git_cfg=${PATH_DOTFILES:+${PATH_DOTFILES}/configs/git/config}
	[ -f "${_git_cfg}" ] || _git_cfg=/dev/null
	git config --file "${_git_cfg:-/dev/null}" --list 2>/dev/null | grep '^alias\.' | while IFS= read -r _git_line; do
		_git_alias=${_git_line%%=*}
		_git_alias=${_git_alias#alias.}
		eval "g${_git_alias}() { git -c include.path=\"${_git_cfg}\" ${_git_alias} \"\$@\"; }"
	done
	unset _git_line _git_alias _git_cfg

	# --- edit config ---

	edit_git_shell() { "${EDITOR}" "${PATH_DOTFILES}/configs/bash/bashrc"; }

	# --- add (override auto-generated: only --all when no args) ---

	ga() {
		if [ "$#" -eq 0 ]; then
			git add --all
		else
			git add "$@"
		fi
	}
	gaf() {
		if [ "$#" -eq 0 ]; then
			git add --all --force
		else
			git add --force "$@"
		fi
	}

	# --- log (override auto-generated: support count arg) ---

	gl() {
		if [ "$#" -eq 0 ]; then
			git log-default -n 20
		elif case "$1" in *[!0-9]* | "") false ;; *) [ "$1" -ge 1 ] ;; esac then
			git log-default -n "$1"
		fi
	}

	# --- private helpers ---

	__auto_msg() { date '+%Y-%m-%d %H:%M:%S (%a)'; }

	__clean_branch_name() {
		printf '%s' "${1:?}" |
			tr '[:upper:]' '[:lower:]' |
			sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g' |
			cut -c1-80
	}

	__remote_is() { git remote-name 2>/dev/null | grep -q "$1"; }

	__git_view() {
		if (__remote_is gitea || __remote_is ts.net) && command -v tea >/dev/null 2>&1; then
			tea open
			return $?
		fi
		if command -v gh >/dev/null 2>&1; then
			gh browse
			return $?
		fi
		echo "'__git_view': no browser tool (tea/gh) available" >&2
		return 1
	}

	__git_push() {
		force='' nv='' web='' exit_after=''
		while [ "$#" -gt 0 ]; do
			case "$1" in
			--force)
				force=1
				shift
				;;
			--no-verify)
				nv=1
				shift
				;;
			--web)
				web=1
				shift
				;;
			--exit)
				exit_after=1
				shift
				;;
			*) break ;;
			esac
		done
		branch
		branch=$(git current-branch) || return $?
		args
		if [ -n "$force" ] && [ -n "$nv" ]; then
			git push --force --set-upstream origin "$branch" --no-verify || return $?
		elif [ -n "$force" ]; then
			git push --force --set-upstream origin "$branch" || return $?
		elif [ -n "$nv" ]; then
			git push --set-upstream origin "$branch" --no-verify || return $?
		else
			git push --set-upstream origin "$branch" || return $?
		fi
		[ -n "$web" ] && { __git_view || return $?; }
		[ -n "$exit_after" ] && exit
	}

	__git_commit_push() {
		git is-clean && return 0
		force='' nv='' web='' exit_after=''
		while [ "$#" -gt 0 ]; do
			case "$1" in
			--force)
				force=1
				shift
				;;
			--no-verify)
				nv=1
				shift
				;;
			--web)
				web=1
				shift
				;;
			--exit)
				exit_after=1
				shift
				;;
			*) break ;;
			esac
		done
		ca
		if [ -n "$nv" ]; then
			git commit --message="$(__auto_msg)" --no-verify || return $?
		else
			git commit --message="$(__auto_msg)" || return $?
		fi
		pa
		set --
		[ -n "$force" ] && set -- "$@" --force
		[ -n "$nv" ] && set -- "$@" --no-verify
		[ -n "$web" ] && set -- "$@" --web
		[ -n "$exit_after" ] && set -- "$@" --exit
		__git_push "$@"
	}

	# retries up to 3 times to handle hook-modified files
	__git_commit_until_push() {
		force='' nv='' web='' exit_after=''
		while [ "$#" -gt 0 ]; do
			case "$1" in
			--force)
				force=1
				shift
				;;
			--no-verify)
				nv=1
				shift
				;;
			--web)
				web=1
				shift
				;;
			--exit)
				exit_after=1
				shift
				;;
			*) break ;;
			esac
		done
		ca
		commit_args=
		[ -n "$nv" ] && commit_args=--no-verify
		proceed=0 i
		for i in 1 2 3; do
			if [ "$proceed" -eq 0 ]; then
				git add --all
				__git_commit_push ${commit_args:+"${commit_args}"} && git is-clean && proceed=1 || true
			fi
		done
		if [ "$proceed" -eq 0 ]; then
			echo "'__git_commit_until_push' failed after $i attempts" >&2
			return 1
		fi
		pa
		set --
		[ -n "$force" ] && set -- "$@" --force
		[ -n "$nv" ] && set -- "$@" --no-verify
		[ -n "$web" ] && set -- "$@" --web
		[ -n "$exit_after" ] && set -- "$@" --exit
		__git_push "$@"
	}

	__git_checkout_open() {
		title='' num='' part=''
		while [ "$#" -gt 0 ]; do
			case "$1" in
			--title=*)
				title="${1#--title=}"
				shift
				;;
			--title)
				title="$2"
				shift 2
				;;
			--num=*)
				num="${1#--num=}"
				shift
				;;
			--num)
				num="$2"
				shift 2
				;;
			--part)
				part=1
				shift
				;;
			*) shift ;;
			esac
		done
		git fetch-default || return $?
		branch
		if [ -z "$title" ] && [ -z "$num" ]; then
			branch=dev
		elif [ -n "$title" ] && [ -z "$num" ]; then
			branch=$(__clean_branch_name "$title") || return $?
		elif [ -z "$title" ] && [ -n "$num" ]; then
			branch=$num
		else
			branch="${num}-$(__clean_branch_name "$title")" || return $?
		fi
		git checkout -b "$branch" "$(git default-remote-branch)" || return $?
		git commit --allow-empty --message="$(__auto_msg)" --no-verify || return $?
		__git_push --no-verify || return $?
		pr_title
		pr_title=${title:-"$(__auto_msg)"}
		pr_body='.'
		if [ -n "$num" ]; then
			pr_body="${part:+Part of}${part:-Closes} $num"
		fi
		__git_create --title="$pr_title" --body="$pr_body"
	}

	__git_checkout_close() {
		if [ "$#" -eq 0 ]; then
			echo "'__git_checkout_close' expected [1..) arguments TARGET; got $#" >&2
			return 1
		fi
		target='' delete='' exit_after=''
		while [ "$#" -gt 0 ]; do
			case "$1" in
			--delete)
				delete=1
				shift
				;;
			--exit)
				exit_after=1
				shift
				;;
			*)
				target="$1"
				shift
				;;
			esac
		done
		original
		original=$(git current-branch) || return $?
		git checkout "$target" || return $?
		git pull-default || return $?
		[ -n "$delete" ] && git branch-delete "$original"
		[ -n "$exit_after" ] && exit
	}

	__git_create() {
		title='' body='.'
		while [ "$#" -gt 0 ]; do
			case "$1" in
			--title=*)
				title="${1#--title=}"
				shift
				;;
			--title)
				title="$2"
				shift 2
				;;
			--body=*)
				body="${1#--body=}"
				shift
				;;
			--body)
				body="$2"
				shift 2
				;;
			*) shift ;;
			esac
		done
		[ -z "$title" ] && title="$(__auto_msg)"
		if (__remote_is gitea || __remote_is ts.net) && command -v tea >/dev/null 2>&1; then
			tea pulls create --title "$title" --description "$body"
			return $?
		fi
		if command -v gh >/dev/null 2>&1; then
			gh pr create --title "$title" --body "$body"
			return $?
		fi
		echo "'__git_create': no PR tool (tea/gh) available" >&2
		return 1
	}

	__git_merge() {
		exit_after=''
		while [ "$#" -gt 0 ]; do
			case "$1" in --exit)
				exit_after=1
				shift
				;;
			*) shift ;; esac
		done
		branch
		branch=$(git current-branch) || return $?
		if (__remote_is gitea || __remote_is ts.net) && command -v tea >/dev/null 2>&1; then
			repo
			repo=$(git repo-name) || return $?
			start i=0 elapsed
			start=$(date +%s)
			while tea pulls ls --fields head --output simple 2>/dev/null | grep -qF "${branch}"; do
				tea pull merge --style squash >/dev/null 2>&1 || true
				if ! tea pulls ls --fields head --output simple 2>/dev/null | grep -qF "${branch}"; then
					break
				fi
				i=$((i + 1))
				elapsed=$(($(date +%s) - start))
				echo "'${repo}/${branch}' is still merging... (${i}, ${elapsed} s)"
				sleep 10
			done
		elif command -v gh >/dev/null 2>&1; then
			gh pr merge --auto --delete-branch --squash || return $?
		else
			echo "'__git_merge': no PR tool (tea/gh) available" >&2
			return 1
		fi
		def_branch
		def_branch=$(git default-local-branch) || return $?
		ca
		if [ -n "$exit_after" ]; then
			__git_checkout_close "$def_branch" --delete --exit
		else
			__git_checkout_close "$def_branch" --delete
		fi
	}

	# orchestrate: optionally branch+PR, add all, commit+push loop, optionally merge
	__git_all() {
		title='' nv='' force='' web='' exit_after='' merge=''
		remaining
		remaining=
		while [ "$#" -gt 0 ]; do
			case "$1" in
			--title=*)
				title="${1#--title=}"
				shift
				;;
			--title)
				title="$2"
				shift 2
				;;
			--no-verify)
				nv=1
				shift
				;;
			--force)
				force=1
				shift
				;;
			--web)
				web=1
				shift
				;;
			--exit)
				exit_after=1
				shift
				;;
			--merge)
				merge=1
				shift
				;;
			*)
				remaining=${remaining:+${remaining} }$1
				shift
				;;
			esac
		done
		if [ -n "$title" ]; then
			__git_checkout_open --title="$title" || return $?
		fi
		# shellcheck disable=SC2086
		git add --all ${remaining}
		cp
		set --
		[ -n "$nv" ] && set -- "$@" --no-verify
		[ -n "$force" ] && set -- "$@" --force
		[ -n "$web" ] && set -- "$@" --web
		[ -z "$merge" ] && [ -n "$exit_after" ] && set -- "$@" --exit
		__git_commit_until_push "$@" || return $?
		if [ -n "$merge" ]; then
			ma
			if [ -n "$exit_after" ]; then
				__git_merge --exit
			else
				__git_merge
			fi
		fi
	}

	# --- navigation / info ---

	cdr() { cd "$(git repo-root)"; }

	yield_git_repos() {
		for _dir in */; do
			[ -d "${_dir}/.git" ] && realpath -- "${_dir}"
		done
	}

	if command -v watch >/dev/null 2>&1; then
		wg() {
			watch --color --interval 2 --no-title --no-wrap -- '
                echo "==== status ==================================================================="
                git -c color.ui=always status --short
                if ! git diff --quiet; then
                    printf "\n==== diff =====================================================================\n"
                    git -c color.ui=always diff --stat
                fi
                branch=$(printf "%-6s" "$(git default-local-branch)")
                if ! git diff-remote --quiet; then
                    printf "\n==== diff origin/%s =======================================================\n" "$branch"
                    git -c color.ui=always diff-remote --stat
                fi
            '
		}
	fi

	# --- branch management (fzf-assisted, override auto-generated stubs) ---

	gbd() {
		if [ "$#" -eq 0 ]; then
			git branch --format='%(refname:short)' |
				fzf --multi | while IFS= read -r _branch; do
				git branch-delete "${_branch}"
			done
		else
			for _branch in "$@"; do git branch-delete "${_branch}"; done
		fi
	}
	gbdr() {
		git fetch-default || return $?
		if [ "$#" -eq 0 ]; then
			git branch --color=never --remotes |
				awk '!/->/' |
				fzf --multi |
				sed -E 's|^[[:space:]]*origin/||' |
				xargs -r -I{} git push --delete origin "{}"
		else
			git push --delete origin "$@"
		fi
	}
	gcbr() {
		branch
		if [ "$#" -eq 0 ]; then
			branch=$(git branch --color=never --remotes |
				awk '!/->/{ print $1 }' |
				fzf |
				sed -E 's|^[[:space:]]*origin/||')
		else
			branch=$1
		fi
		git checkout -b "${branch}" -t "origin/${branch}"
	}
	gco() {
		branch
		if [ "$#" -eq 0 ]; then
			branch=$(git branch --format='%(refname:short)' | fzf)
		else
			branch=$1
		fi
		git checkout "${branch}"
	}

	# clone a repo, install pre-commit hooks, allow direnv
	gcl() {
		if [ "$#" -eq 0 ]; then
			echo "'gcl' expected [1..2] arguments REPO [DIR]; got $#" >&2
			return 1
		fi
		repo="$1" dir
		dir=${2:-$(basename "${1%.git}")}
		git clone --recurse-submodules "$repo" "$dir" || return $?
		orig
		orig=$(pwd)
		cd "$dir" || return $?
		command -v prek >/dev/null 2>&1 && prek install || true
		if command -v direnv >/dev/null 2>&1 && { [ -f .env ] || [ -f .envrc ]; }; then
			direnv allow . || true
		fi
		cd "$orig"
	}

	# checkout file(s); if first arg is a valid ref, fetch and checkout from that ref
	gcof() {
		if [ "$#" -eq 0 ]; then
			git checkout -- .
		else
			if git is-valid-ref "$1" 2>/dev/null; then
				git fetch-default || return $?
				ref=$1
				shift
				git checkout "${ref}" -- "$@"
			else
				git checkout -- "$@"
			fi
		fi
	}

	# checkout file(s) from the default remote branch
	gcfm() {
		git fetch-default || return $?
		branch
		branch=$(git default-remote-branch) || return $?
		git checkout "$branch" -- "$@"
	}

	# create branch + empty commit + push + PR; args: [TITLE [NUM [PART]]]
	gcb() {
		case "$#" in
		0) __git_checkout_open ;;
		1) __git_checkout_open --title "$1" ;;
		2) __git_checkout_open --title "$1" --num "$2" ;;
		3) __git_checkout_open --title "$1" --num "$2" --part ;;
		*)
			echo "'gcb' expected [0..3] arguments TITLE NUM PART; got $#" >&2
			return 1
			;;
		esac
	}

	# --- tagging ---

	gta() {
		if [ "$#" -eq 0 ]; then
			if command -v bump-my-version >/dev/null 2>&1; then
				git tag-add "$(bump-my-version show current_version)" HEAD
			else
				echo "'gta' expected 'bump-my-version' to be available" >&2
				return 1
			fi
		elif [ "$#" -eq 1 ]; then
			git tag-add "$1" HEAD
		elif [ $(($# % 2)) -eq 0 ]; then
			while [ "$#" -ge 2 ]; do
				git tag-add "$1" "$2"
				shift 2
			done
		else
			echo "'gta' expected 0, 1, or an even number of arguments; got $#" >&2
			return 1
		fi
	}

	# --- commit + push variants ---
	gc() { __git_commit_push; }
	gcn() { __git_commit_push --no-verify; }
	gcf() { __git_commit_push --force; }
	gcnf() { __git_commit_push --no-verify --force; }
	gcw() { __git_commit_push --web; }
	gcnw() { __git_commit_push --no-verify --web; }
	gcfw() { __git_commit_push --force --web; }
	gcnfw() { __git_commit_push --no-verify --force --web; }
	gce() { __git_commit_push --exit; }
	gcne() { __git_commit_push --no-verify --exit; }
	gcfe() { __git_commit_push --force --exit; }
	gcnfe() { __git_commit_push --no-verify --force --exit; }
	gcx() { __git_commit_push --web --exit; }
	gcnx() { __git_commit_push --no-verify --web --exit; }
	gcfx() { __git_commit_push --force --web --exit; }
	gcnfx() { __git_commit_push --no-verify --force --web --exit; }

	# --- add + commit + push variants ---
	gg() { __git_all "$@"; }
	ggn() { __git_all --no-verify "$@"; }
	ggf() { __git_all --force "$@"; }
	ggnf() { __git_all --no-verify --force "$@"; }
	ggw() { __git_all --web "$@"; }
	ggnw() { __git_all --no-verify --web "$@"; }
	ggfw() { __git_all --force --web "$@"; }
	ggnfw() { __git_all --no-verify --force --web "$@"; }
	gge() { __git_all --exit "$@"; }
	ggne() { __git_all --no-verify --exit "$@"; }
	ggfe() { __git_all --force --exit "$@"; }
	ggnfe() { __git_all --no-verify --force --exit "$@"; }
	ggm() { __git_all --merge "$@"; }
	ggnm() { __git_all --no-verify --merge "$@"; }
	ggfm() { __git_all --force --merge "$@"; }
	ggnfm() { __git_all --no-verify --force --merge "$@"; }
	ggx() { __git_all --merge --exit "$@"; }
	ggnx() { __git_all --no-verify --merge --exit "$@"; }
	ggfx() { __git_all --force --merge --exit "$@"; }
	ggnfx() { __git_all --no-verify --force --merge --exit "$@"; }

	# --- branch + PR + add + commit + push variants (TITLE required) ---
	ggc() {
		[ "$#" -ge 1 ] || {
			echo "'ggc' expected [1..) arguments TITLE" >&2
			return 1
		}
		title=$1
		shift
		__git_all --title="$title" "$@"
	}
	ggcn() {
		[ "$#" -ge 1 ] || {
			echo "'ggcn' expected [1..) arguments TITLE" >&2
			return 1
		}
		title=$1
		shift
		__git_all --title="$title" --no-verify "$@"
	}
	ggcf() {
		[ "$#" -ge 1 ] || {
			echo "'ggcf' expected [1..) arguments TITLE" >&2
			return 1
		}
		title=$1
		shift
		__git_all --title="$title" --force "$@"
	}
	ggcnf() {
		[ "$#" -ge 1 ] || {
			echo "'ggcnf' expected [1..) arguments TITLE" >&2
			return 1
		}
		title=$1
		shift
		__git_all --title="$title" --no-verify --force "$@"
	}
	ggcw() {
		[ "$#" -ge 1 ] || {
			echo "'ggcw' expected [1..) arguments TITLE" >&2
			return 1
		}
		title=$1
		shift
		__git_all --title="$title" --web "$@"
	}
	ggcnw() {
		[ "$#" -ge 1 ] || {
			echo "'ggcnw' expected [1..) arguments TITLE" >&2
			return 1
		}
		title=$1
		shift
		__git_all --title="$title" --no-verify --web "$@"
	}
	ggcfw() {
		[ "$#" -ge 1 ] || {
			echo "'ggcfw' expected [1..) arguments TITLE" >&2
			return 1
		}
		title=$1
		shift
		__git_all --title="$title" --force --web "$@"
	}
	ggcnfw() {
		[ "$#" -ge 1 ] || {
			echo "'ggcnfw' expected [1..) arguments TITLE" >&2
			return 1
		}
		title=$1
		shift
		__git_all --title="$title" --no-verify --force --web "$@"
	}
	ggce() {
		[ "$#" -ge 1 ] || {
			echo "'ggce' expected [1..) arguments TITLE" >&2
			return 1
		}
		title=$1
		shift
		__git_all --title="$title" --exit "$@"
	}
	ggcne() {
		[ "$#" -ge 1 ] || {
			echo "'ggcne' expected [1..) arguments TITLE" >&2
			return 1
		}
		title=$1
		shift
		__git_all --title="$title" --no-verify --exit "$@"
	}
	ggcfe() {
		[ "$#" -ge 1 ] || {
			echo "'ggcfe' expected [1..) arguments TITLE" >&2
			return 1
		}
		title=$1
		shift
		__git_all --title="$title" --force --exit "$@"
	}
	ggcnfe() {
		[ "$#" -ge 1 ] || {
			echo "'ggcnfe' expected [1..) arguments TITLE" >&2
			return 1
		}
		title=$1
		shift
		__git_all --title="$title" --no-verify --force --exit "$@"
	}
	ggcm() {
		[ "$#" -ge 1 ] || {
			echo "'ggcm' expected [1..) arguments TITLE" >&2
			return 1
		}
		title=$1
		shift
		__git_all --title="$title" --merge "$@"
	}
	ggcnm() {
		[ "$#" -ge 1 ] || {
			echo "'ggcnm' expected [1..) arguments TITLE" >&2
			return 1
		}
		title=$1
		shift
		__git_all --title="$title" --no-verify --merge "$@"
	}
	ggcfm() {
		[ "$#" -ge 1 ] || {
			echo "'ggcfm' expected [1..) arguments TITLE" >&2
			return 1
		}
		title=$1
		shift
		__git_all --title="$title" --force --merge "$@"
	}
	ggcnfm() {
		[ "$#" -ge 1 ] || {
			echo "'ggcnfm' expected [1..) arguments TITLE" >&2
			return 1
		}
		title=$1
		shift
		__git_all --title="$title" --no-verify --force --merge "$@"
	}
	ggcx() {
		[ "$#" -ge 1 ] || {
			echo "'ggcx' expected [1..) arguments TITLE" >&2
			return 1
		}
		title=$1
		shift
		__git_all --title="$title" --merge --exit "$@"
	}
	ggcnx() {
		[ "$#" -ge 1 ] || {
			echo "'ggcnx' expected [1..) arguments TITLE" >&2
			return 1
		}
		title=$1
		shift
		__git_all --title="$title" --no-verify --merge --exit "$@"
	}
	ggcfx() {
		[ "$#" -ge 1 ] || {
			echo "'ggcfx' expected [1..) arguments TITLE" >&2
			return 1
		}
		title=$1
		shift
		__git_all --title="$title" --force --merge --exit "$@"
	}
	ggcnfx() {
		[ "$#" -ge 1 ] || {
			echo "'ggcnfx' expected [1..) arguments TITLE" >&2
			return 1
		}
		title=$1
		shift
		__git_all --title="$title" --no-verify --force --merge --exit "$@"
	}

	# --- push variants (override auto-generated gp) ---
	gp() { __git_push; }
	gpn() { __git_push --no-verify; }
	gpf() { __git_push --force; }
	gpfn() { __git_push --force --no-verify; }
	gpw() { __git_push --web; }
	gpnw() { __git_push --no-verify --web; }
	gpfw() { __git_push --force --web; }
	gpfnw() { __git_push --force --no-verify --web; }
	gpe() { __git_push --exit; }
	gpne() { __git_push --no-verify --exit; }
	gpfe() { __git_push --force --exit; }
	gpfne() { __git_push --force --no-verify --exit; }
	gpx() { __git_push --web --exit; }
	gpnx() { __git_push --no-verify --web --exit; }
	gpfx() { __git_push --force --web --exit; }
	gpfnx() { __git_push --force --no-verify --web --exit; }

	# --- checkout default branch ---
	gm() { __git_checkout_close "$(git default-local-branch)"; }
	gmd() { __git_checkout_close "$(git default-local-branch)" --delete; }
	gmx() { __git_checkout_close "$(git default-local-branch)" --delete --exit; }

	# --- PR operations ---
	gw() { __git_view; }
	ghc() {
		if [ "$#" -eq 0 ]; then
			__git_create
		elif [ "$#" -eq 1 ]; then
			__git_create --title "$1"
		elif [ "$#" -eq 2 ]; then
			__git_create --title "$1" --body "$2"
		else
			echo "'ghc' expected [0..2] arguments TITLE BODY; got $#" >&2
			return 1
		fi
	}
	ghe() {
		title='' body='' remaining_count=0 remaining_1='' remaining_2=''
		while [ "$#" -gt 0 ]; do
			case "$1" in
			--title=*)
				title="${1#--title=}"
				shift
				;;
			--title)
				title="$2"
				shift 2
				;;
			--body=*)
				body="${1#--body=}"
				shift
				;;
			--body)
				body="$2"
				shift 2
				;;
			*)
				remaining_count=$((remaining_count + 1))
				case "${remaining_count}" in
				1) remaining_1=$1 ;;
				2) remaining_2=$1 ;;
				esac
				shift
				;;
			esac
		done
		if [ "${remaining_count}" -eq 1 ]; then
			if [ -n "$title" ]; then
				echo "'ghe' got 1 positional arg but also --title" >&2
				return 1
			fi
			title=${remaining_1}
		elif [ "${remaining_count}" -ge 2 ]; then
			if [ -n "$title" ]; then
				echo "'ghe' got 2 positional args but also --title" >&2
				return 1
			fi
			if [ -n "$body" ]; then
				echo "'ghe' got 2 positional args but also --body" >&2
				return 1
			fi
			title=${remaining_1}
			body=${remaining_2}
		fi
		set --
		[ -n "$title" ] && set -- "$@" --title "$title"
		[ -n "$body" ] && set -- "$@" --body "$body"
		if (__remote_is gitea || __remote_is ts.net) && command -v tea >/dev/null 2>&1; then
			tea pulls edit "$@"
			return $?
		fi
		if command -v gh >/dev/null 2>&1; then
			gh pr edit "$@"
			return $?
		fi
		echo "'ghe': no PR tool (tea/gh) available" >&2
		return 1
	}
	ghm() { __git_merge; }
	ghx() { __git_merge --exit; }

	# --- remote management ---
	add_remote() {
		if [ "$#" -le 1 ]; then
			echo "'add-remote' expected [2..) arguments NAME URL; got $#" >&2
			return 1
		fi
		git remote add "$@"
		git remote set-url --push "$@"
	}
	remove_remote() {
		if [ "$#" -eq 0 ]; then
			echo "'remove-remote' expected [1..) arguments NAME; got $#" >&2
			return 1
		fi
		git remote remove "$@"
	}
	set_remote() {
		if [ "$#" -le 1 ]; then
			echo "'set-remote' expected [2..) arguments NAME URL; got $#" >&2
			return 1
		fi
		git remote set-url "$@" || return $?
		git remote set-url --push "$@"
	}

	# --- rebase ---
	grb() {
		git fetch-default || return $?
		branch
		branch=$(git default-remote-branch) || return $?
		git rebase --strategy=recursive --strategy-option=theirs "$branch"
	}
	grbp() {
		grb || return $?
		command -v prek >/dev/null 2>&1 && prek run --all-files || true
		__git_all --no-verify --force
	}
	grbw() {
		grb || return $?
		command -v prek >/dev/null 2>&1 && prek run --all-files || true
		__git_all --no-verify --force --web
	}
fi
