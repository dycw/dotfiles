return {
    "sqve/sort.nvim",
    config = function()
        local keymap_set = require("utilities").keymap_set
        keymap_set("n", "<Leader>so", "<Cmd>Sort<CR>", "Sort")
        keymap_set("n", "<Leader>sn", "<Cmd>Sort n<CR>", "Sort (numbers)")
        keymap_set("v", "<Leader>so", "<Esc><Cmd>Sort<CR>", "Sort")
        keymap_set("v", "<Leader>sn", "<Esc><Cmd>Sort n<CR>", "Sort (numbers)")
    end,
    event = "VeryLazy",
}
