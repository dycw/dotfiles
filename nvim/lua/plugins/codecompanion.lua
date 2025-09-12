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

        local headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer ${api_key}",
        }
        local parameters = { sync = true }
        local ai_engine = os.getenv("AI_ENGINE")
        local model
        if ai_engine == "lmstudio" then
            model = "bbecedefd826819d2c6b6465e88ca7b9b8ad3407" -- qwen3-coder:30b
        elseif ai_engine == "ollama" then
            model = "gpt-oss:20b"
        else
            print("Invalid value for 'AI_ENGINE'")
            model = ""
        end
        local strategy = {
            adapter = {
                name = ai_engine,
                model = model,
            },
        }
        require("codecompanion").setup({
            adapters = {
                http = {
                    lmstudio = function()
                        return require("codecompanion.adapters").extend("openai_compatible", {
                            env = { url = "LMSTUDIO_SERVER" },
                            headers = headers,
                            parameters = parameters,
                        })
                    end,
                    ollama = function()
                        return require("codecompanion.adapters").extend("ollama", {
                            env = { url = "OLLAMA_SERVER" },
                            headers = headers,
                            parameters = parameters,
                        })
                    end,
                },
                strategies = {
                    chat = strategy,
                    inline = strategy,
                    cmd = strategy,
                },
            },
        })
    end,
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
}
