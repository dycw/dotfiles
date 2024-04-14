return {
    "simrat39/symbols-outline.nvim",
    config = function()
        local symbols_outline = require("symbols-outline")
        symbols_outline.setup()
        require("utilities").keymap_set("n", "<Leader>ls", function()
            symbols_outline.toggle_outline()
        end, "list document [s]ymbols")
    end,
}
