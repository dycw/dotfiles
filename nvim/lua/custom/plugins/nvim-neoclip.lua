return {
    "acksld/nvim-neoclip.lua",
    config = function()
        require("neoclip").setup({
            enable_persistent_history = true,
            keys = {
                telescope = {
                    i = {
                        paste = "<CR>",
                    },
                },
            },
        })
        require("utilities").keymap_set("n", "<Leader>nc", function()
            require("telescope").extensions.neoclip.neoclip()
        end, "Neo[C]lip")
    end,
    dependencies = {
        { "nvim-telescope/telescope.nvim" },
        { "kkharji/sqlite.lua", module = "sqlite" },
    },
}
