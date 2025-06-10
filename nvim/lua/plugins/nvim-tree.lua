return {
    "nvim-tree/nvim-tree.lua",
    config = function()
        require("utilities").keymap_set({ "n", "v" }, "<Leader>e", "<Cmd>NvimTreeFindFileToggle<CR>", "[E]xplorer")
        -- keymap_set("n", "<Leader>rf", "<Cmd>RenameCurrentFile<CR>", "Rename [f]ile")
        require("nvim-tree").setup({
            filters = { custom = { "__pycache__" } },
            git = { ignore = true },
        })
    end,
}
