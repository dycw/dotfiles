-- luacheck: push ignore vim
local opt = vim.opt
-- luacheck: pop

-- Make a backup before overwriting a file?
opt.backup = false

-- Every wrapped line with continue visually indended?
opt.breakindent = true

-- Sync clipboard between OS and Neovim
opt.clipboard = "unnamedplus"

-- Number of screen lines to use for the command-line
opt.cmdheight = 1

-- Comma-separated list of screen columns that are highlighted with ColorColumn
opt.colorcolumn = "80"

-- A comma-separated list of options for Insert mode completion
opt.completeopt = { "menuone", "preview" }

-- Determine how text with the "conceal" syntax attribute is shown
opt.conceallevel = 0

-- Highlight the text line of the cursor with CursorLine
opt.cursorline = true

-- Use the appropriate number of spaces to insert a <Tab>?
opt.expandtab = true

-- File-content encoding for the current buffer
opt.fileencoding = "utf-8"

-- The kind of folding used for the current window
opt.foldmethod = "manual"

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

local default_options = {
    cmdheight = 1, -- more space in the neovim command line for displaying messages
    foldmethod = "manual", -- folding, set to "expr" for treesitter based folding
    foldexpr = "", -- set to "nvim_treesitter#foldexpr()" for treesitter based folding
    hidden = true, -- required to keep multiple buffers and open multiple buffers
    hlsearch = true, -- highlight all matches on previous search pattern
    ignorecase = true, -- ignore case in search patterns
    mouse = "a", -- allow the mouse to be used in neovim
    pumheight = 10, -- pop up menu height
    showmode = false, -- we don't need to see things like -- INSERT -- anymore
    smartcase = true, -- smart case
    splitbelow = true, -- force all horizontal splits to go below current window
    splitright = true, -- force all vertical splits to go to the right of current window
    swapfile = false, -- creates a swapfile
    termguicolors = true, -- set term gui colors (most terminals support this)
    timeoutlen = 1000, -- time to wait for a mapped sequence to complete (in milliseconds)
    title = true, -- set the title of window to the value of the titlestring
    -- opt.titlestring = "%<%F%=%l/%L - nvim" -- what the title of the window will be set to
    -- undodir = undodir, -- set an undo directory
    undofile = true, -- enable persistent undo
    updatetime = 100, -- faster completion
    writebackup = false, -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
    expandtab = true, -- convert tabs to spaces
    shiftwidth = 2, -- the number of spaces inserted for each indentation
    tabstop = 2, -- insert 2 spaces for a tab
    cursorline = true, -- highlight the current line
    number = true, -- set numbered lines
    numberwidth = 4, -- set number column width to 2 {default 4}
    signcolumn = "yes", -- always show the sign column, otherwise it would shift the text each time
    wrap = false, -- display lines as one long line
    -- shadafile = join_paths(get_cache_dir(), "lvim.shada"),
    scrolloff = 8, -- minimal number of screen lines to keep above and below the cursor.
    sidescrolloff = 8, -- minimal number of screen lines to keep left and right of the cursor.
    showcmd = false,
    ruler = false,
    laststatus = 3,
}
