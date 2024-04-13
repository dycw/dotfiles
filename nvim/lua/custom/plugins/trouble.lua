return {
    "folke/trouble.nvim",
    config = function()
        local keymap_set = require("utilities").keymap_set
        local trouble = require("trouble")

        keymap_set("n", "<Leader>ld", function()
            trouble.open("document_diagnostics")
        end, "[D]ocument Diagnostics (list)")
        keymap_set("n", "<Leader>lq", function()
            trouble.open("quickfix")
        end, "Quick [F]ix (list)")
        keymap_set("n", "<Leader>lr", function()
            trouble.open("lsp_references")
        end, "[R]eferences (list)")
        keymap_set("n", "<Leader>lw", function()
            trouble.open("workspace_diagnostics")
        end, "[W]orkspace diagnostics (list)")
    end,
    dependencies = { "nvim-tree/nvim-web-devicons" },
}
