-- Make a backup before overwriting a file?
vim.opt.backup = false

-- Every wrapped line with continue visually indended?
vim.opt.breakindent = true

-- Sync clipboard between OS and Neovim
vim.opt.clipboard = "unnamedplus"

-- Use the appropriate number of spaces to insert a <Tab>?
vim.opt.expandtab = true

-- Enables mouse support
vim.opt.mouse = "a"

-- Print the line number in front of each line?
vim.opt.number = true

-- Show the line number relative to the line with the cursor in front of each line?
vim.opt.relativenumber = true

-- If in Insert, Replace or Visual mode put a message on the last line?
vim.opt.showmode = false

-- When and how to draw the sign column
vim.opt.signcolumn = "yes"

-- Use a swapfile for the buffer?
vim.opt.swapfile = false

-- Number of spaces to use for each step of (auto)indent
vim.opt.shiftwidth = 2

-- Number of spaces that a <Tab> int he file counts for
vim.opt.tabstop = 2

-- When on, Vim automatically saves undo history to an undo file when writing a buffer to a file
vim.opt.undofile = true
