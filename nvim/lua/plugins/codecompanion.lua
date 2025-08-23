return {
    "olimorris/codecompanion.nvim",
    config = function()
        local keymap_set = require("utilities").keymap_set
        keymap_set({ "n", "v" }, "<C-a>", "<Cmd>CodeCompanionActions<CR>", "CodeCompanion [a]ctions")
        keymap_set({ "n", "v" }, "<Leader>c", "<Cmd>CodeCompanionChat Toggle<CR>", "CodeCompanion [c]hat")
        keymap_set("v", "ga", "<Cmd>CodeCompanionChat Add<CR>", "CodeCompanion [a]dd")

        require("codecompanion").setup({
            adapters = {
                qrt_ollama = function()
                    return require("codecompanion.adapters").extend("ollama", {
                        env = {
                            url = "OLLAMA_URL",
                            api_key = "OLLAMA_API_KEY",
                        },
                        headers = {
                            ["Content-Type"] = "application/json",
                            ["Authorization"] = "Bearer ${api_key}",
                        },
                        parameters = {
                            sync = true,
                        },
                    })
                end,
            },
            strategies = {
                chat = {
                    adapter = {
                        name = "qrt_ollama",
                        model = "gpt-oss:20b",
                    },
                },
                inline = {
                    adapter = {
                        name = "qrt_ollama",
                        model = "gpt-oss:20b",
                    },
                },
                cmd = {
                    adapter = {
                        name = "qrt_ollama",
                        model = "gpt-oss:20b",
                    },
                },
            },
        })
    end,
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
}
