-- luacheck: push ignore
local v = vim
-- luacheck: pop
local api = v.api

return {
    "ibhagwan/fzf-lua",
    config = function()
        local fzf_lua = require("fzf-lua")
        local keymap_set = require("utilities").keymap_set

        fzf_lua.setup()
        -- buffers and files
        for _, value in ipairs({ { "f", "[f]iles" }, { "fi", "f[i]les" } }) do
            keymap_set("n", "<Leader>" .. value[1], fzf_lua.files, value[2])
        end
        keymap_set("n", "<Leader><Leader>", fzf_lua.buffers, "buffers")
        keymap_set("n", "<Leader>al", fzf_lua.lines, "all [l]ines")
        keymap_set("n", "<Leader>bl", fzf_lua.blines, "buffer [l]ines")
        keymap_set("n", "<Leader>of", fzf_lua.oldfiles, "old [f]iles")
        keymap_set("n", "<Leader>qf", fzf_lua.quickfix, "quick [f]ix")
        keymap_set("n", "<Leader>ta", fzf_lua.tabs, "t[a]bs")
        -- search
        keymap_set("n", "<Leader>/", fzf_lua.grep_curbuf, "grep buffer")
        for _, value in ipairs({ { "\\", "grep project" }, { "gr", "g[r]ep project" } }) do
            keymap_set("n", "<Leader>" .. value[1], fzf_lua.grep_project, value[2])
            -- don't use grep, no good
        end
        keymap_set("n", "<Leader>gl", fzf_lua.grep_last, "grep [l]ast")
        keymap_set("v", "<Leader>gr", fzf_lua.grep_visual, "g[r]ep")
        keymap_set("n", "<Leader>gw", fzf_lua.grep_cword, "grep [w]ord")
        keymap_set("n", "<Leader>gW", fzf_lua.grep_cWORD, "grep [W]ORD")
        -- git
        keymap_set("n", "<Leader>gc", fzf_lua.git_bcommits, "git buffer [c]ommits")
        keymap_set("n", "<Leader>gf", fzf_lua.git_files, "git [f]iles")
        keymap_set("n", "<Leader>ga", fzf_lua.git_branches, "git br[a]nches")
        keymap_set("n", "<Leader>gh", fzf_lua.git_status, "git stas[h]")
        keymap_set("n", "<Leader>go", fzf_lua.git_commits, "git c[o]mmits")
        keymap_set("n", "<Leader>gs", fzf_lua.git_status, "git [s]tatus")
        keymap_set("n", "<Leader>gt", fzf_lua.git_tags, "git [t]ags")
        -- LSP
        keymap_set("n", "gd", fzf_lua.lsp_definitions, "[d]efinitions")
        keymap_set("n", "gr", fzf_lua.lsp_references, "[r]eferences")
        keymap_set("n", "gD", fzf_lua.lsp_declarations, "[D]eclarations")
        keymap_set("n", "gI", fzf_lua.lsp_implementations, "[i]mplementations")
        keymap_set("n", "<Leader>ca", fzf_lua.lsp_code_actions, "code [a]ctions")
        keymap_set("n", "<Leader>ds", fzf_lua.lsp_document_symbols, "document [s]ymbols (search)")
        keymap_set("n", "<Leader>td", fzf_lua.lsp_typedefs, "type [d]efs")
        keymap_set("n", "<Leader>ws", fzf_lua.lsp_live_workspace_symbols, "workspace [s]ymbols (search)")
        -- miscellaneous
        keymap_set("n", "<Leader>ac", fzf_lua.autocmds, "auto[c]mds")
        keymap_set({ "n", "v" }, "<Leader>c", fzf_lua.commands, "[c]ommands")
        keymap_set("n", "<Leader>ch", fzf_lua.command_history, "command [h]istory")
        keymap_set("n", "<Leader>cg", fzf_lua.changes, "chan[g]es")
        keymap_set("n", "<Leader>fl", fzf_lua.builtin, "fzf-[l]ua")
        keymap_set("n", "<Leader>ft", fzf_lua.filetypes, "file [t]ypes")
        keymap_set("n", "<Leader>fr", fzf_lua.resume, "fzf-lua [r]esume")
        keymap_set("n", "<Leader>ht", fzf_lua.help_tags, "help [t]ags")
        keymap_set("n", "<Leader>hl", fzf_lua.highlights, "high[l]ights")
        keymap_set("n", "<Leader>ju", fzf_lua.jumps, "j[u]mps")
        keymap_set("n", "<Leader>km", fzf_lua.keymaps, "key [m]aps")
        keymap_set("n", "<Leader>ma", fzf_lua.marks, "[m]arks")
        keymap_set("n", "<Leader>me", fzf_lua.menus, "m[e]nus")
        keymap_set("n", "<Leader>mp", fzf_lua.manpages, "man [p]ages")
        keymap_set("n", "<Leader>re", fzf_lua.registers, "r[e]gisters")
        keymap_set("n", "<Leader>sh", fzf_lua.search_history, "search [h]istory")
        keymap_set("n", "<Leader>ss", fzf_lua.spell_suggest, "spell [s]uggest")

        -- UI select
        require("fzf-lua.providers.ui_select").register()

        -- autocommands
        api.nvim_create_autocmd("VimEnter", {
            callback = function()
                if v.fn.argv(0) == "" then
                    vim.cmd("GitFilesMRU")
                end
            end,
            desc = "git-files upon entering vim",
            group = api.nvim_create_augroup("git-files-upon-enter", { clear = true }),
        })

        local function get_git_root()
            local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")
            if vim.v.shell_error ~= 0 then
                print("Error: Not a git repository")
                return nil
            end
            return git_root[1] -- the output is a list, we need the first item
        end

        local function get_git_files(git_root)
            local relative_files = vim.fn.systemlist("git ls-files")
            if vim.v.shell_error ~= 0 then
                print("Not a git repository or other error")
                return {}
            end
            local absolute_files = {}
            for _, file in ipairs(relative_files) do
                table.insert(absolute_files, git_root .. "/" .. file) -- Convert to absolute path
            end
            return absolute_files
        end

        local function get_old_files()
            local oldfiles = vim.tbl_filter(function(f)
                return vim.fn.filereadable(f) == 1
            end, vim.v.oldfiles)
            return oldfiles
        end

        local function intersect_files(git_files, old_files)
            local git_files_set = {}
            for _, file in ipairs(git_files) do
                git_files_set[file] = true
            end

            local intersection = {}
            for _, file in ipairs(old_files) do
                if git_files_set[file] then
                    table.insert(intersection, file)
                end
            end
            return intersection
        end

        local function sort_git_files_by_oldfiles_presence(git_files, old_files)
            local old_files_set = {}
            for _, file in ipairs(old_files) do
                old_files_set[file] = true
            end

            -- Split git files into those present in old files and those not
            local sorted_files = {}
            local rest_files = {}
            for _, file in ipairs(git_files) do
                if old_files_set[file] then
                    table.insert(sorted_files, file)
                else
                    table.insert(rest_files, file)
                end
            end

            -- Sort the `sorted_files` based on the order in `old_files`
            table.sort(sorted_files, function(a, b)
                return vim.fn.index(old_files, a) < vim.fn.index(old_files, b)
            end)

            -- Concatenate the sorted files with the rest
            for _, file in ipairs(rest_files) do
                table.insert(sorted_files, file)
            end

            return sorted_files
        end

        local function convert_paths_to_relative(common_files, git_root)
            local relative_paths = {}
            for _, file in ipairs(common_files) do
                local relative_path = file:sub(#git_root + 2) -- Remove git root from the path
                table.insert(relative_paths, relative_path)
            end
            return relative_paths
        end

        local function open_selected_file(selected)
            if selected then
                vim.cmd("edit " .. selected[1])
            end
        end

        local function fzf_exec_with_open(files)
            local core = require("fzf-lua.core")
            core.fzf_exec(files, {
                actions = { default = open_selected_file },
                prompt = "Common Git and Old Files> ",
                previewer = "builtin",
            })
        end

        local function git_and_old_files_intersection()
            local git_root = get_git_root()
            if not git_root then
                return
            end -- exit if not in a git repository

            local git_files = get_git_files(git_root)
            local old_files = get_old_files()
            local sorted_files = sort_git_files_by_oldfiles_presence(git_files, old_files)
            local relative_files = convert_paths_to_relative(sorted_files, git_root)
            fzf_exec_with_open(relative_files)
        end

        vim.api.nvim_create_user_command("GitFilesMRU", git_and_old_files_intersection, {})
    end,

    dependencies = { "nvim-tree/nvim-web-devicons" },
}
