return {
    "johmsalas/text-case.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
        require("textcase").setup()
        require("telescope").load_extension("textcase")

        local keymap_set = require("utilities").keymap_set
        keymap_set({ "n", "v" }, "<Leader>cc", "<Cmd>TextCaseOpenTelescopeQuickChange<CR>", "change [c]ase")
        keymap_set("n", "<Leader>su", "<Cmd>TextCaseStartReplacingCommand<CR>", "s[u]bstitute")
        keymap_set("v", "<Leader>su", ":Subs/", "s[u]bstitute")
    end,
    lazy = false,
}
