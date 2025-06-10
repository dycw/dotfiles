return {

    "tpope/vim-eunuch",
    config = function()
        require("utilities").keymap_set("n", "<Leader>rf", "<Cmd>Rename<CR>", "Rename [f]ile")
    end,
}
