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
-- command mode
lvim.keys.normal_mode["<CR>"] = ":"
lvim.keys.visual_mode["<CR>"] = ":"

-- ex-mode
lvim.keys.normal_mode["Q"] = "<Nop>"

-- LSP
lvim.lsp.buffer_mappings.normal_mode["gr"] = { "<Cmd>Telescope lsp_references<CR>", "References" }
lvim.keys.normal_mode["ge"] = "<Cmd>Telescope diagnostics<CR>"
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
lvim.builtin.which_key.mappings["b"] = { "<Cmd>Telescope buffers<CR>", "Buffers" }
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
lvim.builtin.which_key.mappings["E"] = { "<Cmd>TroubleToggle workspace_diagnostics<CR>", "Diagnostics (ws)" }

-- files
lvim.builtin.which_key.mappings["f"] = { "<Cmd>Telescope find_files<CR>", "Files" }
lvim.builtin.which_key.mappings["gs"] = { "<Cmd>Telescope git_status<CR>", "Git status" }
lvim.builtin.which_key.mappings["F"] = { "<Cmd>Telescope oldfiles<CR>", "Old files" }

-- iswap
lvim.keys.normal_mode["<Leader>i"] = "<Cmd>ISwapWith<CR>"
lvim.keys.normal_mode["<Leader>is"] = "<Cmd>ISwap<CR>"

-- jump list
lvim.builtin.which_key.mappings["j"] = { "<Cmd>Telescope jumplist<CR>", "Jump list" }

-- lazy
lvim.keys.normal_mode["<Leader>lu"] = "<Cmd>Lazy update<CR>"

-- LSP
lvim.builtin.which_key.mappings["r"] = { "<Cmd>TroubleToggle lsp_references<CR>", "References" }
lvim.builtin.which_key.mappings["lR"] = { "<Cmd>LspRestart<CR>", "Restart LSP" }

-- marks
lvim.builtin.which_key.mappings["m"] = { "<Cmd>Telescope marks<CR>", "Marks" }

-- mergetool
lvim.keys.normal_mode["<Leader>mj"] = "<Cmd>MergetoolDiffExchangeLeft<CR>"
lvim.keys.normal_mode["<Leader>mk"] = "<Cmd>MergetoolDiffExchangeRight<CR>"
lvim.keys.normal_mode["<Leader>ml"] = "<Cmd>MergetoolPreferLocal<CR>"
lvim.keys.normal_mode["<Leader>mr"] = "<Cmd>MergetoolPreferRemote<CR>"
lvim.keys.normal_mode["<Leader>mq"] = "<Cmd>MergetoolStop<CR>"

-- nvim tree
lvim.builtin.which_key.mappings["t"] = { "<Cmd>NvimTreeToggle<CR>", "NvimTree" }

-- quickfix
lvim.keys.normal_mode["<Leader>q"] = "<Cmd>Telescope quickfix<CR>"
lvim.keys.normal_mode["<Leader>lq"] = "<Cmd>TroubleToggle quickfix<CR>"

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
lvim.builtin.which_key.mappings["z"] = { "<Cmd>Telescope current_buffer_fuzzy_find<CR>", "Fuzzy" }

-- sort
lvim.keys.normal_mode["<Leader>so"] = "<Cmd>Sort<CR>"
lvim.keys.normal_mode["<Leader>sn"] = "<Cmd>Sort n<CR>"
lvim.keys.visual_mode["<Leader>so"] = "<Esc><Cmd>Sort<CR>"
lvim.keys.visual_mode["<Leader>sn"] = "<Esc><Cmd>Sort n<CR>"

-- spectre
lvim.keys.normal_mode["<Leader>sp"] = "<Cmd>lua require('spectre').open()<CR>"
lvim.keys.normal_mode["<Leader>sf"] = "<Cmd>lua require('spectre').open_file_search()<CR>"
lvim.keys.visual_mode["<Leader>sp"] = "<Esc><Cmd>lua require('spectre').open_visual()<CR>"
lvim.keys.visual_mode["<Leader>sf"] = "<Esc><Cmd>lua require('spectre').open_file_search({select_word=true})<CR>"

-- symbols
lvim.keys.normal_mode["<Leader>s"] = "<Cmd>Telescope lsp_document_symbols<CR>"
lvim.keys.normal_mode["<Leader>sy"] = "<Cmd>SymbolsOutline<CR>"
lvim.keys.normal_mode["<Leader>ws"] = "<Cmd>Telescope lsp_dynamic_workspace_symbols<CR>"

-- telescope
lvim.keys.normal_mode["<Leader>te"] = "<Cmd>Telescope<CR>"
lvim.keys.visual_mode["<Leader>te"] = "<Esc><Cmd>Telescope<CR>"

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
-- linters
-------------------------------------------------------------------------------
require("lvim.lsp.null-ls.linters").setup({
	-- lua
	{ name = "luacheck", filetypes = { "lua" } },
	-- python
	{ name = "ruff", filetypes = { "python" } },
	-- sh
	{ name = "shellcheck", filetypes = { "sh" } },
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
-- lvim.builtin.which_key.active = false
lvim.plugins = {
	-- auto save
	{
		"okuuva/auto-save.nvim",
		config = function()
			require("auto-save").setup()
		end,
		event = { "BufRead", "BufNew" },
	},

	-- better escape
	{
		"max397574/better-escape.nvim",
		config = function()
			require("better_escape").setup({
				mapping = { "jj", "jk", "kj", "kk" },
			})
		end,
		event = { "BufRead", "BufNew" },
	},

	-- better quick fix
	{
		"kevinhwang91/nvim-bqf",
		config = function()
			require("bqf").setup({ auto_resize_height = true })
		end,
		event = { "BufRead", "BufNew" },
	},

	-- bracey
	{
		"turbio/bracey.vim",
		build = "npm install --prefix server",
		cmd = { "Bracey", "BracyStop", "BraceyReload", "BraceyEval" },
		config = function()
			vim.api.nvim_set_var("g:bracey_refresh_on_save", 1)
		end,
	},

	-- caser
	{
		"arthurxavierx/vim-caser",
		event = { "BufRead", "BufNew" },
	},

	-- close buffers
	{
		"kazhala/close-buffers.nvim",
		event = { "BufRead", "BufNew" },
	},

	-- colorizer
	{
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup({ "css", "scss", "html", "javascript" }, {
				RGB = true, -- #RGB hex codes
				RRGGBB = true, -- #RRGGBB hex codes
				RRGGBBAA = true, -- #RRGGBBAA hex codes
				rgb_fn = true, -- CSS rgb() and rgba() functions
				hsl_fn = true, -- CSS hsl() and hsla() functions
				css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
				css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
			})
		end,
	},

	-- cool
	{
		"romainl/vim-cool",
		event = { "BufRead", "BufNew" },
	},

	-- dial
	{
		"monaqa/dial.nvim",
		config = function()
			vim.keymap.set("n", "<C-a>", require("dial.map").inc_normal(), { noremap = true })
			vim.keymap.set("n", "<C-x>", require("dial.map").dec_normal(), { noremap = true })
			vim.keymap.set("v", "<C-a>", require("dial.map").inc_visual(), { noremap = true })
			vim.keymap.set("v", "<C-x>", require("dial.map").dec_visual(), { noremap = true })
			vim.keymap.set("v", "g<C-a>", require("dial.map").inc_gvisual(), { noremap = true })
			vim.keymap.set("v", "g<C-x>", require("dial.map").dec_gvisual(), { noremap = true })
			local augend = require("dial.augend")
			require("dial.config").augends:register_group({
				default = {
					augend.integer.alias.decimal,
					augend.integer.alias.decimal_int,
					augend.integer.alias.hex,
					augend.integer.alias.octal,
					augend.integer.alias.binary,
					augend.date.alias["%Y/%m/%d"],
					augend.date.alias["%Y-%m-%d"],
					augend.date.alias["%H:%M:%S"],
					augend.date.alias["%H:%M"],
					augend.constant.alias.bool,
					augend.semver.alias.semver,
					augend.constant.new({
						elements = { "True", "False" },
						word = true,
						cyclic = true,
					}),
					augend.constant.new({
						elements = { "true", "false" },
						word = true,
						cyclic = true,
					}),
					augend.constant.new({
						elements = { "and", "or" },
						word = true,
						cyclic = true,
					}),
					augend.constant.new({
						elements = { "&&", "||" },
						word = true,
						cyclic = true,
					}),
				},
			})
		end,
		event = { "BufRead", "BufNew" },
	},

	-- flit
	{
		"ggandor/flit.nvim",
		config = function()
			require("flit").setup()
		end,
		dependencies = { "ggandor/leap.nvim" },
		event = { "BufRead", "BufNew" },
	},

	-- glow
	{
		"npxbr/glow.nvim",
		event = { "BufRead", "BufNew" },
		ft = { "markdown" },
	},

	-- hlslens
	{
		"kevinhwang91/nvim-hlslens",
		config = function()
			require("hlslens").setup()
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

	-- iswap
	{
		"mizlan/iswap.nvim",
		event = { "BufRead", "BufNew" },
	},

	-- last place
	{
		"ethanholz/nvim-lastplace",
		config = function()
			require("nvim-lastplace").setup()
		end,
		event = { "BufRead", "BufNew" },
	},

	-- leap
	{
		"ggandor/leap.nvim",
		config = function()
			require("leap").add_default_mappings()
		end,
		event = { "BufRead", "BufNew" },
	},

	-- match quote
	{
		"airblade/vim-matchquote",
		event = { "BufRead", "BufNew" },
	},

	-- mergetool
	{
		"samoshkin/vim-mergetool",
		config = function()
			vim.g.mergetool_layout = "rml,b"
			vim.g.mergetool_prefer_revision = "unmodified"
		end,
		event = { "BufRead", "BufNew" },
	},

	-- mkdir
	{
		"jghauser/mkdir.nvim",
		config = function()
			require("mkdir")
		end,
		event = { "BufRead", "BufNew" },
	},

	-- neoscroll
	{
		"karb94/neoscroll.nvim",
		config = function()
			require("neoscroll").setup()
		end,
		event = "WinScrolled",
	},

	-- number toggle
	{
		"jeffkreeftmeijer/vim-numbertoggle",
		event = { "BufRead", "BufNew" },
	},

	-- signature
	{
		"ray-x/lsp_signature.nvim",
		config = function()
			require("lsp_signature").on_attach()
		end,
		event = { "BufRead", "BufNew" },
	},

	-- sort
	{
		"sqve/sort.nvim",
		event = { "BufRead", "BufNew" },
	},

	-- spectre
	{
		"windwp/nvim-spectre",
		config = function()
			require("spectre").setup({ live_update = true })
		end,
		event = { "BufRead", "BufNew" },
	},

	-- surround
	{
		"kylechui/nvim-surround",
		config = function()
			require("nvim-surround").setup()
		end,
		event = { "BufRead", "BufNew" },
	},

	-- symbols outline
	{
		"simrat39/symbols-outline.nvim",
		config = function()
			require("symbols-outline").setup()
		end,
		event = { "BufRead", "BufNew" },
	},

	-- targets
	{
		"wellle/targets.vim",
		event = { "BufRead", "BufNew" },
	},

	-- text objects
	{
		"chrisgrieser/nvim-various-textobjs",
		config = function()
			require("various-textobjs").setup({ useDefaultKeymaps = true })
		end,
		event = { "BufRead", "BufNew" },
	},

	-- tidy
	{
		"mcauley-penney/tidy.nvim",
		config = function()
			require("tidy").setup()
		end,
	},

	-- tmux
	{
		"christoomey/vim-tmux-navigator",
		event = { "BufRead", "BufNew" },
	},

	-- treesitter autotag
	{
		"windwp/nvim-ts-autotag",
		config = function()
			require("nvim-ts-autotag").setup()
		end,
		event = { "BufRead", "BufNew" },
	},

	-- treesitter context
	-- https://github.com/LunarVim/LunarVim/issues/4386#issuecomment-1916835688
	-- {
	-- 	"nvim-treesitter/nvim-treesitter-context",
	-- 	event = { "BufRead", "BufNew" },
	-- },

	-- trouble
	{
		"folke/trouble.nvim",
		cmd = "TroubleToggle",
		event = { "BufRead", "BufNew" },
	},

	-- visual multi
	{
		"mg979/vim-visual-multi",
		event = { "BufRead", "BufNew" },
	},
}
