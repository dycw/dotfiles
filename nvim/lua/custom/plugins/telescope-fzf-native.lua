return {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    cond = function()
        -- luacheck: push ignore
        return vim.fn.executable("make") == 1
        -- luacheck: pop
    end,
    config = function()
        require("telescope").load_extension("fzf")
    end,
}
