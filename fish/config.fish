# xdg
set -Ux XDG_BIN_HOME (set -q XDG_BIN_HOME; and echo $XDG_BIN_HOME; or echo $HOME/.local/bin)
set -Ux XDG_CACHE_HOME (set -q XDG_CACHE_HOME; and echo $XDG_CACHE_HOME; or echo $HOME/.cache)
set -Ux XDG_CONFIG_DIRS (set -q XDG_CONFIG_DIRS; and echo $XDG_CONFIG_DIRS; or echo /etc/xdg)
set -Ux XDG_CONFIG_HOME (set -q XDG_CONFIG_HOME; and echo $XDG_CONFIG_HOME; or echo $HOME/.config)
set -Ux XDG_DATA_DIRS (set -q XDG_DATA_DIRS; and echo $XDG_DATA_DIRS; or echo /usr/local/share:/usr/share)
set -Ux XDG_DATA_HOME (set -q XDG_DATA_HOME; and echo $XDG_DATA_HOME; or echo $HOME/.local/share)
set -Ux XDG_RUNTIME_DIR (set -q XDG_RUNTIME_DIR; and echo $XDG_RUNTIME_DIR; or echo /run/user/(id -u))
set -Ux XDG_STATE_HOME (set -q XDG_STATE_HOME; and echo $XDG_STATE_HOME; or echo $HOME/.local/state)

if status is-interactive
    # Commands to run in interactive sessions can go here

    # bat
    if type -q batcat
        function cat
            batcat $argv
        end
        function catp
            batcat --plain $argv
        end
    end

    # cd
    function ..
        cd ..
    end
    function ...
        cd ../..
    end
    function ....
        cd ../../..
    end
    function cd-config
        cd "$XDG_CONFIG_HOME"
    end
    function cd-db
        cd "$HOME/Dropbox"
    end
    function cd-dbt
        cd "$HOME/Dropbox/Temporary"
    end
    function cd-df
        cd "$HOME/dotfiles"
    end
    function cd-dl
        cd "$HOME/Downloads"
    end
    function cdw
        cd "$HOME/work"
    end

    # direnv
    if type -q direnv
        direnv hook fish | source
    end

    # eza
    if type -q eza
        function l
            __eza --git-ignore $argv
        end
        function la
            __eza $argv
        end
        function ll
            __eza $argv
        end
        function __eza
            eza --all --classify=always --git --group --group-directories-first --header --long --time-style=long-iso $argv
        end
    end

    # fish
    fish_vi_key_bindings

    function fish-config
        $EDITOR "$XDG_CONFIG_HOME/fish/config.fish"
    end
    function fish-reload
        source "$XDG_CONFIG_HOME/fish/config.fish"
    end

    # fzf
    if type -q fzf
        fzf --fish | source
    end

    # git
    if type -q git
        # cherry-pick
        function gcp
            git cherry-pick $argv
        end
        # branch
        function delete-gone-branches
            git branch -vv | awk '/: gone]/{print $1}' | xargs -r git branch -D
        end
        # clone
        function gcl
            git clone --recurse-submodules $argv
        end
        # diff
        function gd
            git diff $argv
        end
        function gdc
            git diff --cached $argv
        end
        function gdm
            git diff origin/master $argv
        end
        # fetch
        function gf
            git fetch --all --force
            delete-gone-branches
        end
        # log
        function gl
            set -l args --abbrev-commit --decorate=short --pretty='format:%C(red)%h%C(reset) |%C(yellow)%d%C(reset) | %s | %Cgreen%cr%C(reset)'
            set -l n
            if test (count $argv) -eq 0
                set n 20
            else if string match -qr '^[0-9]+$' -- $argv[1]; and test $argv[1] -gt 0
                set n $argv[1]
            end
            if set -q n
                set args $args --max-count=$n
            end
            git log $args
        end
        # mv
        function gm
            git mv $argv
        end
        # rev-parse
        function cdr
            set -l root (git-repo-root)
            if test -n "$root"
                cd $root
            end
        end
        function git-repo-root
            if git rev-parse --show-toplevel >/dev/null 2>&1
                git rev-parse --show-toplevel
            end
        end
        # stash
        function gst
            git stash $argv
        end
        function gstd
            git stash drop $argv
        end
        function gstp
            git stash pop $argv
        end
        # status
        function gs
            git status $argv
        end
    end

    # local
    if test -f "$HOME/local.fish"
        source "$HOME/local.fish"
    end

    # neovim
    function cd-nvim-plugins
        cd "$XDG_CONFIG_HOME/nvim/lua/plugins"
    end
    function clean-neovim
        set dirs $XDG_STATE_HOME $XDG_DATA_HOME $XDG_STATE_HOME
        for dir in $dirs
            set nvim "$dir/nvim"
            echo "Cleaning '$nvim'..."
            rm -rf $nvim
        end
    end
    if type -q nvim
        set -gx EDITOR nvim
        set -gx VISUAL nvim

        function n
            nvim $argv
        end
    end

    # pre-commit
    if type -q pre-commit
        function pcau
            pre-commit autoupdate
        end
        function pci
            pre-commit install
        end
        function pca
            pre-commit run --all-files
        end
    end

    # starship
    if type -q starship
        starship init fish | source
    end

    # tailscale
    if type -q tailscale
        function ts-up
            set auth_key "$XDG_CONFIG_HOME/tailscale/auth-key.txt"
            if not test -f $auto_key
                echo "'$auto_key' does not exist"
                return 1
            end
            if not set -q TAILSCALE_LOGIN_SERVER
                echo "'\$TAILSCALE_LOGIN_SERVER' is not set"
                return 1
            end
            echo "Starting 'tailscaled' in the background..."
            sudo tailscaled &
            echo "Starting 'tailscale'..."
            sudo tailscale up --accept-dns --accept-routes --auth-key="file:$auth_key" \
                --login-server="$TAILSCALE_LOGIN_SERVER" --reset
        end
        function ts-exit-node
            sudo tailscale set --exit-node=qrt-nanode
        end
        function ts-no-exit-node
            sudo tailscale set --exit-node=
        end
    end

    # vim
    if type -q vim
        if not type -q nvim
            set -gx EDITOR vim
            set -gx VISUAL vim
        end

        function v
            vim $argv
        end
    end

    # zoxide
    if type -q zoxide
        zoxide init --cmd j fish | source
    end
end
