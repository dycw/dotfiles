-- luacheck: ignore 112

-------------------------------------------------------------------------------
-- key bindings
-------------------------------------------------------------------------------
-- LSP
lvim.keys.normal_mode["R"] = {
    function()
        return ":IncRename " .. vim.fn.expand("<cword>")
    end,
    { expr = true, noremap = true },
}

-------------------------------------------------------------------------------
-- key bindings (leader)
-------------------------------------------------------------------------------

-- mergetool
lvim.builtin.which_key.mappings["mj"] = { "<Cmd>MergetoolDiffExchangeLeft<CR>", "Exchange left" }
lvim.builtin.which_key.mappings["mk"] = { "<Cmd>MergetoolDiffExchangeRight<CR>", "Exchange right" }
lvim.builtin.which_key.mappings["ml"] = { "<Cmd>MergetoolPreferLocal<CR>", "Prefer local" }
lvim.builtin.which_key.mappings["mr"] = { "<Cmd>MergetoolPreferRemote<CR>", "Prefer right" }
lvim.builtin.which_key.mappings["mq"] = { "<Cmd>MergetoolStop<CR>", "Stop" }
