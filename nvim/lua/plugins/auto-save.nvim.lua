return {
    "okuuva/auto-save.nvim", -- forked from pocco81/auto-save.nvim
    config = function()
        vim.keymap.set("n", "<leader>as", function()
            require("auto-save").toggle()
        end)
        require("auto-save").setup({
            enabled = true,
            debounce_delay = 10,
        })
    end,
}
