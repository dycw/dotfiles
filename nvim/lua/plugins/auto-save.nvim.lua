-- luacheck: push ignore
local v = vim
-- luacheck: pop

return {
    "okuuva/auto-save.nvim", -- forked from pocco81/auto-save.nvim
    config = function()
        v.keymap.set("n", "<leader>as", function()
            require("auto-save").toggle()
        end, { desc = "auto [s]ave" })
        require("auto-save").setup({
            enabled = true,
            debounce_delay = 10,
        })
    end,
    event = "VeryLazy",
}
