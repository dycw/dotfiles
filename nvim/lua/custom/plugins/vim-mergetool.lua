-- luacheck: push ignore
local g = vim.g
-- luacheck: pop

return {
    "samoshkin/vim-mergetool",
    config = function()
        g.mergetool_layout = "rml,b"
        g.mergetool_prefer_revision = "unmodified"
    end,
}
