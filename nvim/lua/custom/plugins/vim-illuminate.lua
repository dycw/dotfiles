return {
    "rrethy/vim-illuminate",
    config = function()
        require("illuminate").configure()
    end,
    event = "VeryLazy",
}
