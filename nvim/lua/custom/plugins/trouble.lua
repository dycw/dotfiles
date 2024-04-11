return {
    "folke/trouble.nvim",
    config = function()
        local keymap_set = require("utilities").keymap_set
        keymap_set("n", "<leader>tr", function()
            require("trouble").toggle()
        end, "Toggle Trouble")
        keymap_set("n", "<leader>lw", function()
            require("trouble").toggle("workspace_diagnostics")
        end, "Workspace diagnostics (list)")
        keymap_set("n", "<leader>ld", function()
            require("trouble").toggle("document_diagnostics")
        end, "Document diagnostics (list)")
        keymap_set("n", "<leader>lq", function()
            require("trouble").toggle("quickfix")
        end, "Quickfix (list)")
        keymap_set("n", "<Leader>ll", function()
            require("trouble").toggle("loclist")
        end, "Loc list (list)")
        keymap_set("n", "lr", function()
            require("trouble").toggle("lsp_references")
        end, "References (list)")
    end,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
}
