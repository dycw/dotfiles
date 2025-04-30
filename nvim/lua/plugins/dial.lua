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

        local augend = require("dial.augend")
        require("dial.config").augends:register_group({
            default = {
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
                augend.constant.new({
                    elements = { "&&", "||" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "<", ">" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "<=", ">=" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "BUY", "SELL" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "LOWER", "UPPER" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "START", "END", "STOP" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "True", "False" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "absolute", "relative" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "after", "before" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "and", "or" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "all", "any" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "ascending", "descending" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "backward", "forward" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "bottom", "top" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "bull", "bear" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "buy", "sell" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "ceil", "floor" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "close", "open" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "cloud", "local" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "column", "row" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "disable", "enable" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "down", "up" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "entry", "exit" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "first", "last" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "float", "int" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "gateway", "tws" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "head", "tail" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "high", "low" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "left", "right" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "long", "short" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "loss", "profit" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "lower", "upper" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "max", "min" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "max_value", "min_value" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "maximum", "minimum" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "minor", "major" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "no", "yes" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "on", "off" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "only", "skip" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "positive", "negative" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "start", "end", "stop" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "true", "false" },
                    word = true,
                    cyclic = true,
                }),
            },
        })
    end,
}
