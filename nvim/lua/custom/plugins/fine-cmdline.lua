return {
    "vonheikemen/fine-cmdline.nvim",
    config = function()
        local keymap_set = require("utilities").keymap_set
        keymap_set({ "n", "v" }, ":", "<Cmd>FineCmdline<CR>", "Command")
        keymap_set({ "n", "v" }, ";", "<Cmd>FineCmdline<CR>", "Command")
        require("fine-cmdline").setup({
            cmdline = { prompt = " " },
            popup = {
                relative = "editor",
                border = {
                    style = "rounded",
                    text = { top = " Command ", top_align = "center" },
                },
            },
        })
    end,
    dependencies = { "muniftanjim/nui.nvim" },
}
