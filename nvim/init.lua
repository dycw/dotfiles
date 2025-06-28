-- luacheck: push ignore
local v = vim
-- luacheck: pop

require("globals") -- setting leader must happen before plugins are loaded
require("autocmds")
require("keymaps")
require("lsp")
require("opts")
require("user_commands")

-- https://github.com/folke/lazy.nvim for more info
local lazypath = v.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not v.loop.fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    v.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end ---@diagnostic disable-next-line: undefined-field
v.opt.rtp:prepend(lazypath)

-- plugins
local spec = { { import = "plugins" } }
local opts = { change_detection = { enabled = true } }
local lazy = require("lazy")
lazy.setup(spec, opts)

require("utilities").keymap_set("n", "<Leader>lu", lazy.update, "lazy [u]pdate")
