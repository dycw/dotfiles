-- luacheck: push ignore
local v = vim
-- luacheck: pop
local fn = v.fn

require("globals") -- setting leader must happen before plugins are loaded
require("keymaps")
require("opts")
require("autocmds")

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- https://github.com/folke/lazy.nvim for more info
local lazypath = fn.stdpath("data") .. "/lazy/lazy.nvim"
if not v.loop.fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end ---@diagnostic disable-next-line: undefined-field
v.opt.rtp:prepend(lazypath)

-- plugins
local spec = {
    { import = "custom.plugins" },
}
local opts = {
    change_detection = {
        enabled = false,
    },
}
require("lazy").setup(spec, opts)
