return {
    "magicduck/grug-far.nvim",
    version = "1.6.3", -- Last release supporting Neovim 0.10.
    config = function()
        require("grug-far").setup()
    end,
}
