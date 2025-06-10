-- luacheck: push ignore
local v = vim
-- luacheck: pop

return {
    "tpope/vim-eunuch",
    config = function()
        require("utilities").keymap_set("n", "<Leader>rf", function()
            v.api.nvim_feedkeys(":Rename " .. v.fn.expand("%:t"), "n", false)
        end, "Rename [f]ile")
    end,
}
