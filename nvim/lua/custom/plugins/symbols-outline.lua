return {
    "simrat39/symbols-outline.nvim",
    config = function()
        require("symbols-outline").setup()
        require("utilities").keymap_set("n", "<Leader>ls", function()
            require("symbols-outline").toggle_outline()
        end, "Document [S]ymbols (list)")
    end,
    event = "VeryLazy",
}
