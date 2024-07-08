return {
    "folke/trouble.nvim",
    config = function()
        local keymap_set = require("utilities").keymap_set
        local trouble = require("trouble")

        trouble.setup()

        keymap_set("n", "<Leader>ld", function()
            trouble.open({ mode = "diagnostics", focus = false })
        end, "list [d]ocument diagnostics")
        keymap_set("n", "<Leader>lq", function()
            trouble.open({ mode = "quickfix", focus = false })
        end, "list [q]uick fix")
        keymap_set("n", "<Leader>lr", function()
            trouble.open({ mode = "lsp_references", focus = false })
        end, "list [r]eferences")
        keymap_set("n", "<Leader>ls", function()
            trouble.open({ mode = "symbols", focus = false })
        end, "list [s]ymbols")
        keymap_set("n", "<Leader>ly", function()
            trouble.open({ mode = "symbols", focus = false })
        end, "list document s[y]mbols")
    end,
    dependencies = { "nvim-tree/nvim-web-devicons" },
}
