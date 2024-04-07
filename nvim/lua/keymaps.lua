-- luacheck: push ignore vim
local set = vim.keymap.set
-- luacheck: pop
local opts = { noremap = true, silent = true }

-- command mode
set({ "n", "v" }, "<CR>", ":", opts)

-- global marks
local prefixes = "m'"
local letters = "abcdefghijklmnopqrstuvwxyz"
for i = 1, #prefixes do
    local prefix = prefixes:sub(i, i)
    for j = 1, #letters do
        local lower_letter = letters:sub(j, j)
        local upper_letter = string.upper(lower_letter)
        set({ "n", "v" }, prefix .. lower_letter, prefix .. upper_letter, { desc = "Mark " .. upper_letter })
    end
end

-- navigation
set("i", "<C-h>", "<Left>", opts) -- doesn't seem to work
set("i", "<C-j>", "<Down>", opts)
set("i", "<C-k>", "<Up>", opts)
set("i", "<C-l>", "<Right>", opts) -- doesn't seem to work

-- paste in insert mode
set("i", "<C-v>", "<C-o>p", opts)

-- paste mode
set({ "n", "v", "i" }, "<F2>", "<Cmd>set invpaste paste?<CR>", opts)

-- quickfix
set("n", "]", "<Cmd>cnext<CR>", opts)
set("n", "[", "<Cmd>cprev<CR>", opts)

-- quit
set({ "n", "v" }, "<C-q>", ":confirm q<CR>", opts)
set("i", "<C-q>", ":confirm q<CR>", opts)

-- save
set({ "n", "v" }, "<C-s>", "<Cmd>:w<CR>", opts)
set("i", "<C-s>", "<Esc><Cmd>:w<CR>a", opts)

-- search highlight
set("n", "<Esc>", "<Cmd>nohlsearch<CR>", opts)

-- split windows
set("n", "<C-w>h", ":set nosplitright<CR> :vsplit<CR> :set splitright<CR>", opts)
set("n", "<C-w>j", ":set splitbelow<CR> :split<CR>", opts)
set("n", "<C-w>k", ":set nosplitbelow<CR> :split<CR> :set splitbelow<CR>", opts)
set("n", "<C-w>l", ":set splitright<CR> :vsplit<CR>", opts)

-- visual indents
set("v", "<", "<gv", opts)
set("v", ">", ">gv", opts)
