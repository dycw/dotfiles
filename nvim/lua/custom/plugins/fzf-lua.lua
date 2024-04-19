-- luacheck: push ignore
local v = vim
-- luacheck: pop
local api = v.api
local fn = v.fn

local function get_git_root()
    local git_root = fn.systemlist("git rev-parse --show-toplevel")
    if v.v.shell_error ~= 0 then
        print("Error: Not a git repository")
        return nil
    end
    return git_root[1] -- the output is a list, we need the first item
end

local function get_git_files(git_root)
    local rel_files = fn.systemlist("git ls-files")
    if v.v.shell_error ~= 0 then
        print("Not a git repository or other error")
        return {}
    end
    local abs_files = {}
    for _, file in ipairs(rel_files) do
        table.insert(abs_files, git_root .. "/" .. file) -- Convert to absolute path
    end
    return abs_files
end

local function get_old_files()
    return v.tbl_filter(function(file)
        return fn.filereadable(file) == 1
    end, v.v.oldfiles)
end

local function sort_git_files_by_oldness(git_files, old_files)
    local old_files_set = {}
    for _, file in ipairs(old_files) do
        old_files_set[file] = true
    end

    -- partition based on oldness
    local git_old_files = {}
    local git_non_old_files = {}
    for _, file in ipairs(git_files) do
        if old_files_set[file] then
            table.insert(git_old_files, file)
        else
            table.insert(git_non_old_files, file)
        end
    end
    table.sort(git_old_files, function(a, b)
        return fn.index(old_files, a) < fn.index(old_files, b)
    end)

    -- concatenate the non-old onto old
    for _, file in ipairs(git_non_old_files) do
        table.insert(git_old_files, file)
    end
    return git_old_files
end

local function make_paths_relative(abs_files, git_root)
    local rel_files = {}
    for _, file in ipairs(abs_files) do
        local relative_path = file:sub(#git_root + 2) -- Remove git root from the path
        table.insert(rel_files, relative_path)
    end
    return rel_files
end

local function open_selected_file(selected)
    if selected then
        v.cmd("edit " .. selected[1])
    end
end

local function git_files_mru()
    local git_root = get_git_root()
    if not git_root then
        return
    end -- exit if not in a git repository

    local git_files = get_git_files(git_root)
    local old_files = get_old_files()
    local abs_files = sort_git_files_by_oldness(git_files, old_files)
    local rel_files = make_paths_relative(abs_files, git_root)
    local opts = {
        actions = { default = open_selected_file },
        prompt = "GitFilesMRU> ",
        previewer = "builtin",
    }
    require("fzf-lua.core").fzf_exec(rel_files, opts)
end

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
        keymap_set("n", "<Leader>gf", git_files_mru, "git [f]iles")
        keymap_set("n", "<Leader>ga", fzf_lua.git_branches, "git br[a]nches")
        keymap_set("n", "<Leader>gh", fzf_lua.git_stash, "git stas[h]")
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

        -- git files (MRU)

        api.nvim_create_user_command("GitFilesMRU", git_files_mru, {})

        -- autocommands
        api.nvim_create_autocmd("VimEnter", {
            callback = function()
                if v.fn.argv(0) == "" then
                    git_files_mru()
                end
            end,
            desc = "git-files upon entering vim",
            group = api.nvim_create_augroup("git-files-upon-enter", { clear = true }),
        })
    end,

    dependencies = { "nvim-tree/nvim-web-devicons" },
}
