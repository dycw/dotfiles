-- luacheck: push ignore
local v = vim
-- luacheck: pop

return {
    "neovim/nvim-lspconfig",
    opts = function()
        local keys = require("lazyvim.plugins.lsp.keymaps").get()
        keys[#keys + 1] = {
            "zj",
            function()
                v.diagnostic.jump({ count = 1, float = true })
            end,
        }
        keys[#keys + 1] = {
            "zk",
            function()
                v.diagnostic.jump({ count = -1, float = true })
            end,
        }
    end,
}
