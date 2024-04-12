return {
    "nvim-tree/nvim-tree.lua",
    config = function()
        require("utilities").keymap_set({ "n", "v" }, "<Leader>fe", "<Cmd>NvimTreeToggle<CR>", "File Explorer")
        require("nvim-tree").setup()
    end,
    event = "VeryLazy",
}
