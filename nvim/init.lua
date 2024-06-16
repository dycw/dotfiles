-- luacheck: push ignore
local v = vim
-- luacheck: pop
local fn = v.fn

require("globals") -- setting leader must happen before plugins are loaded
require("autocmds")
require("keymaps")
require("opts")
require("user_commands")

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
local lazy = require("lazy")
lazy.setup(spec, opts)

require("utilities").keymap_set("n", "<Leader>lu", lazy.update, "lazy [u]pdate")
