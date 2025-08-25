-- luacheck: push ignore
local v = vim
-- luacheck: pop

return {
    "olimorris/codecompanion.nvim",
    config = function()
        local keymap_set = require("utilities").keymap_set
        keymap_set({ "n", "v" }, "<Leader>ca", "<Cmd>CodeCompanionActions<CR>", "CodeCompanion [a]ctions")
        keymap_set("n", "<Leader>c", "<Cmd>CodeCompanionChat Toggle<CR>", "[C]odeCompanion")
        keymap_set("v", "<Leader>c", "<Cmd>CodeCompanion<CR>", "[C]odeCompanion")
        keymap_set("v", "ga", "<Cmd>CodeCompanionChat Add<CR>", "CodeCompanion [a]dd")
        v.cmd([[cab cc CodeCompanion]])

        local strategy = {
            adapter = {
                name = "my_ollama",
                model = "qwen3-coder:30b",
            },
        }
        require("codecompanion").setup({
            adapters = {
                my_ollama = function()
                    return require("codecompanion.adapters").extend("ollama", {
                        env = { url = "OLLAMA_SERVER" },
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
                chat = strategy,
                inline = strategy,
                cmd = strategy,
            },
        })
    end,
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
}
