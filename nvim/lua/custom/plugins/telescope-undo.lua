return {
    "debugloop/telescope-undo.nvim",
    config = function()
        local telescope = require("telescope")
        telescope.load_extension("undo")
        require("utilities").keymap_set("n", "<Leader>uh", function()
            telescope.extensions.undo.undo()
        end, "undo [h]istory")
    end,
    dependencies = "nvim-telescope/telescope.nvim",
}
