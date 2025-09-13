-- luacheck: push ignore
local v = vim
-- luacheck: pop
local api = v.api
local fn = v.fn

return {
    "ggandor/leap.nvim",
    config = function()
        local leap = require("leap")
        leap.add_default_mappings()
        leap.opts.labels = {} -- auto-jump to the first match

        require("utilities").keymap_set({ "n", "x", "o" }, "gs", function()
            require("leap.remote").action()
        end, "leap remote")

        api.nvim_create_autocmd("CmdlineLeave", {
            group = api.nvim_create_augroup("LeapOnSearch", {}),
            callback = function()
                local ev = v.v.event
                local is_search_cmd = (ev.cmdtype == "/") or (ev.cmdtype == "?")
                local cnt = fn.searchcount().total

                if is_search_cmd and not ev.abort and (cnt > 1) then
                    -- Allow CmdLineLeave-related chores to be completed before
                    -- invoking Leap.
                    v.schedule(function()
                        -- We want "safe" labels, but no auto-jump (as the search
                        -- command already does that), so just use `safe_labels`
                        -- as `labels`, with n/N removed.
                        local safe_labels = require("leap").opts.safe_labels
                        if type(safe_labels) == "string" then
                            safe_labels = fn.split(safe_labels, "\\zs")
                        end
                        local labels = v.tbl_filter(function(l)
                            return l:match("[^nN]")
                        end, safe_labels)
                        -- For `pattern` search, we never need to adjust conceallevel
                        -- (no user input).
                        local vim_opts = require("leap").opts.vim_opts
                        vim_opts["wo.conceallevel"] = nil

                        require("leap").leap({
                            pattern = fn.getreg("/"), -- last search pattern
                            target_windows = { fn.win_getid() },
                            opts = {
                                safe_labels = "",
                                labels = labels,
                                vim_opts = vim_opts,
                            },
                        })
                    end)
                end
            end,
        })
    end,
}
