-- luacheck: push ignore
local api = vim.api
-- luacheck: pop

local send_escape = function()
    api.nvim_feedkeys(api.nvim_replace_termcodes("<Esc>", false, false, true), "n", false)
end

return {
    "windwp/nvim-spectre",
    config = function()
        local spectre = require("spectre")
        local utilities = require("utilities")
        local keymap_set = utilities.keymap_set

        spectre.setup({ live_update = true })
        keymap_set("n", "<Leader>sp", function()
            spectre.open_file_search()
        end, "S[p]ectre (file)")
        keymap_set("n", "<Leader>sP", function()
            spectre.toggle()
        end, "S[p]ectre (project)")
        keymap_set("n", "<Leader>sw", function()
            spectre.open_file_search({ select_word = true })
        end, "Spectre [W]ord (file)")
        keymap_set("n", "<Leader>sW", function()
            spectre.open_visual({ select_word = true })
        end, "Spectre [W]ord (project)")
        keymap_set("v", "<Leader>sp", function()
            send_escape()
            spectre.open_file_search()
        end, "S[p]ectre (file)")
        keymap_set("v", "<Leader>sP", function()
            send_escape()
            spectre.open_visual()
        end, "S[p]ectre (project)")
        keymap_set("v", "<Leader>sw", function()
            spectre.open_file_search({ select_word = true })
        end, "Spectre [W]ord (file)")
        keymap_set("v", "<Leader>sW", function()
            send_escape()
            spectre.open_visual({ select_word = true })
        end, "Spectre [W]ord (proejct)")
    end,
    dependencies = { "nvim-lua/plenary.nvim" },
}
