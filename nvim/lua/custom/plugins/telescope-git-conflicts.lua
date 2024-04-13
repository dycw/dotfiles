return {
    "snikimonkd/telescope-git-conflicts.nvim",
    config = function()
        local telescope = require("telescope")
        telescope.load_extension("conflicts")
        require("utilities").keymap_set("n", "<Leader>gc", function()
            telescope.extensions.conflicts.conflicts({})
        end, "Git [C]onflicts")
    end,
    dependencies = "nvim-telescope/telescope.nvim",
    event = "VeryLazy",
}
