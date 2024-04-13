return {
    "vonheikemen/searchbox.nvim",
    config = function()
        local keymap_set = require("utilities").keymap_set
        keymap_set("n", "/", "<Cmd>SearchBoxIncSearch<CR>", "Search")
        require("searchbox").setup({
            popup = {
                position = { row = "10%", col = "50%" },
                size = { width = "60%" },
                relative = "editor",
                border = {
                    style = "rounded",
                    text = { top = " Search ", top_align = "center" },
                },
            },
        })
    end,
    dependencies = { "muniftanjim/nui.nvim" },
    event = "VeryLazy",
}
