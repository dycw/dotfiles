return {
    "max397574/better-escape.nvim",
    config = function()
        local esc = "<Esc>"
        local same = { j = esc, k = esc }
        local diff = { j = { k = esc }, k = { j = esc } }
        require("better_escape").setup({
            mappings = {
                i = { j = same, k = same },
                c = diff,
                t = diff,
                v = diff,
                s = diff,
            },
        })
    end,
}
