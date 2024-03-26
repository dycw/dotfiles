-- luacheck: ignore 112

-------------------------------------------------------------------------------
-- vim
-------------------------------------------------------------------------------
vim.opt.colorcolumn = "80"
vim.opt.mouse = ""
vim.opt.relativenumber = true
vim.opt.gdefault = true
vim.opt.wrap = true

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

-- marks
local prefixes = "m'"
local letters = "abcdefghijklmnopqrstuvwxyz"
for i = 1, #prefixes do
    for j = 1, #letters do
        local prefix = prefixes:sub(i, i)
        local lower_letter = letters:sub(j, j)
        local upper_letter = string.upper(lower_letter)
        lvim.keys.normal_mode[prefix .. lower_letter] = prefix .. upper_letter
    end
end

-- navigation
lvim.keys.insert_mode["<C-h>"] = "<Left>"
lvim.keys.insert_mode["<C-j>"] = "<Down>"
lvim.keys.insert_mode["<C-k>"] = "<Up>"
lvim.keys.insert_mode["<C-l>"] = "<Right>"

-- paste
lvim.keys.normal_mode["<F2>"] = "<Cmd>set invpaste paste?<CR>"
lvim.keys.insert_mode["<F2>"] = "<C-o><Cmd>set invpaste paste?<CR>"

-- quickfix
lvim.keys.normal_mode["<Leader>q"] = "<Cmd>Telescope quickfix<CR>"
lvim.keys.normal_mode["]"] = "<Cmd>cnext<CR>"
lvim.keys.normal_mode["["] = "<Cmd>cprev<CR>"

-- quit
lvim.keys.normal_mode["<C-q>"] = ":confirm q<CR>"

-- save
lvim.keys.normal_mode["<C-s>"] = "<Cmd>w<CR>"
lvim.keys.visual_mode["<C-s>"] = "<Esc><Cmd>w<CR>"
lvim.keys.insert_mode["<C-s>"] = "<Esc><Cmd>w<CR>"

-- windows
lvim.keys.normal_mode["<C-w>h"] = "<Cmd>set nosplitright<CR><Cmd>vsplit<CR>"
lvim.keys.normal_mode["<C-w>j"] = "<Cmd>set splitbelow<CR><Cmd>split<CR>"
lvim.keys.normal_mode["<C-w>k"] = "<Cmd>set nosplitbelow<CR><Cmd>split<CR>"
lvim.keys.normal_mode["<C-w>l"] = "<Cmd>set splitright<CR><Cmd>vsplit<CR>"

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

-- keymaps
lvim.builtin.which_key.mappings["K"] = { "<Cmd>Telescope keymaps<CR>", "Key maps" }

-- trouble
lvim.builtin.which_key.mappings["t"] = { "<Cmd>TroubleToggle<CR>", "Trouble" }
lvim.builtin.which_key.vmappings["t"] = { "<Cmd>TroubleToggle<CR>", "Trouble" }

-- windows
lvim.builtin.which_key.mappings["wh"] = { "<Cmd>set nosplitright<CR><Cmd>vsplit<CR>", "Split left" }
lvim.builtin.which_key.mappings["wj"] = { "<Cmd>set splitbelow<CR><Cmd>split<CR>", "Split down" }
lvim.builtin.which_key.mappings["wk"] = { "<Cmd>set nosplitbelow<CR><Cmd>split<CR>", "Split up" }
lvim.builtin.which_key.mappings["wl"] = { "<Cmd>set splitright<CR><Cmd>vsplit<CR>", "Split right" }
lvim.builtin.which_key.mappings["-"] = { "<Cmd>split<CR>", "Split down" }
lvim.builtin.which_key.mappings["\\"] = { "<Cmd>vsplit<CR>", "Split right" }

-- comment
lvim.builtin.which_key.mappings["/"] = { "<Plug>(comment_toggle_linewise_current)", "Comment" }
lvim.builtin.which_key.vmappings["/"] = { "<Plug>(comment_toggle_linewise_visual)", "Comment" }

-- diagnostics
lvim.builtin.which_key.mappings["e"] = { "<Cmd>TroubleToggle document_diagnostics<CR>", "Diagnostics (doc)" }
lvim.builtin.which_key.mappings["w"] = { "<Cmd>TroubleToggle workspace_diagnostics<CR>", "Diagnostics (ws)" }

-- files
lvim.builtin.which_key.mappings["f"] = { "<Cmd>Telescope find_files<CR>", "Files" }
lvim.builtin.which_key.mappings["F"] = { "<Cmd>Telescope oldfiles<CR>", "Old files" }

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

-- sort
lvim.builtin.which_key.mappings["s"] = { "<Cmd>Sort<CR>", "Sort" }
lvim.builtin.which_key.mappings["sn"] = { "<Cmd>Sort n<CR>", "Sort (numbers)" }
lvim.builtin.which_key.vmappings["s"] = { "<Esc><Cmd>Sort<CR>", "Sort" }
lvim.builtin.which_key.vmappings["sn"] = { "<Esc><Cmd>Sort n<CR>", "Sort (numbers)" }

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
-- formatters
-------------------------------------------------------------------------------
require("lvim.lsp.null-ls.formatters").setup({
    -- lua
    { name = "stylua", filetypes = { "lua" } },
    -- python
    { name = "black", filetypes = { "ruff" } },
    -- sh
    { name = "shfmt", filetypes = { "sh" } },
    -- prettier
    {
        name = "prettier",
        filetypes = {
            "css",
            "html",
            "htmldjango",
            "javascript",
            "javascriptreact",
            "json",
            "markdown",
            "scss",
            "toml",
            "typescript",
            "typescriptreact",
            "vue",
            "yaml",
        },
    },
})

-------------------------------------------------------------------------------
-- LSP
-------------------------------------------------------------------------------
lvim.builtin.treesitter.ensure_installed = {
    "bash",
    "dart",
    "elm",
    "go",
    "graphql",
    "haskell",
    "javascript",
    "json",
    "lua",
    "prisma",
    "python",
    "rust",
    "sql",
    "swift",
    "tsx",
    "typescript",
    "vue",
    "yaml",
}

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
