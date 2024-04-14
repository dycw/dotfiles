return {
    "ibhagwan/fzf-lua",
    config = function()
        local fzf_lua = require("fzf-lua")
        local keymap_set = require("utilities").keymap_set

        fzf_lua.setup()
        -- buffers and files
        keymap_set("n", "<Leader><Leader>", fzf_lua.buffers, "buffers")
        keymap_set("n", "<Leader>al", fzf_lua.lines, "all [l]ines")
        keymap_set("n", "<Leader>bl", fzf_lua.blines, "Buffer [l]ines")
        keymap_set("n", "<Leader>of", fzf_lua.oldfiles, "old [f]iles")
        keymap_set("n", "<Leader>qf", fzf_lua.quickfix, "quick [f]ix")
        keymap_set("n", "<Leader>ta", fzf_lua.tabs, "T[a]bs")
        -- search
        keymap_set("n", "<Leader>/", fzf_lua.grep_curbuf, "grep buffer")
        for _, value in ipairs({ { "\\", "grep project" }, { "gf", "g[r]ep project" } }) do
            keymap_set("n", "<Leader>" .. value[1], fzf_lua.grep_project, value[2])
            -- don't use grep, no good
        end
        keymap_set("n", "<Leader>gl", fzf_lua.grep_last, "grep [l]ast")
        keymap_set("v", "<Leader>gr", fzf_lua.grep_visual, "g[r]ep")
        keymap_set("n", "<Leader>gw", fzf_lua.grep_cword, "grep [w]ord")
        keymap_set("n", "<Leader>gW", fzf_lua.grep_cWORD, "grep [W]ORD")
        -- git
        keymap_set("n", "<Leader>gc", fzf_lua.git_bcommits, "git buffer [c]ommits")
        for _, value in ipairs({ { "f", "[f]iles" }, { "gf", "git [f]iles" } }) do
            keymap_set("n", "<Leader>" .. value[1], fzf_lua.git_files, value[2])
        end
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
        keymap_set("n", "<Leader>ht", fzf_lua.manpages, "man [p]ages")
        keymap_set("n", "<Leader>ju", fzf_lua.jumps, "j[u]mps")
        keymap_set("n", "<Leader>km", fzf_lua.keymaps, "key [m]aps")
        keymap_set("n", "<Leader>m", fzf_lua.marks, "[m]arks")
        keymap_set("n", "<Leader>me", fzf_lua.menus, "m[e]nus")
        keymap_set("n", "<Leader>re", fzf_lua.registers, "r[e]gisters")
        keymap_set("n", "<Leader>sh", fzf_lua.search_history, "search [h]istory")
        keymap_set("n", "<Leader>ss", fzf_lua.spell_suggest, "spell [s]uggest")
    end,
    dependencies = { "nvim-tree/nvim-web-devicons" },
}
