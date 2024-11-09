return {
    {
        "copilotc-nvim/copilotchat.nvim",
        branch = "canary",
        build = "make tiktoken", -- Only on MacOS or Linux
        config = function()
            local keymap_set = require("utilities").keymap_set

            keymap_set({ "n", "v" }, "<Leader>cc", ":CopilotChat<CR>", "copilot [c]hat")
        end,
        dependencies = {
            { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
            { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
        },
        opts = { debug = true },
        -- See Commands section for default commands if you want to lazy load on them
    },
}
