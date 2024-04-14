return {
    "folke/trouble.nvim",
    config = function()
        local keymap_set = require("utilities").keymap_set
        local trouble = require("trouble")

        keymap_set("n", "<Leader>ld", function()
            trouble.open("document_diagnostics")
        end, "list [d]ocument diagnostics")
        keymap_set("n", "<Leader>lq", function()
            trouble.open("quickfix")
        end, "list [q]uick fix")
        keymap_set("n", "<Leader>lr", function()
            trouble.open("lsp_references")
        end, "list [r]eferences")
        keymap_set("n", "<Leader>lw", function()
            trouble.open("workspace_diagnostics")
        end, "list [w]orkspace diagnostics")
    end,
    dependencies = { "nvim-tree/nvim-web-devicons" },
}
