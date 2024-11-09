return {
    {
        "copilotc-nvim/copilotchat.nvim",
        branch = "canary",
        build = "make tiktoken", -- Only on MacOS or Linux
        dependencies = {
            { "zbirenbaum/copilot.lua" },
            { "nvim-lua/plenary.nvim" },
        },
        keys = { { "<Leader>cc", ":CopilotChat<CR>", mode = { "n", "v" }, desc = "copilot [c]hat" } },
        opts = { debug = true, clear_chat_on_new_prompt = true },
    },
}
