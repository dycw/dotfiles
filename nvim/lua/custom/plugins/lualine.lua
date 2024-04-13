return {
    "nvim-lualine/lualine.nvim",
    config = function()
        local function git_relative_path()
            local handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
            if handle == nil then
                return "[Unable to get repo root]"
            end
            local git_root = handle:read("*a")
            handle:close()
            git_root = string.gsub(git_root, "\n$", "")

            if git_root == "" then
                return "[Not in repo]"
            end

            -- luacheck: push ignore
            local fn = vim.fn
            -- luacheck: pop

            local file_path = fn.expand("%:p")
            if fn.stridx(file_path, git_root) == 0 then
                return file_path:sub(#git_root + 2)
            else
                return "[Outside repo]"
            end
        end

        require("lualine").setup({
            sections = {
                lualine_c = {
                    git_relative_path,
                },
            },
        })
    end,
    dependencies = { "nvim-tree/nvim-web-devicons" },
}
