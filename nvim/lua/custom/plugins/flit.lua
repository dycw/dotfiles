return {
    "ggandor/flit.nvim",
    config = function()
        require("flit").setup()
    end,
    dependencies = { "ggandor/leap.nvim" },
    event = "VeryLazy",
}
