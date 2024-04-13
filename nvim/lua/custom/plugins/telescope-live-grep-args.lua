return {
    "nvim-telescope/telescope-live-grep-args.nvim",
    config = function()
        local telescope = require("telescope")
        telescope.load_extension("live_grep_args")
        require("utilities").keymap_set("n", "<Leader>lG", function()
            telescope.extensions.live_grep_args.live_grep_args()
        end, "Live [G]rep (args)")
    end,
    dependencies = "nvim-telescope/telescope.nvim",
    event = "VeryLazy",
}
