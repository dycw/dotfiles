return {
    "vonheikemen/fine-cmdline.nvim",
    config = function()
        vim.keymap.set("n", ":", "<Cmd>FineCmdline<CR>", { noremap = true, silent = true })
        require("fine-cmdline").setup({
            cmdline = { prompt = " " },
            popup = {
                relative = "editor",
                border = {
                    style = "rounded",
                    text = { top = " Command ", top_align = "center" },
                },
            },
        })
    end,
    dependencies = { "MunifTanjim/nui.nvim" },
}
