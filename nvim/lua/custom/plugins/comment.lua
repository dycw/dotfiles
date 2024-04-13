return {
    "numtostr/comment.nvim",
    config = function()
        require("Comment").setup({
            toggler = {
                line = "<Leader>c",
                block = "<Leader>cb",
            },
            opleader = {
                line = "<Leader>c",
                block = "<Leader>b",
            },
        })
        --
    end,
}
