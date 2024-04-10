local function merge_tables(t1, t2)
    local result = {}
    for k, v in pairs(t1) do
        result[k] = v
    end
    for k, v in pairs(t2) do
        result[k] = v
    end
    return result
end

local keymap_opts = { noremap = true, silent = true }

local keymap_set = function(mode, lhs, rhs, desc)
    -- luacheck: push ignore
    local v = vim
    -- luacheck: pop
    v.keymap.set(mode, lhs, rhs, merge_tables(keymap_opts, { desc = desc }))
end

return {
    keymap_opts = keymap_opts,
    keymap_set = keymap_set,
    merge_tables = merge_tables,
}
