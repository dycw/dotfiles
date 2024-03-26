-- luacheck: push ignore vim
local opt = vim.opt
-- luacheck: pop

-- Make a backup before overwriting a file?
opt.backup = false

-- Every wrapped line with continue visually indended?
opt.breakindent = true

-- Sync clipboard between OS and Neovim
opt.clipboard = "unnamedplus"

-- Use the appropriate number of spaces to insert a <Tab>?
opt.expandtab = true

-- Enables mouse support
opt.mouse = "a"

-- Print the line number in front of each line?
opt.number = true

-- Show the line number relative to the line with the cursor in front of each line?
opt.relativenumber = true

-- If in Insert, Replace or Visual mode put a message on the last line?
opt.showmode = false

-- When and how to draw the sign column
opt.signcolumn = "yes"

-- Use a swapfile for the buffer?
opt.swapfile = false

-- Number of spaces to use for each step of (auto)indent
opt.shiftwidth = 2

-- Number of spaces that a <Tab> int he file counts for
opt.tabstop = 2

-- When on, Vim automatically saves undo history to an undo file when writing a buffer to a file
opt.undofile = true
