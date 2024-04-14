return {
    "ibhagwan/fzf-lua",
    config = function()
        local fzf_lua = require("fzf-lua")
        local keymap_set = require("utilities").keymap_set

        fzf_lua.setup()
        keymap_set("n", "<Leader><Leader>", fzf_lua.buffers, "Buffers")
        keymap_set("n", "<Leader>fl", fzf_lua.builtin, "Fzf-[L]ua")
        keymap_set("n", "<Leader>of", fzf_lua.oldfiles, "Old [F]iles")
    end,
    dependencies = { "nvim-tree/nvim-web-devicons" },
}
