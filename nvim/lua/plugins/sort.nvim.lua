-- luacheck: push ignore
local v = vim
-- luacheck: pop

return {
    "sqve/sort.nvim",
    config = function()
        v.keymap.set("v", "<Leader>so", "<Esc><Cmd>Sort<CR>", { desc = "S[o]rt" })
        v.keymap.set("v", "<Leader>sn", "<Esc><Cmd>Sort n<CR>", { desc = "Sort [N]umbers" })
    end,
    event = "VeryLazy",
}
