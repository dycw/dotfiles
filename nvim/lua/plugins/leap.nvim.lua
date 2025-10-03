return {
    "ggandor/leap.nvim",
    config = function()
        local leap = require("leap")
        leap.add_default_mappings()
        leap.opts.labels = {} -- auto-jump to the first match

        require("utilities").keymap_set({ "n", "x", "o" }, "gs", function()
            require("leap.remote").action()
        end, "leap remote")
    end,
}
