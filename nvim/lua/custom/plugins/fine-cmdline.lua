return {
    "vonheikemen/fine-cmdline.nvim",
    config = function()
        local fine_cmdline = require("fine-cmdline")
        local keymap_set = require("utilities").keymap_set

        fine_cmdline.setup({
            cmdline = { prompt = " " },
            popup = {
                relative = "editor",
                border = {
                    style = "rounded",
                    text = { top = " Command ", top_align = "center" },
                },
            },
        })

        keymap_set({ "n", "v" }, ":", function()
            fine_cmdline.open()
        end, "Command")
        keymap_set({ "n", "v" }, ";", function()
            fine_cmdline.open()
        end, "Command")
    end,
    dependencies = { "muniftanjim/nui.nvim" },
    event = "VeryLazy",
}
