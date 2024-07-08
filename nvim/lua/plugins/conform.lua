-- luacheck: push ignore
local v = vim
-- luacheck: pop

return {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    lazy = false,
    opts = {
        formatters_by_ft = {
            dart = { "dart_format" },
            elm = { "elm_format" },
            go = { "gofumpt" },
            htmldjango = { "djlint", "rustywind" },
            lua = { "stylua" },
            python = { "ruff_fix", "ruff_format" },
            rust = { "rustfmt" },
            sh = { "shfmt" },
            sql = { "sql_formatter" },
            zig = { "zigfmt" },
            -- prettier
            css = { "prettier" },
            graphql = { "prettier" },
            json = { "prettier" },
            less = { "prettier" },
            markdown = { "prettier" },
            scss = { "prettier" },
            toml = { "prettier" },
            vue = { "prettier" },
            yaml = { "prettier" },
            -- prettier + rustywind
            html = { "prettier", "rustywind" },
            javascript = { "prettier", "rustywind" },
            javascriptreact = { "prettier", "rustywind" },
            typescript = { "prettier", "rustywind" },
            typescriptreact = { "prettier", "rustywind" },
            -- rest
            ["*"] = { "trim_whitespace", "trim_newlines" },
        },
        format_on_save = function(bufnr)
            local disable_filetypes = { c = true, cpp = true }
            return {
                timeout_ms = 500,
                lsp_fallback = not disable_filetypes[v.bo[bufnr].filetype],
            }
        end,
        formatters = {
            ruff_fix = {
                prepend_args = {
                    "check",
                    "--unfixable=F401", --unused-import
                    "--unfixable=F841", --unused-variable
                },
            },
        },
        notify_on_error = false,
    },
}
