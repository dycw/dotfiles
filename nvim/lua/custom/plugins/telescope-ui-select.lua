return {
    "nvim-telescope/telescope-ui-select.nvim",
    config = function()
        require("telescope").load_extension("ui-select")
        require("telescope.themes").get_dropdown({})
    end,
    dependencies = "nvim-telescope/telescope.nvim",
}
