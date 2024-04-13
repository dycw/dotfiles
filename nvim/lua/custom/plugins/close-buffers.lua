return {
    "kazhala/close-buffers.nvim",
    config = function()
        require("utilities").keymap_set("n", "<Leader>bd", function()
            require("close_buffers").delete({ type = "this" })
        end, "Buffer [D]elete")
    end,
}
