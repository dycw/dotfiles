return {
    "nvim-telescope/telescope.nvim",
    config = function()
        require("telescope").load_extension("live_grep_args")

        require("utilities").keymap_set("n", "<Leader>lG", function()
            require("telescope").extensions.live_grep_args.live_grep_args()
        end, "Live Grep (args)")
    end,
    dependencies = {
        {
            "nvim-telescope/telescope-live-grep-args.nvim",
            version = "^1.0.0",
        },
    },
}
