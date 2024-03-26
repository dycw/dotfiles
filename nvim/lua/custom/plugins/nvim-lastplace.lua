return {
    "ethanholz/nvim-lastplace",
    config = function()
        require("nvim-lastplace").setup()
    end,
    -- event = "VeryLazy",  -- this cannot be lazy
}
