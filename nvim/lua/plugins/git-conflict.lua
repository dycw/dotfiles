-- luacheck: push ignore
local v = vim
-- luacheck: pop

return {
    "akinsho/git-conflict.nvim",
    version = "*",
    config = function()
        require("git-conflict").setup({
            default_mappings = {
                ours = "o",
                theirs = "t",
                none = "0",
                both = "b",
                next = "n",
                prev = "p",
            },
        })

        v.api.nvim_create_autocmd("User", {
            pattern = "GitConflictDetected",
            callback = function(event)
                v.notify("Conflict detected in " .. v.fn.expand("<afile>"))
                v.keymap.set("n", "cww", function()
                    require("git-conflict").conflict_buster()
                    require("git-conflict").create_buffer_local_mappings()
                end, { buffer = event.buf })
            end,
        })
    end,
}
