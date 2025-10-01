-- luacheck: push ignore
local v = vim
-- luacheck: pop

-- command
v.keymap.set("n", ";", ":", { desc = "Command" })

-- navigation
v.keymap.set("i", "<C-h>", "<Left>", { desc = "Move left" })
v.keymap.set("i", "<C-j>", "<Down>", { desc = "Move down" })
v.keymap.set("i", "<C-k>", "<Up>", { desc = "Move up" })
v.keymap.set("i", "<C-l>", "<Right>", { desc = "Move right" })

-- paste in insert mode
v.keymap.set("i", "<C-v>", "<C-o>p", { desc = "Paste" })

-- split windows
v.keymap.set(
    "n",
    "<C-w>h",
    "<Cmd>set nosplitright<CR> <Cmd>vsplit<CR> <Cmd>set splitright<CR>",
    { desc = "Split left" }
)
v.keymap.set("n", "<C-w>j", "<Cmd>set splitbelow<CR> <Cmd>split<CR>", { desc = "Split down" })
v.keymap.set("n", "<C-w>k", "<Cmd>set nosplitbelow<CR> <Cmd>split<CR> <Cmd>set splitbelow<CR>", { desc = "Split up" })
v.keymap.set("n", "<C-w>l", "<Cmd>set splitright<CR> <Cmd>vsplit<CR>", { desc = "Split right" })

-- quit
v.keymap.set({ "n", "v" }, "<C-q>", "<Cmd>confirm q<CR>", { desc = "Quit" })
v.keymap.set("i", "<C-q>", "<Esc><Cmd>confirm q<CR>a", { desc = "Quit" })
