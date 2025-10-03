-- luacheck: push ignore
local v = vim
-- luacheck: pop
local api = v.api

return {
    "okuuva/auto-save.nvim", -- forked from pocco81/auto-save.nvim
    cmd = "ASToggle",
    config = function()
        local group = api.nvim_create_augroup("autosave", {})
        api.nvim_create_autocmd("User", {
            pattern = "AutoSaveEnable",
            group = group,
            callback = function()
                v.notify("AutoSave enabled", v.log.levels.INFO)
            end,
        })

        api.nvim_create_autocmd("User", {
            pattern = "AutoSaveDisable",
            group = group,
            callback = function()
                v.notify("AutoSave disabled", v.log.levels.INFO)
            end,
        })
    end,
    event = { "InsertLeave", "TextChanged" },
    keys = {
        {
            "<Leader>as",
            function()
                require("auto-save").toggle()
            end,
            desc = "auto [s]ave",
        },
    },
    opts = {
        debounce_delay = 10,
    },
    version = "^1.0.0",
}
