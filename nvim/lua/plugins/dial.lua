-- luacheck: push ignore
local v = vim
-- luacheck: pop

return {
    "monaqa/dial.nvim",
    config = function()
        local keymap_set = require("utilities").keymap_set

        local map = require("dial.map")
        keymap_set("n", "<C-a>", map.inc_normal(), "Increment")
        keymap_set("n", "<C-x>", map.dec_normal(), "Decrement")
        keymap_set("v", "<C-a>", map.inc_visual(), "Increment")
        keymap_set("v", "<C-x>", map.dec_visual(), "Decrement")
        keymap_set("v", "g<C-a>", map.inc_gvisual(), "Increment")
        keymap_set("v", "g<C-x>", map.dec_gvisual(), "Decrement")

        local function titlecase(s)
            return s:sub(1, 1):upper() .. s:sub(2):lower()
        end

        local augend = require("dial.augend")
        local function register_group(words)
            return {
                augend.constant.new({
                    elements = v.tbl_map(string.upper, words),
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = v.tbl_map(titlecase, words),
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = v.tbl_map(string.lower, words),
                    word = true,
                    cyclic = true,
                }),
            }
        end

        -- build groups
        local groups = {
            { "absolute", "relative" },
            { "after", "before" },
            { "all", "any" },
            { "and", "or" },
            { "ascending", "descending" },
            { "backward", "forward" },
            { "bottom", "top" },
            { "bull", "bear" },
            { "buy", "sell" },
            { "ceil", "floor" },
            { "close", "open" },
            { "cloud", "local" },
            { "cold", "hot" },
            { "column", "row" },
            { "disable", "enable" },
            { "down", "up" },
            { "entry", "exit" },
            { "first", "last" },
            { "float", "int" },
            { "gateway", "tws" },
            { "head", "tail" },
            { "high", "low" },
            { "left", "right" },
            { "long", "short" },
            { "loss", "profit" },
            { "lower", "upper" },
            { "max", "min" },
            { "max_value", "min_value" },
            { "maximum", "minimum" },
            { "minor", "major" },
            { "no", "yes" },
            { "on", "off" },
            { "only", "skip" },
            { "positive", "negative" },
            { "start", "end", "stop" },
            { "true", "false" },
        }

        local groups_all_cases = {}
        for _, pair in ipairs(groups) do
            table.insert(
                groups_all_cases,
                augend.constant.new({
                    elements = v.tbl_map(string.upper, pair),
                    word = true,
                    cyclic = true,
                })
            )
            table.insert(
                groups_all_cases,
                augend.constant.new({
                    elements = v.tbl_map(titlecase, pair),
                    word = true,
                    cyclic = true,
                })
            )
            table.insert(
                groups_all_cases,
                augend.constant.new({
                    elements = v.tbl_map(string.lower, pair),
                    word = true,
                    cyclic = true,
                })
            )
        end

        -- register all
        require("dial.config").augends:register_group({
            default = v.list_extend({
                augend.integer.alias.decimal,
                augend.integer.alias.decimal_int,
                augend.integer.alias.hex,
                augend.integer.alias.octal,
                augend.integer.alias.binary,
                augend.date.alias["%Y/%m/%d"],
                augend.date.alias["%Y-%m-%d"],
                augend.date.alias["%H:%M:%S"],
                augend.date.alias["%H:%M"],
                augend.constant.alias.bool,
                augend.semver.alias.semver,
            }, groups_all_cases),
        })
    end,
}
