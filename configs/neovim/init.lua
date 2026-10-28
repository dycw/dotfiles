-- main
require("globals") -- setting leader must happen before plugins are loaded
require("autocmds")
require("keymaps")
require("opts")

-- Bootstrap lazy.nvim and load the configured plugins.
require("config.lazy")
