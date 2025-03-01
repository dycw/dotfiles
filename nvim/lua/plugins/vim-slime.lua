-- luacheck: push ignore
local v = vim
-- luacheck: pop

return {
    "jpalardy/vim-slime",
    lazy = false,
    init = function()
        v.g.slime_target = "tmux"
        v.g.slime_default_config = { socket_name = "default", target_pane = "{right-of}" }
        v.g.slime_dont_ask_default = 1
    end,
}
