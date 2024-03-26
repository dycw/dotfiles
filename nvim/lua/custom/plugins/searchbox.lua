-- luacheck: push ignore vim
local set = vim.keymap.set
-- luacheck: pop
local opts = { noremap = true, silent = true }

return {
    "vonheikemen/searchbox.nvim",
    config = function()
        set("n", "/", "<Cmd>SearchBoxIncSearch<CR>", opts)
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
