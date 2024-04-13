return {
    "nvim-telescope/telescope-live-grep-args.nvim",
    config = function()
        require("telescope").load_extension("live_grep_args")
        require("utilities").keymap_set("n", "<Leader>lG", function()
            require("telescope").extensions.live_grep_args.live_grep_args()
        end, "Live [G]rep (args)")
    end,
    dependencies = "nvim-telescope/telescope.nvim",
}
