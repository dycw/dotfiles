return {
    "nvim-telescope/telescope-project.nvim",
    config = function()
        local telescope = require("telescope")
        telescope.setup({
            extensions = {
                project = {
                    base_dirs = {
                        { "~/dotfiles", max_depth = 1 },
                        { "~/work", max_depth = 1 },
                    },
                    hidden_files = true,
                    sync_with_nvim_tree = true,
                },
            },
        })
        telescope.load_extension("recent-files")
        require("utilities").keymap_set("n", "<Leader>pr", function()
            require("telescope").extensions.project.project()
        end, "P[r]oject")
    end,
    dependencies = "nvim-telescope/telescope.nvim",
}
