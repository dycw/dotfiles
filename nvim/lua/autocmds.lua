-- luacheck: push ignore vim
local v = vim
-- luacheck: pop
local api = v.api

api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    callback = function()
        v.cmd("set filetype=jsonc")
    end,
    desc = "JSONC support for VSCode files",
    group = api.nvim_create_augroup("jsonc-vscode", { clear = true }),
    pattern = "*/.vscode/*.json",
})

api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        v.highlight.on_yank()
    end,
    desc = "Highlight when yanking (copying) text",
    group = api.nvim_create_augroup("highlight-yank", { clear = true }),
})

api.nvim_create_autocmd("VimResized", {
    callback = function()
        v.cmd("wincmd =")
    end,
    desc = "Auto resize windows when Vim is resized",
    group = api.nvim_create_augroup("auto-resize-windows", { clear = true }),
})
