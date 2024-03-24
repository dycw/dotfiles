local mode = { "n", "o", "x" }
return {
    "chrisgrieser/nvim-spider",
    keys = {
        { "w", "<Cmd>lua require('spider').motion('w')<CR>", mode = mode },
        { "e", "<Cmd>lua require('spider').motion('e')<CR>", mode = mode },
        { "b", "<Cmd>lua require('spider').motion('b')<CR>", mode = mode },
        { "ge", "<Cmd>lua require('spider').motion('ge')<CR>", mode = mode },
    },
}
