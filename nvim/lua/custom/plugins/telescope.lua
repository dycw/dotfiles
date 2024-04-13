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

        require("telescope").setup({
            defaults = {
                vimgrep_arguments = vimgrep_arguments,
            },
        })

        -- See `:help telescope.builtin`
        local builtin = require("telescope.builtin")
        local keymap_set = require("utilities").keymap_set
        keymap_set("n", "<Leader><Leader>", builtin.buffers, "Buffers")
        keymap_set("n", "<Leader>dd", function()
            require("telescope.builtin").diagnostics({ bufnr = 0 })
        end, "Document diagnostics (Search)")
        keymap_set("n", "<Leader>c", builtin.commands, "[C]ommands")
        keymap_set("n", "<Leader>ch", builtin.command_history, "Command [History]")
        keymap_set("n", "<Leader>wd", builtin.diagnostics, "Workspace [D]iagnostics (Search)")
        keymap_set("n", "<Leader>te", builtin.builtin, "T[e]lescope")
        keymap_set("n", "<Leader>ff", builtin.find_files, "Find [F]iles")
        keymap_set("n", "<Leader>gf", builtin.git_files, "Git [F]iles")
        keymap_set("n", "<Leader>gs", builtin.grep_string, "Grep [S]tring")
        keymap_set("n", "<Leader>ht", builtin.help_tags, "Help [T]ags")
        keymap_set("n", "<Leader>km", builtin.keymaps, "Key[M]aps")
        keymap_set("n", "<Leader>lg", builtin.live_grep, "Live [G]rep")
        keymap_set("n", "<Leader>of", builtin.oldfiles, "Old [F]iles")
        keymap_set("n", "<Leader>/", builtin.current_buffer_fuzzy_find, "Buffer fuzzy find")

        -- It's also possible to pass additional configuration options.
        --  See `:help telescope.builtin.live_grep()` for information about particular keys
        keymap_set("n", "<leader>s/", function()
            builtin.live_grep({
                grep_open_files = true,
                prompt_title = "Live Grep in Open Files",
            })
        end, "[S]earch [/] in Open Files")

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
