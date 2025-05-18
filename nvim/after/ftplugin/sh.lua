-- luacheck: push ignore
local opt_local = vim.opt_local
-- luacheck: pop

opt_local.shiftwidth = 2
opt_local.tabstop = 2
opt_local.listchars = {
    tab = "▏ ", -- vertical line + space, or use "  " to hide
    trail = "·",
    nbsp = "_",
}
