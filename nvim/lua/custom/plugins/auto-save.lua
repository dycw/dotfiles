return {
    "okuuva/auto-save.nvim", -- forked from pocco81/auto-save.nvim
    config = function()
        require("utilities").keymap_set("n", "<leader>as", "<Cmd>ASToggle<CR>", "Toggle Trouble")
        require("auto-save").setup({
            enabled = false,
        })
    end,
    event = "VeryLazy",
}
