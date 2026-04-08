#!/usr/bin/env fish

#### local (interactive & non-interactive) ####################################

if test -d $HOME/.cargo/bin
    fish_add_path $HOME/.cargo/bin
end

#### interactive only #########################################################

if not status is-interactive
    exit
end

#### logs #####################################################################

function ci-log
    set -l sha (git rev-parse --short HEAD)
    set -l repo (basename (git rev-parse --show-toplevel))
    set -l branch (git current-branch)
    set -l log_dir ~/Dropbox/Temporary
    set -l log "$log_dir/logs—$sha—$repo—$branch.txt"
    set -l tmp (mktemp)

    clippy-log 2>&1 | tee $tmp
    set -l clippy_status $pipestatus[1]

    if test $clippy_status -ne 0
        mv $tmp $log
        return $clippy_status
    end

    : >$tmp

    nextest-log 2>&1 | tee $tmp
    set -l nextest_status $pipestatus[1]

    if test $nextest_status -ne 0
        mv $tmp $log
        return $nextest_status
    end

    rm -f $tmp
    : >$log
    return 0
end

function clippy-log
    env CLIPPY_CONF_DIR=.configs \
        cargo +stable clippy \
        --all-targets \
        --all-features \
        --locked
end

function nextest-log
    cargo +stable nextest run \
        --locked \
        --all-targets \
        --config-file .configs/nextest.toml \
        --profile ci 2>&1
end
