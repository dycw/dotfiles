-- luacheck: ignore 112

-------------------------------------------------------------------------------
-- key bindings
-------------------------------------------------------------------------------
-- buffers
lvim.keys.normal_mode["gb"] = "<Cmd>Telescope buffers<CR>"

-- command mode
lvim.keys.normal_mode["<CR>"] = ":"
lvim.keys.visual_mode["<CR>"] = ":"

-- ex-mode
lvim.keys.normal_mode["Q"] = "<Nop>"

-- LSP
lvim.lsp.buffer_mappings.normal_mode["gr"] = { "<Cmd>Telescope lsp_references<CR>", "References" }
lvim.keys.normal_mode["ge"] = "<Cmd>Telescope diagnostics<CR>"
lvim.keys.normal_mode["gs"] = "<Cmd>Telescope lsp_document_symbols<CR>"
lvim.keys.normal_mode["gS"] = "<Cmd>Telescope lsp_dynamic_workspace_symbols<CR>"
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
lvim.builtin.which_key.mappings = {}
lvim.builtin.which_key.vmappings = {}

-- auto-save
lvim.builtin.which_key.mappings["as"] = { "<Cmd>ASToggle<CR>", "Toggle AutoSave" }

-- buffers
lvim.builtin.which_key.mappings["x"] = { "BDelete this<CR>", "Delete buffer" }

-- commands
lvim.builtin.which_key.mappings["c"] = { "<Cmd>Telescope commands<CR>", "Commands" }
lvim.builtin.which_key.mappings["C"] = { "<Cmd>Telescope commands_history<CR>", "Command history" }
lvim.builtin.which_key.vmappings["c"] = { "<Cmd>Telescope commands<CR>", "Commands" }

-- iswap
lvim.builtin.which_key.mappings["i"] = { "<Cmd>ISwap<CR>", "ISwap" }
lvim.builtin.which_key.mappings["iw"] = { "<Cmd>ISwapWith<CR>", "ISwapWith" }

-- jump list
lvim.builtin.which_key.mappings["j"] = { "<Cmd>Telescope jumplist<CR>", "Jump list" }

-- lazy
lvim.builtin.which_key.mappings["lu"] = { "<Cmd>Lazy update<CR>", "Lazy update" }

-- LSP
lvim.builtin.which_key.mappings["r"] = { "<Cmd>TroubleToggle lsp_references<CR>", "References" }
lvim.builtin.which_key.mappings["lR"] = { "<Cmd>LspRestart<CR>", "Restart LSP" }

-- marks
lvim.builtin.which_key.mappings["m"] = { "<Cmd>Telescope marks<CR>", "Marks" }

-- mergetool
lvim.builtin.which_key.mappings["mj"] = { "<Cmd>MergetoolDiffExchangeLeft<CR>", "Exchange left" }
lvim.builtin.which_key.mappings["mk"] = { "<Cmd>MergetoolDiffExchangeRight<CR>", "Exchange right" }
lvim.builtin.which_key.mappings["ml"] = { "<Cmd>MergetoolPreferLocal<CR>", "Prefer local" }
lvim.builtin.which_key.mappings["mr"] = { "<Cmd>MergetoolPreferRemote<CR>", "Prefer right" }
lvim.builtin.which_key.mappings["mq"] = { "<Cmd>MergetoolStop<CR>", "Stop" }

-- nvim tree
lvim.builtin.which_key.mappings["t"] = { "<Cmd>NvimTreeToggle<CR>", "NvimTree" }

-- quickfix
lvim.builtin.which_key.mappings["lq"] = { "<Cmd>TroubleToggle quickfix<CR>", "Quick Fix" }

-- search text
lvim.builtin.which_key.mappings["b"] = { "<Cmd>Telescope current_buffer_fuzzy_find<CR>", "Fuzzy" }
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

-- symbols
lvim.builtin.which_key.mappings["<Leader>s"] = { "<Cmd>SymbolsOutline<CR>", "Symbols" }

-------------------------------------------------------------------------------
-- lvim
-------------------------------------------------------------------------------
lvim.format_on_save.enabled = true
lvim.reload_config_on_save = false

-------------------------------------------------------------------------------
-- nvim tree
-------------------------------------------------------------------------------
lvim.builtin.nvimtree.setup.git.ignore = true
lvim.builtin.nvimtree.setup.renderer.icons.show.git = true

-------------------------------------------------------------------------------
-- telescope
-------------------------------------------------------------------------------
lvim.builtin.telescope.defaults.layout_config.height = 0.8
lvim.builtin.telescope.defaults.layout_config.preview_cutoff = 40
lvim.builtin.telescope.defaults.layout_config.preview_height = 0.6
lvim.builtin.telescope.defaults.layout_config.prompt_position = "bottom"
lvim.builtin.telescope.defaults.layout_config.width = 0.8
lvim.builtin.telescope.defaults.layout_strategy = "vertical"
lvim.builtin.telescope.defaults.path_display = { "smart" }
lvim.builtin.telescope.pickers.find_files.find_command = { "fd", "-H", "-tf" }

-------------------------------------------------------------------------------
-- plugins
-------------------------------------------------------------------------------
lvim.builtin.dap.active = false
lvim.builtin.illuminate.active = false
lvim.builtin.lir.active = false
lvim.plugins = {

    -- better quick fix
    {
        "kevinhwang91/nvim-bqf",
        config = function()
            require("bqf").setup({ auto_resize_height = true })
        end,
        event = { "BufRead", "BufNew" },
    },

    -- inc rename
    {
        "smjonas/inc-rename.nvim",
        config = function()
            require("inc_rename").setup()
        end,
        event = { "BufRead", "BufNew" },
    },
}
