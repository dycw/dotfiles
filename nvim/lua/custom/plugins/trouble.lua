return {
    "folke/trouble.nvim",
    config = function()
        local keymap_set = require("utilities").keymap_set
        keymap_set("n", "<Leader>ld", function()
            require("trouble").open("document_diagnostics")
        end, "Document diagnostics (list)")
        keymap_set("n", "<Leader>ll", function()
            require("trouble").open("loclist")
        end, "Loc list (list)")
        keymap_set("n", "<Leader>lq", function()
            require("trouble").open("quickfix")
        end, "Quickfix (list)")
        keymap_set("n", "<Leader>lr", function()
            require("trouble").open("lsp_references")
        end, "References (list)")
        keymap_set("n", "<Leader>lw", function()
            require("trouble").open("workspace_diagnostics")
        end, "Workspace diagnostics (list)")
    end,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
}
