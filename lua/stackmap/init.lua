local M = {}
M._stack = {}

local find_mappings = function(maps, lhs)
    for _, value in ipairs(maps) do
        if value.lhs == lhs then
            return value
        end
    end
end

M.push = function(name, mode, mappings)
    local maps = vim.api.nvim_get_keymap(mode)

    local existing_maps = {}
    for lhs, rhs in pairs(mappings) do
        local existing = find_mappings(maps, lhs)
        if existing then
            existing_maps[lhs] = existing
        end
    end

    if not M._stack[name] then
        M._stack[name] = {}
    end

    M._stack[name][mode] = {
        existing = existing_maps,
        mappings = mappings,
    }

    for lhs, rhs in pairs(mappings) do
        vim.keymap.set(mode, lhs, rhs)
    end
end

M.pop = function(name, mode)
    local state = M._stack[name][mode]

    if not state then
        -- give feedback?
        return
    end

    M._stack[name][mode] = nil

    local emptyIt = true
    for value in pairs(M._stack[name]) do
        if value then
            emptyIt = false
        end
    end

    if emptyIt then
        M._stack[name] = nil
    end

    for lhs, _ in pairs(state.mappings) do
        if state.existing[lhs] then
            vim.keymap.set(mode, lhs, state.existing[lhs].rhs)
        else
            vim.keymap.del(mode, lhs)
        end
    end
end

M._drop_stack = function()
    M._stack = {}
end

return M
