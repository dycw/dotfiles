return {
    "debugloop/telescope-undo.nvim",
    config = function()
        require("telescope").load_extension("undo")
        require("utilities").keymap_set("n", "<Leader>uh", function()
            require("telescope").extensions.undo.undo()
        end, "Undo [H]istory")
    end,
    dependencies = "nvim-telescope/telescope.nvim",
}