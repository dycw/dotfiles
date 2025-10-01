return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function(_, opts)
        ---@diagnostic disable-next-line: missing-fields
        require("nvim-treesitter.configs").setup(opts)
    end,
    opts = {
        ensure_installed = { "bash", "html", "lua", "markdown", "python", "rust", "vim", "vimdoc" },
        auto_install = true,
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = { "ruby" },
        },
        indent = {
            enable = true,
            disable = { "ruby" },
        },
    },
}
