local M = {}

function M.check_result(text, test_pattern)
    local res = string.match(text, "✗ " .. test_pattern)
    if res == nil then
        res = string.match(text, "✓ " .. test_pattern)
        if res == nil then return nil end
    end

    return string.sub(res, 0, 3)
end

function M.get_test_result(filename)
    local err_file = os.tmpname()
    local handle = io.popen("/usr/bin/env bun test" .. filename .. " 2> " .. err_file)
    if handle then
        handle:read("*a")
        handle:close()
    end
    local res = {}

    local file = io.open(err_file, "r")

    for line in file:lines() do
        table.insert(res, line .. "\n")
    end

    os.remove(err_file)

    return res
end

return M
