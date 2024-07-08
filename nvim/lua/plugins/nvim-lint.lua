-- luacheck: push ignore
local v = vim
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
            zsh = { "shellcheck" },
        }

        -- Retrieve the current configuration for ruff
        local ruff_linter = lint.linters.ruff or {}

        -- Adjust the args field
        ruff_linter.args = {
            "check",
            "--force-exclude",
            "--quiet",
            "--stdin-filename",
            v.api.nvim_buf_get_name(0), -- Use the function directly
            "--no-fix",
            "--output-format",
            "json",
            "-",
            "--ignore=F401", --unused-import
            "--ignore=F841", --unused-variable
        }

        -- Set the adjusted configuration back to lint
        lint.linters.ruff = ruff_linter

        local lint_augroup = v.api.nvim_create_augroup("lint", { clear = true })
        v.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
            group = lint_augroup,
            callback = function()
                require("lint").try_lint()
            end,
        })
    end,
}
