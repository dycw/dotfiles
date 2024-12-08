-- luacheck: push ignore
local v = vim
-- luacheck: pop

return {
    "hrsh7th/nvim-cmp",
    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        luasnip.config.setup({})

        cmp.setup({
            completion = { completeopt = "menu,menuone,noinsert" },
            mapping = cmp.mapping.preset.insert({
                -- Select the next item
                ["<Tab>"] = cmp.mapping.select_next_item(),

                -- Select the previous item
                ["<S-Tab>"] = cmp.mapping.select_prev_item(),

                -- Scroll the documentation window back/forward
                ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),

                -- Accept the completion
                ["<CR>"] = cmp.mapping.confirm({ select = true }),

                -- Manually trigger a completion from nvim-cmp
                ["<C-Space>"] = cmp.mapping.complete({}),

                -- Move to the right of each of the expansion locations
                ["<C-l>"] = cmp.mapping(function()
                    if luasnip.expand_or_locally_jumpable() then
                        luasnip.expand_or_jump()
                    end
                end, { "i", "s" }),
                ["<C-h>"] = cmp.mapping(function()
                    if luasnip.locally_jumpable(-1) then
                        luasnip.jump(-1)
                    end
                end, { "i", "s" }),
            }),
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            sources = {
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "path" },
                { name = "buffer" },
            },
        })
    end,
    dependencies = {
        {
            "l3mon4d3/luasnip",
            build = (function()
                if v.fn.has("win32") == 1 or v.fn.executable("make") == 0 then
                    return
                end
                return "make install_jsregexp"
            end)(),
            config = function()
                require("snippets")
            end,
        },
        "saadparwaiz1/cmp_luasnip",

        -- Adds other completion capabilities
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-path",
    },
    event = "InsertEnter",
}
