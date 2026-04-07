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
    set -l log ~/Dropbox/Temporary/logs.txt
    set -l tmp (mktemp)

    # run clippy
    clippy-log | tee $tmp
    set -l clippy_status $status

    if test $clippy_status -ne 0
        mv $tmp $log
        return $clippy_status
    end

    # reset temp
    : >$tmp

    # run nextest
    nextest-log | tee $tmp
    set -l nextest_status $status

    if test $nextest_status -ne 0
        mv $tmp $log
        return $nextest_status
    end

    # both succeeded → empty log
    rm -f $tmp
    : >$log
    return 0
end

function clippy-log
    env CLIPPY_CONF_DIR=.configs \
        cargo +stable clippy \
        --all-targets \
        --all-features \
        --locked 2>&1 | tee ~/Dropbox/Temporary/logs.txt
end

function nextest-log
    cargo +stable nextest run \
        --locked \
        --all-targets \
        --config-file .configs/nextest.toml \
        --profile ci 2>&1 | tee ~/Dropbox/Temporary/logs.txt
end
