-- luacheck: push ignore vim
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
            -- You can put your default mappings / updates / etc. in here
            --  All the info you're looking for is in `:help telescope.setup()`
            --
            -- defaults = {
            --   mappings = {
            --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
            --   },
            -- },
            -- pickers = {}
            extensions = {
                file_browser = {
                    hidden = { file_browser = true, folder_browser = true },
                },
                live_grep_args = {
                    require("telescope").load_extension("live_grep_args"),
                },
                ["ui-select"] = {
                    require("telescope.themes").get_dropdown(),
                },
            },
        })

        -- Enable Telescope extensions if they are installed
        pcall(require("telescope").load_extension, "fzf")
        pcall(require("telescope").load_extension, "ui-select")

        -- See `:help telescope.builtin`
        local builtin = require("telescope.builtin")
        local keymap_set = require("utilities").keymap_set
        keymap_set("n", "<Leader><Leader>", builtin.buffers, "Buffers")
        keymap_set("n", "<Leader>dd", function()
            require("telescope.builtin").diagnostics({ bufnr = 0 })
        end, "Document diagnostics (Search)")
        keymap_set("n", "<Leader>c", builtin.commands, "Commands")
        keymap_set("n", "<Leader>wd", builtin.diagnostics, "Workspace diagnostics (Search)")
        keymap_set("n", "<Leader>te", builtin.builtin, "Telescope")
        keymap_set("n", "<Leader>ff", builtin.find_files, "Find Files")
        keymap_set("n", "<Leader>gf", builtin.git_files, "Git Files")
        keymap_set("n", "<Leader>gs", builtin.grep_string, "Grep String")
        keymap_set("n", "<Leader>ht", builtin.help_tags, "Help Tags")
        keymap_set("n", "<Leader>km", builtin.keymaps, "Keymaps")
        keymap_set("n", "<Leader>lg", builtin.live_grep, "Live Grep")
        keymap_set("n", "<Leader>of", builtin.oldfiles, "Old Files")

        -- Slightly advanced example of overriding default behavior and theme
        keymap_set("n", "<Leader>/", function()
            -- You can pass additional configuration to Telescope to change the theme, layout, etc.
            builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
                winblend = 10,
                previewer = false,
            }))
        end, "Current buffer fuzzy find")

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
        end, "Search Neovim files")

        -- Extension: File Browser
        keymap_set("n", "<Leader>fb", function()
            require("telescope").extensions.file_browser.file_browser()
        end, "File [B]rowser")

        -- Extension: Live Grep args
        keymap_set("n", "<Leader>lG", function()
            require("telescope").extensions.live_grep_args.live_grep_args()
        end, "Live Grep (args)")
    end,
    dependencies = {
        "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-file-browser.nvim" },
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
            cond = function()
                return fn.executable("make") == 1
            end,
        },
        {
            "nvim-telescope/telescope-live-grep-args.nvim",
            version = "^1.0.0",
        },
        { "nvim-telescope/telescope-ui-select.nvim" },
        { "nvim-tree/nvim-web-devicons", enabled = v.g.have_nerd_font },
    },
    event = "VimEnter",
}
