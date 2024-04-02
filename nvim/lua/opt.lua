-- luacheck: push ignore vim
local opt = vim.opt
-- luacheck: pop

-- Make a backup before overwriting a file?
opt.backup = false

-- Every wrapped line with continue visually indended?
opt.breakindent = true

-- Sync clipboard between OS and Neovim
opt.clipboard = "unnamedplus"

-- Comma-separated list of screen columns that are highlighted with ColorColumn
opt.colorcolumn = "80"

-- Highlight the text line of the cursor with CursorLine
opt.cursorline = true

-- Use the appropriate number of spaces to insert a <Tab>?
opt.expandtab = true

-- The ":substitute" flag `'g'`?
opt.gdefault = true

-- When there is a previous search pattern, highlight all its matches
opt.hlsearch = true

-- Ignore case in search patterns
opt.ignorecase = true

-- When nonempty, shows the effects of |:substitute|, |:smagic|, |:snomagic| and user commands with the
-- |:command-preview| flag as you type
opt.inccommand = "split"

-- By default, show tabs as ">", trailing spaces as "-", and non-breakable space characters as "+".
opt.list = true

-- Strings to use in `'list'`  mode and for the |:list| command
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Enables mouse support
opt.mouse = "a"

-- Print the line number in front of each line?
opt.number = true

-- Show the line number relative to the line with the cursor in front of each line?
opt.relativenumber = true

-- Minimal number of screen lines to keep above and below the cursor
opt.scrolloff = 10

-- If in Insert, Replace or Visual mode put a message on the last line?
opt.showmode = false

-- When and how to draw the sign column
opt.signcolumn = "yes"

-- Override the `'ignorecase'`  option if the search pattern contains upper case characters
opt.smartcase = true

-- Number of spaces to use for each step of (auto)indent
opt.shiftwidth = 2

-- When on, splitting a window will put the new window right of the current one
opt.splitright = true

-- When on, splitting a window will put the new window below the current one
opt.splitbelow = true

-- Use a swapfile for the buffer?
opt.swapfile = false

-- Number of spaces that a <Tab> int he file counts for
opt.tabstop = 2

-- Time in milliseconds to wait for a mapped sequence to complete
opt.timeoutlen = 300

-- When on, Vim automatically saves undo history to an undo file when writing a buffer to a file
opt.undofile = true

-- If this many milliseconds nothing is typed the swap file will be written to disk
opt.updatetime = 250

-- When on, lines longer than the width of the window will wrap and displaying continues on the next line
opt.wrap = true
