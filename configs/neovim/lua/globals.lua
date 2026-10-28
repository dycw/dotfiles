-- luacheck: push ignore
local v = vim
-- luacheck: pop

local cargo_home = v.env.CARGO_HOME or v.fn.expand("~/.cargo")
local cargo_bin = cargo_home .. "/bin"
local path_entries = v.split(v.env.PATH or "", ":", { plain = true })
if v.fn.isdirectory(cargo_bin) == 1 and not v.tbl_contains(path_entries, cargo_bin) then
    v.env.PATH = cargo_bin .. (v.env.PATH and v.env.PATH ~= "" and ":" .. v.env.PATH or "")
end

local g = v.g

-- leader
g.mapleader = " "
g.maplocalleader = " "
g.rustaceanvim = {
    server = {
        default_settings = {
            ["rust-analyzer"] = {
                checkOnSave = { command = "check" },
            },
        },
    },
}

-- Nerd Font
g.have_nerd_font = false
