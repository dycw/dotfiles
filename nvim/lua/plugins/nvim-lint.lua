return {
    "mfussenegger/nvim-lint",
    opts = {
        linters_by_ft = {
            haskell = { "hlint" },
            lua = { "luacheck" },
            python = { "ruff" },
            sh = { "shellcheck" },
            sql = { "sqlfluff" },
            zsh = { "shellcheck" },
        },
    },
}
