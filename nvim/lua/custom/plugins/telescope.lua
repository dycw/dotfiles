-- luacheck: push ignore
local v = vim
-- luacheck: pop
local fn = v.fn

return {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    config = function()
        local telescope_config = require("telescope.config")
        local vimgrep_arguments = { unpack(telescope_config.values.vimgrep_arguments) }
        table.insert(vimgrep_arguments, "--context=0")
        table.insert(vimgrep_arguments, "--trim")

        require("telescope").setup({
            defaults = {
                layout_config = {
                    height = 0.8,
                    preview_cutoff = 40,
                    preview_height = 0.6,
                    prompt_position = "bottom",
                    width = 0.8,
                },
                layout_strategy = "vertical",
                path_display = "smart",
                vimgrep_arguments = vimgrep_arguments,
            },
        })

        -- See `:help telescope.builtin`
        local builtin = require("telescope.builtin")
        local keymap_set = require("utilities").keymap_set

        -- Leader
        keymap_set("n", "<Leader>te", builtin.builtin, "T[e]lescope")

        -- Shortcut for searching your Neovim configuration files
        keymap_set("n", "<Leader>sN", function()
            builtin.find_files({ cwd = fn.stdpath("config") })
        end, "Search [N]eovim files")
    end,
    dependencies = {
        "nvim-lua/plenary.nvim",
        { "nvim-tree/nvim-web-devicons", enabled = v.g.have_nerd_font },
    },
    event = "VimEnter",
}
