return {
    "mizlan/iswap.nvim",
    config = function()
        local keymap_set = require("utilities").keymap_set
        local iswap = require("iswap")
        keymap_set("n", "<Leader>is", function()
            iswap.iswap()
        end, "I[S]wap")
        keymap_set("n", "<Leader>iw", function()
            iswap.iswap_with()
        end, "ISwap [W]ith")
    end,
    event = "VeryLazy",
}
