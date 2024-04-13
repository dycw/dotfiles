return {
    "snikimonkd/telescope-git-conflicts.nvim",
    config = function()
        require("telescope").load_extension("conflicts")
        require("utilities").keymap_set("n", "<Leader>gc", function()
            require("telescope").extensions.conflicts.conflicts({})
        end, "Git [C]onflicts")
    end,
    dependencies = "nvim-telescope/telescope.nvim",
}
