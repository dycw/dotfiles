-- luacheck: push ignore
local v = vim
-- luacheck: pop
local api = v.api

return {
    -- Main LSP Configuration
    "neovim/nvim-lspconfig",
    version = "^1", -- Keep compatibility with Neovim 0.10 from Debian 13.
    dependencies = {
        -- Automatically install LSPs and related tools to stdpath for Neovim
        -- Mason must be loaded before its dependents so we need to set it up
        -- here.
        -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
        { "mason-org/mason.nvim", version = "^1", opts = {} },
        { "mason-org/mason-lspconfig.nvim", version = "^1" },
        "WhoIsSethDaniel/mason-tool-installer.nvim",

        -- Useful status updates for LSP.
        { "j-hui/fidget.nvim", opts = {} },

        -- Allows extra capabilities provided by blink.cmp
        "saghen/blink.cmp",
    },
    config = function()
        api.nvim_create_autocmd("LspAttach", {
            group = api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
            callback = function(event)
                local map = function(keys, func, desc, mode)
                    mode = mode or "n"
                    v.keymap.set(mode, keys, func, { buffer = event.buf, desc = desc })
                end
                map("zj", function()
                    v.diagnostic.goto_next({ float = true })
                end, "next diagnostic")
                map("zk", function()
                    v.diagnostic.goto_prev({ float = true })
                end, "previous diagnostic")
                map("<Leader>dl", function()
                    v.diagnostic.open_float(nil, { scope = "line" })
                end, "diagnostic [l]ine")
                map("<Leader>ca", v.lsp.buf.code_action, "code [a]ction", { "n", "x" })
                map("gD", v.lsp.buf.declaration, "[d]eclaration")
                map("<Leader>lr", "<Cmd>LspRestart<CR>", "[r]estart")
                map("<Leader>rn", v.lsp.buf.rename, "re[n]ame")

                -- The following two autocommands are used to highlight
                -- references of the word under your cursor when your cursor
                -- rests there for a little while.
                local client = v.lsp.get_client_by_id(event.data.client_id)
                if
                    client
                    and client:supports_method(v.lsp.protocol.Methods.textDocument_documentHighlight, event.buf)
                then
                    local highlight_augroup = api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
                    api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                        buffer = event.buf,
                        group = highlight_augroup,
                        callback = v.lsp.buf.document_highlight,
                    })
                    api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                        buffer = event.buf,
                        group = highlight_augroup,
                        callback = v.lsp.buf.clear_references,
                    })
                    api.nvim_create_autocmd("LspDetach", {
                        group = api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
                        callback = function(event2)
                            v.lsp.buf.clear_references()
                            api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
                        end,
                    })
                end

                -- The following code creates a keymap to toggle inlay hints in
                -- your code, if the language server you are using supports
                -- them
                if client and client:supports_method(v.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
                    map("<leader>ih", function()
                        v.lsp.inlay_hint.enable(not v.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
                    end, "inlay [h]ints")
                end
            end,
        })

        -- https://docs.astral.sh/ruff/editors/setup/#neovim
        api.nvim_create_autocmd("LspAttach", {
            group = api.nvim_create_augroup("lsp_attach_disable_ruff_hover", { clear = true }),
            callback = function(args)
                local client = v.lsp.get_client_by_id(args.data.client_id)
                if client == nil then
                    return
                end
                if client.name == "ruff" then
                    -- Disable hover in favor of Pyright
                    client.server_capabilities.hoverProvider = false
                end
            end,
            desc = "LSP: Disable hover capability from Ruff",
        })

        -- Diagnostic Config
        -- See :help vim.diagnostic.Opts
        v.diagnostic.config({
            severity_sort = true,
            float = { border = "rounded", source = "if_many" },
            underline = { severity = v.diagnostic.severity.ERROR },
            signs = {
                text = {
                    [v.diagnostic.severity.ERROR] = "E",
                    [v.diagnostic.severity.WARN] = "W",
                    [v.diagnostic.severity.INFO] = "I",
                    [v.diagnostic.severity.HINT] = "H",
                },
            },
            virtual_text = {
                source = "if_many",
                spacing = 2,
                format = function(diagnostic)
                    local diagnostic_message = {
                        [v.diagnostic.severity.ERROR] = diagnostic.message,
                        [v.diagnostic.severity.WARN] = diagnostic.message,
                        [v.diagnostic.severity.INFO] = diagnostic.message,
                        [v.diagnostic.severity.HINT] = diagnostic.message,
                    }
                    return diagnostic_message[diagnostic.severity]
                end,
            },
        })

        -- LSP servers and clients are able to communicate to each other what
        -- features they support. By default, Neovim doesn't support everything
        -- that is in the LSP specification. When you add blink.cmp, luasnip,
        -- etc. Neovim now has *more* capabilities. So, we create new
        -- capabilities with blink.cmp, and then broadcast that to the servers.
        local capabilities = require("blink.cmp").get_lsp_capabilities()

        -- Enable the following language servers
        -- Feel free to add/remove any LSPs that you want here. They will
        -- automatically be installed.
        --
        -- Add any additional override configuration in the following tables.
        -- Available keys are:
        --  - cmd (table): Override the default command used to start the
        --    server
        --  - filetypes (table): Override the default list of associated
        --    filetypes for the server
        --  - capabilities (table): Override fields in capabilities. Can be
        --    used to disable certain LSP features.
        --  - settings (table): Override the default settings passed when
        --    initializing the server.
        -- For example, to see the options for `lua_ls`, you could go to:
        --   https://luals.github.io/wiki/settings/
        local servers = {
            bashls = {},
            fish_lsp = {},
            lua_ls = {
                settings = {
                    Lua = {
                        completion = { callSnippet = "Replace" },
                    },
                },
            },
            pyright = {},
            ruff = {},
        }

        -- rust-analyzer is supplied by rustup and configured by rustaceanvim.
        require("mason-tool-installer").setup({ ensure_installed = { "stylua" } })
        require("mason-lspconfig").setup({
            ensure_installed = v.tbl_keys(servers),
            automatic_installation = true,
            handlers = {
                function(server_name)
                    local server = servers[server_name] or {}
                    -- This handles overriding only values explicitly passed
                    -- by the server configuration above. Useful when disabling
                    -- certain features of an LSP (for example, turning off
                    -- formatting for ts_ls)
                    server.capabilities = v.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
                    require("lspconfig")[server_name].setup(server)
                end,
            },
        })
    end,
}
