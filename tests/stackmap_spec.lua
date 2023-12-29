local find_map = function(maps, lhs)
    for _, map in ipairs(maps) do
        if map.lhs == lhs then
            return map
        end
    end
end

describe("stackmap", function()
    local rhs = "echo 'this is a test'"

    after_each(function()
        require("stackmap")._drop_stack()

        pcall(vim.keymap.del, "n", "asdf")
        pcall(vim.keymap.del, "n", "asdf_1")
        pcall(vim.keymap.del, "n", "asdf_2")
    end)

    it("can be required", function()
        require("stackmap")
    end)

    it("can push a single mapping", function()
        require("stackmap").push("test1", "n", {
            ["asdf"] = rhs
        })

        local maps = vim.api.nvim_get_keymap('n')
        local found = find_map(maps, "asdf")

        assert.are.same(rhs, found.rhs)
    end)

    it("can push multiple mappings", function()
        require("stackmap").push("test2", "n", {
            ["asdf_1"] = rhs .. "1",
            ["asdf_2"] = rhs .. "2",
        })

        local maps = vim.api.nvim_get_keymap('n')
        local found = find_map(maps, "asdf_1")
        assert.are.same(rhs .. "1", found.rhs)

        found = find_map(maps, "asdf_2")
        assert.are.same(rhs .. "2", found.rhs)
    end)

    it("can pop stack and reset state", function()
        require("stackmap").push("test1", "n", {
            ["asdf"] = rhs
        })

        local maps = vim.api.nvim_get_keymap('n')
        local found = find_map(maps, "asdf")
        assert.are.same(rhs, found.rhs)

        require("stackmap").pop("test1", "n")

        maps = vim.api.nvim_get_keymap('n')
        found = find_map(maps, "asdf")
        assert.equals(nil, found)

        assert.equals(nil, require("stackmap")._stack["test1"])
    end)
end)
