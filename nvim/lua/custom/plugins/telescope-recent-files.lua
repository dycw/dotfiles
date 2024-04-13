return {
    "mollerhoj/telescope-recent-files.nvim",
    config = function()
        require("telescope").load_extension("recent-files")
        require("utilities").keymap_set("n", "<Leader>rf", function()
            require("telescope").extensions["recent-files"].recent_files({})
        end, "Recent [F]iles")
    end,
    dependencies = "nvim-telescope/telescope.nvim",
}
