-- luacheck: push ignore
local v = vim
-- luacheck: pop
local api = v.api
local lsp = v.lsp

lsp.config("ruff", {
    init_options = {
        settings = {
            configurationPreference = "filesystemFirst",
            lint = {
                preview = true,
            },
            format = {
                preview = true,
            },
        },
    },
})

lsp.enable("ruff")

api.nvim_create_autocmd("LspAttach", {
    group = api.nvim_create_augroup("lsp_attach_disable_ruff_hover", { clear = true }),
    callback = function(args)
        local client = lsp.get_client_by_id(args.data.client_id)
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
