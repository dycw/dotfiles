#!/usr/bin/env fish

if not status is-interactive; or not begin
        type -q bat; or type -q batcat
    end
    exit
end

###############################################################################

if not type -q bat; and type -q batcat
    function bat
        batcat $argv
    end
end

function cat
    bat $argv
end

function catp
    bat --style=plain $argv
end
