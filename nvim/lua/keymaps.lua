local set = vim.keymap.set
local opts = { noremap = true, silent = true }

-- quit
set("n", "<C-q>", ":confirm q<CR>", opts)

-- save
set("n", "<C-s>", "<Cmd>:w<CR>", opts)
set("v", "<C-s>", "<Cmd>:w<CR>", opts)

-- stay in indent mode
set("v", "<", "<gv", opts)
set("v", ">", ">gv", opts)
