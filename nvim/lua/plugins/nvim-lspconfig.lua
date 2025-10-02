-- luacheck: push ignore
local v = vim
-- luacheck: pop

return { -- LSP Configuration & Plugins
    "neovim/nvim-lspconfig",
    config = function()
        v.api.nvim_create_autocmd("LspAttach", {
            group = v.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
            callback = function(event)
                local map = function(keys, func, desc)
                    v.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
                end
                map("K", v.lsp.buf.hover, "hover documentation")
                map("zj", function()
                    v.diagnostic.jump({ count = 1, float = true })
                end, "next diagnostic")
                map("zk", function()
                    v.diagnostic.jump({ count = -1, float = true })
                end, "previous diagnostic")
                map("<Leader>K", v.diagnostic.open_float, "open float")
                map("<Leader>rn", v.lsp.buf.rename, "re[n]ame")
                map("<Leader>lt", "<Cmd>LspRestart<CR>", "lsp res[t]art")

                -- The following two autocommands are used to highlight references of the
                -- word under your cursor when your cursor rests there for a little while.
                --    See `:help CursorHold` for information about when this is executed
                --
                -- When you move your cursor, the highlights will be cleared (the second autocommand).
                local client = v.lsp.get_client_by_id(event.data.client_id)
                if client and client.server_capabilities.documentHighlightProvider then
                    local highlight_augroup = v.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
                    v.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                        buffer = event.buf,
                        group = highlight_augroup,
                        callback = v.lsp.buf.document_highlight,
                    })

                    v.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                        buffer = event.buf,
                        group = highlight_augroup,
                        callback = v.lsp.buf.clear_references,
                    })

                    v.api.nvim_create_autocmd("LspDetach", {
                        group = v.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
                        callback = function(event2)
                            v.lsp.buf.clear_references()
                            v.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
                        end,
                    })
                end

                -- The following autocommand is used to enable inlay hints in your
                -- code, if the language server you are using supports them
                --
                -- This may be unwanted, since they displace some of your code
                if client and client.server_capabilities.inlayHintProvider and v.lsp.inlay_hint then
                    map("<leader>ih", function()
                        v.lsp.inlay_hint.enable(not v.lsp.inlay_hint.is_enabled())
                    end, "inlay [h]ints")
                end

                -- if client then
                --     require("workspace-diagnostics").populate_workspace_diagnostics(
                --         client,
                --         v.api.nvim_get_current_buf()
                --     )
                -- end
            end,
        })

        -- LSP servers and clients are able to communicate to each other what features they support.
        --  By default, Neovim doesn't support everything that is in the LSP specification.
        --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
        --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
        local capabilities = v.lsp.protocol.make_client_capabilities()
        capabilities = v.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

        -- Enable the following language servers
        --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
        --
        --  Add any additional override configuration in the following tables. Available keys are:
        --  - cmd (table): Override the default command used to start the server
        --  - filetypes (table): Override the default list of associated filetypes for the server
        --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
        --  - settings (table): Override the default settings passed when initializing the server.
        --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
        local servers = {
            pyright = {
                capabilities = capabilities,
            },
            lua_ls = {
                settings = {
                    Lua = {
                        completion = {
                            callSnippet = "Replace",
                        },
                    },
                },
            },
        }

        -- Ensure the servers and tools above are installed
        --  To check the current status of installed tools and/or manually install
        --  other tools, you can run
        --    :Mason
        --
        --  You can press `g?` for help in this menu.
        -- require("mason").setup()

        -- You can add other tools here that you want Mason to install
        -- for you, so that they are available from within Neovim.
        -- local ensure_installed = v.tbl_keys(servers or {})
        -- v.list_extend(ensure_installed, {
        --     "pyright",
        --     "shfmt",
        --     "stylua",
        -- })
        -- require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

        -- require("mason-lspconfig").setup({
        --     handlers = {
        --         function(server_name)
        --             local server = servers[server_name] or {}
        --             -- This handles overriding only values explicitly passed
        --             -- by the server configuration above. Useful when disabling
        --             -- certain features of an LSP (for example, turning off formatting for tsserver)
        --             server.capabilities = v.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
        --             require("lspconfig")[server_name].setup(server)
        --         end,
        --     },
        -- })
    end,
    -- dependencies = {
    --     -- automatically install LSPs
    --     { "williamboman/mason.nvim", config = true }, -- NOTE: Must be loaded before dependents
    --     "williamboman/mason-lspconfig.nvim",
    --     "whoissethdaniel/mason-tool-installer.nvim",
    --
    --     -- Neovim notifications and LSP progress messages
    --     { "j-hui/fidget.nvim", opts = {} },
    --
    --     -- configures LuaLS
    --     { "folke/lazydev.nvim", opts = {} },
    --
    --     -- project-wide diagnostics
    --     -- { "artemave/workspace-diagnostics.nvim" },
    -- },
}
