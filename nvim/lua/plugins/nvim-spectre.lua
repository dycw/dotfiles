-- luacheck: push ignore
local v = vim
-- luacheck: pop

local send_escape = function()
    v.api.nvim_feedkeys(v.api.nvim_replace_termcodes("<Esc>", false, false, true), "n", false)
end

return {
    "windwp/nvim-spectre",
    config = function()
        local spectre = require("spectre")
        local utilities = require("utilities")
        local keymap_set = utilities.keymap_set

        local is_macos = v.fn.has("macunix")
        if is_macos == 1 then
            spectre.setup({
                live_update = true,
                replace_engine = { -- https://github.com/nvim-pack/nvim-spectre/issues/118#issuecomment-1531683211
                    ["sed"] = {
                        cmd = "sed",
                        args = { "-i", "", "-E" },
                    },
                },
            })
        else
            spectre.setup({ live_update = true })
        end

        keymap_set("n", "<Leader>sp", function()
            spectre.open_file_search()
        end, "s[p]ectre (file)")
        keymap_set("n", "<Leader>sP", function()
            spectre.toggle()
        end, "s[P]ectre (project)")
        -- keymap_set("n", "<Leader>sw", function()
        --     spectre.open_file_search({ select_word = true })
        -- end, "spectre [w]ord (file)")
        keymap_set("n", "<Leader>sW", function()
            spectre.open_visual({ select_word = true })
        end, "Spectre [W]ord (project)")
        keymap_set("v", "<Leader>sp", function()
            send_escape()
            spectre.open_file_search()
        end, "s[p]ectre (file)")
        keymap_set("v", "<Leader>sP", function()
            send_escape()
            spectre.open_visual()
        end, "s[P]ectre (project)")
        keymap_set("v", "<Leader>sw", function()
            spectre.open_file_search({ select_word = true })
        end, "spectre [w]ord (file)")
        keymap_set("v", "<Leader>sW", function()
            send_escape()
            spectre.open_visual({ select_word = true })
        end, "spectre [W]ord (proejct)")
    end,
    dependencies = { "nvim-lua/plenary.nvim" },
}
