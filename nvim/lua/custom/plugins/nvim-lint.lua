-- luacheck: push ignore
local api = vim.api
-- luacheck: pop

return {
    "mfussenegger/nvim-lint",
    config = function()
        local lint = require("lint")
        lint.linters_by_ft = {
            css = { "biomejs" },
            dockerfile = { "hadolint" },
            haskell = { "hlint" },
            html = { "biomejs" },
            htmldjango = { "biomejs" },
            javascript = { "biomejs" },
            javascriptreact = { "biomejs" },
            json = { "biomejs" },
            jsonc = { "biomejs" },
            lua = { "luacheck" },
            markdown = { "biomejs" },
            python = { "ruff" },
            sh = { "shellcheck" },
            sql = { "sqlfluff" },
            svelte = { "biomejs" },
            typescript = { "biomejs" },
            typescriptreact = { "biomejs" },
            vue = { "biomejs" },
            yaml = { "yamllint" },
            zsh = { "shellcheck" },
        }

        local lint_augroup = api.nvim_create_augroup("lint", { clear = true })
        api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
            group = lint_augroup,
            callback = function()
                require("lint").try_lint()
            end,
        })
    end,
}
