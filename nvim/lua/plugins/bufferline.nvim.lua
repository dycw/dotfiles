return {
    "akinsho/bufferline.nvim",
    config = function()
        require("bufferline").setup()
    end,
    dependencies = "nvim-tree/nvim-web-devicons",
    keys = {
        { "<S-l>", "<Cmd>BufferLineCycleNext<CR>", desc = "Buffer next" },
        { "<S-h>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Buffer prev" },
    },
    opts = {

        always_show_bufferline = true,
    },
    version = "*",
}
