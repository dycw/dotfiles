-- luacheck: push ignore
local v = vim
-- luacheck: pop
local fn = v.fn

return {
    "nvim-telescope/telescope.nvim",
    -- branch = "0.1.x",  -- https://github.com/nvim-telescope/telescope.nvim/issues/3438
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
                path_display = { "smart" },
                sorting_strategy = "ascending",
                vimgrep_arguments = vimgrep_arguments,
            },
            extensions = {
                adjacent = {
                    level = 2, -- default
                },
            },
        })

        -- extensions
        telescope.load_extension("adjacent")
        telescope.load_extension("recent-files")

        -- key maps
        -- key maps: files
        keymap_set("n", "<Leader><Leader>", function()
            require("telescope").extensions["recent-files"].recent_files({})
        end, "recent files")
        keymap_set("n", "<Leader>af", "<Cmd>Telescope adjacent<CR>", "[a]djacent files")
        keymap_set("n", "<Leader>ff", builtin.find_files, "find [f]iles")
        keymap_set("n", "<Leader>gf", builtin.git_files, "git [f]iles")
        keymap_set("n", "<Leader>lg", builtin.live_grep, "live [g]rep")
        keymap_set("n", "<Leader>of", builtin.oldfiles, "old [f]iles")

        -- key maps: buffers
        keymap_set("n", "<Leader>bb", builtin.buffers, "[b]uffers")

        -- key maps: LSP
        keymap_set("n", "gd", builtin.lsp_definitions, "[d]efinitions")
        keymap_set("n", "gi", builtin.lsp_incoming_calls, "[i]ncoming calls")
        keymap_set("n", "go", builtin.lsp_outgoing_calls, "[o]utgoing calls")
        keymap_set("n", "gr", builtin.lsp_references, "[r]eferences")
        -- keymap_set("n", "gD", builtin.lsp_declarations, "[D]eclarations")
        -- keymap_set("n", "gI", builtin.lsp_implementations, "[i]mplementations")
        -- keymap_set("n", "<Leader>ca", builtin.lsp_code_actions, "code [a]ctions")
        keymap_set("n", "<Leader>ds", builtin.lsp_document_symbols, "document [s]ymbols")
        keymap_set("n", "<Leader>td", builtin.lsp_type_definitions, "type [d]efinitions")
        keymap_set("n", "<Leader>ws", builtin.lsp_dynamic_workspace_symbols, "workspace [s]ymbols")

        -- keys maps: text
        keymap_set("n", "<Leader>gs", builtin.grep_string, "grep [s]tring")
        keymap_set("n", "<Leader>bf", builtin.current_buffer_fuzzy_find, "buffer [f]uzzy find")

        -- key maps: miscellaneous
        keymap_set("n", "<Leader>ch", builtin.command_history, "command [h]istory")
        keymap_set({ "n", "v" }, "<Leader>co", builtin.commands, "c[o]mmands")
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
