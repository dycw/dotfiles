-- luacheck: push ignore
local v = vim
-- luacheck: pop

return {
    "ggandor/leap.nvim",
    config = function()
        local leap = require("leap")
        local keymap_set = require("utilities").keymap_set

        leap.add_default_mappings()

        -- remote actions
        keymap_set({ "n", "x", "o" }, "gs", function()
            require("leap.remote").action()
        end, "leap remote")

        -- 1-character search (enhanced f/t motions)
        do
            -- Returns an argument table for `leap()`, tailored for f/t-motions.
            local function as_ft(key_specific_args)
                local common_args = {
                    inputlen = 1,
                    inclusive_op = true,
                    -- To limit search scope to the current line:
                    -- pattern = function (pat) return '\\%.l'..pat end,
                    opts = {
                        labels = "", -- force autojump
                        safe_labels = v.fn.mode(1):match("o") and "" or nil, -- [1]
                        case_sensitive = true, -- [2]
                    },
                }
                return v.tbl_deep_extend("keep", common_args, key_specific_args)
            end

            local clever = require("leap.user").with_traversal_keys -- [3]
            local clever_f = clever("f", "F")
            local clever_t = clever("t", "T")

            for key, args in pairs({
                f = { opts = clever_f },
                F = { backward = true, opts = clever_f },
                t = { offset = -1, opts = clever_t },
                T = { backward = true, offset = 1, opts = clever_t },
            }) do
                keymap_set({ "n", "x", "o" }, key, function()
                    leap.leap(as_ft(args))
                end)
            end
        end
    end,
    opts = {
        labels = {}, -- force auto-jumping to the first match
    },
}
