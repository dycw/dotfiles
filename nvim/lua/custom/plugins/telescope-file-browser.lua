return {
    "nvim-telescope/telescope-file-browser.nvim",
    config = function()
        local telescope = require("telescope")
        telescope.setup({
            extensions = {
                file_browser = {
                    hidden = { file_browser = true, folder_browser = true },
                },
            },
        })
        telescope.load_extension("recent-files")
        require("utilities").keymap_set("n", "<Leader>fb", function()
            telescope.extensions.file_browser.file_browser()
        end, "File [B]rowser")
    end,
    dependencies = "nvim-telescope/telescope.nvim",
    event = "VeryLazy",
}
