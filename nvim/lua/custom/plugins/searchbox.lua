return {
    "vonheikemen/searchbox.nvim",
    config = function()
        vim.keymap.set("n", "/", "<Cmd>SearchBoxIncSearch<CR>", { noremap = true, silent = true })
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
}
