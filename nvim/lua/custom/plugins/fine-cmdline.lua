-- luacheck: push ignore vim
local set = vim.keymap.set
-- luacheck: pop
local opts = { noremap = true, silent = true }

return {
    "vonheikemen/fine-cmdline.nvim",
    config = function()
        set("n", ":", "<Cmd>FineCmdline<CR>", opts)
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
