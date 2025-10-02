return {
    "okuuva/auto-save.nvim", -- forked from pocco81/auto-save.nvim
    config = function()
        require("utilities").keymap_set("n", "<leader>as", function()
            require("auto-save").toggle()
        end, "auto [s]ave")
        require("auto-save").setup({
            enabled = true,
            debounce_delay = 10,
        })
    end,
}
