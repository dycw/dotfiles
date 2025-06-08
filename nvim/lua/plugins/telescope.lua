-- luacheck: push ignore
local v = vim
-- luacheck: pop
local fn = v.fn

return {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    config = function()
        local telescope = require("telescope")
        local builtin = require("telescope.builtin")
        local config = require("telescope.config")
        local keymap_set = require("utilities").keymap_set

        local vimgrep_arguments = { unpack(config.values.vimgrep_arguments) }
        table.insert(vimgrep_arguments, "--context=0")
        table.insert(vimgrep_arguments, "--trim")

        require("telescope").setup({
            defaults = {
                layout_config = {
                    height = 0.6,
                    preview_cutoff = 40,
                    preview_width = 0.67,
                    prompt_position = "top",
                    width = 0.99,
                },
                layout_strategy = "horizontal",
                path_display = "smart",
                sorting_strategy = "ascending",
                vimgrep_arguments = vimgrep_arguments,
            },
            extensions = {
                adjacent = {
                    level = 2, -- default
                },
            },
        })

        -- See `:help telescope.builtin`
        telescope.load_extension("adjacent")
        telescope.load_extension("recent-files")

        -- Leader
        keymap_set("n", "<Leader>te", builtin.builtin, "t[e]lescope")

        -- Shortcut for searching your Neovim configuration files
        keymap_set("n", "<Leader>nf", function()
            builtin.find_files({ cwd = fn.stdpath("config") })
        end, "neovim [f]iles")
        -- autocommands
        v.api.nvim_create_autocmd("VimEnter", {
            callback = function()
                if fn.argc() == 0 then
                    require("telescope").extensions["recent-files"].recent_files({})
                end
            end,
        })
    end,
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MaximilianLloyd/adjacent.nvim",
        "mollerhoj/telescope-recent-files.nvim",
    },
    event = "VimEnter",
}
