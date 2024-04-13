return {
    "mollerhoj/telescope-recent-files.nvim",
    config = function()
        local telescope = require("telescope")
        telescope.load_extension("recent-files")
        require("utilities").keymap_set("n", "<Leader>rf", function()
            telescope.extensions["recent-files"].recent_files({})
        end, "Recent [F]iles")
    end,
    dependencies = "nvim-telescope/telescope.nvim",
    event = "VeryLazy",
}
