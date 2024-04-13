-- luacheck: ignore 112

-------------------------------------------------------------------------------
-- key bindings
-------------------------------------------------------------------------------
-- LSP
lvim.keys.normal_mode["`j"] = "<Cmd>lua vim.diagnostic.goto_next()<CR>"
lvim.keys.normal_mode["`k"] = "<Cmd>lua vim.diagnostic.goto_prev()<CR>"
lvim.keys.normal_mode["R"] = {
    function()
        return ":IncRename " .. vim.fn.expand("<cword>")
    end,
    { expr = true, noremap = true },
}

-------------------------------------------------------------------------------
-- key bindings (leader)
-------------------------------------------------------------------------------
-- buffers
lvim.builtin.which_key.mappings["x"] = { "BDelete this<CR>", "Delete buffer" }

-- commands
lvim.builtin.which_key.vmappings["c"] = { "<Cmd>Telescope commands<CR>", "Commands" }

-- iswap
lvim.builtin.which_key.mappings["i"] = { "<Cmd>ISwap<CR>", "ISwap" }
lvim.builtin.which_key.mappings["iw"] = { "<Cmd>ISwapWith<CR>", "ISwapWith" }

-- lazy
lvim.builtin.which_key.mappings["lu"] = { "<Cmd>Lazy update<CR>", "Lazy update" }

-- LSP
lvim.builtin.which_key.mappings["lR"] = { "<Cmd>LspRestart<CR>", "Restart LSP" }

-- mergetool
lvim.builtin.which_key.mappings["mj"] = { "<Cmd>MergetoolDiffExchangeLeft<CR>", "Exchange left" }
lvim.builtin.which_key.mappings["mk"] = { "<Cmd>MergetoolDiffExchangeRight<CR>", "Exchange right" }
lvim.builtin.which_key.mappings["ml"] = { "<Cmd>MergetoolPreferLocal<CR>", "Prefer local" }
lvim.builtin.which_key.mappings["mr"] = { "<Cmd>MergetoolPreferRemote<CR>", "Prefer right" }
lvim.builtin.which_key.mappings["mq"] = { "<Cmd>MergetoolStop<CR>", "Stop" }

-- search text
lvim.builtin.which_key.mappings["g"] = {
    function()
        require("telescope.builtin").grep_string({
            shorten_path = true,
            word_match = "-w",
            only_sort_text = true,
            search = "",
        })
    end,
    "Grep",
}

-- spectre
lvim.builtin.which_key.mappings["<Leader>sp"] = { "<Cmd>lua require('spectre').open()<CR>", "Spectre" }
lvim.builtin.which_key.mappings["<Leader>sf"] =
    { "<Cmd>lua require('spectre').open_file_search()<CR>", "Spectre (file)" }
lvim.builtin.which_key.vmappings["<Leader>sp"] = { "<Esc><Cmd>lua require('spectre').open_visual()<CR>", "Spectre" }
lvim.builtin.which_key.vmappings["<Leader>sf"] =
    { "<Esc><Cmd>lua require('spectre').open_file_search({select_word=true})<CR>", "Spectre (file)" }

-------------------------------------------------------------------------------
-- plugins
-------------------------------------------------------------------------------
lvim.builtin.dap.active = false
lvim.builtin.illuminate.active = false
lvim.builtin.lir.active = false
