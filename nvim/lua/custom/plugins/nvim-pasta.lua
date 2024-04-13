return {
    "hrsh7th/nvim-pasta",
    config = function()
        local mapping = require("pasta.mapping")
        local keymap_set = require("utilities").keymap_set

        keymap_set({ "n", "x" }, "p", mapping.p, "Paste after")
        keymap_set({ "n", "x" }, "P", mapping.P, "Paste before")
    end,
}
