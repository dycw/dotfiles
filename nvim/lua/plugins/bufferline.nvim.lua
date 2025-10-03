return {
    "akinsho/bufferline.nvim",
    config = function()
        require("bufferline").setup()
        local keymap_set = require("utilities").keymap_set
        keymap_set("n", "<S-l>", "<Cmd>BufferLineCycleNext<CR>", "Buffer next")
        keymap_set("n", "<S-h>", "<Cmd>BufferLineCyclePrev<CR>", "Buffer prev")
    end,
    dependencies = "nvim-tree/nvim-web-devicons",
    version = "*",
}
