-- luacheck: push ignore vim
local v = vim
-- luacheck: pop
local api = v.api

api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function()
        v.highlight.on_yank()
    end,
})
