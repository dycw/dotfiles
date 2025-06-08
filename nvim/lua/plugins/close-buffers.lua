return {
    "kazhala/close-buffers.nvim",
    keys = {
        {
            "<Leader>k",
            function()
                require("close_buffers").delete({ type = "this" })
            end,
            desc = "[K]ill buffer",
        },
        {
            "<Leader>ko",
            function()
                require("close_buffers").delete({ type = "other" })
            end,
            desc = "Kill [o]thers",
        },
    },
}
