return {
    "mizlan/iswap.nvim",
    config = function()
        local keymap_set = require("utilities").keymap_set
        local iswap = require("iswap")
        keymap_set("n", "<Leader>is", function()
            iswap.iswap()
        end, "i[s]wap")
        keymap_set("n", "<Leader>iw", function()
            iswap.iswap_with()
        end, "iswap [w]ith")
    end,
}
