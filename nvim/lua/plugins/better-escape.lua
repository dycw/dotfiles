return {
    "max397574/better-escape.nvim",
    config = function()
        local inner = { j = "<Esc>", k = "<Esc>" }
        local outer = { j = inner, k = inner }
        require("better_escape").setup({
            mappings = {
                i = outer,
                c = outer,
                t = outer,
                v = outer,
                s = outer,
            },
        })
    end,
}
