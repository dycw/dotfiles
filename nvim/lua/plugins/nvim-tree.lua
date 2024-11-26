return {
    "nvim-tree/nvim-tree.lua",
    config = function()
        require("utilities").keymap_set(
            { "n", "v" },
            "<Leader>fe",
            "<Cmd>NvimTreeFindFileToggle<CR>",
            "File [E]xplorer"
        )
        require("nvim-tree").setup({
            filters = {
                custom = { "__pycache__" },
            },
            git = {
                ignore = true,
            },
        })
    end,
}
