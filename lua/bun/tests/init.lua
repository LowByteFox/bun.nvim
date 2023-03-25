local utils = require("bun.utils")
local stack = require("bun.stack")
local execution = require("bun.tests.execution")

local M = {}

local config = {
    width = 0.8,
    height = 0.8,
    border = "rounded"
}

local function transform_to_tree(tbl, tbl2)
    for i, v in pairs(tbl) do
        if type(v) == "table" then
            tbl2[i] = {opened = false}
            transform_to_tree(v, tbl2[i])
        else
            table.insert(tbl2, v)
        end
    end
end

local function color_test_pass(line)
    vim.cmd.sign("place 1 name=BunPass line=" .. tostring(line))
end


local function color_test_fail(line)
    vim.cmd.sign("place 1 name=BunFail line=" .. tostring(line))
end

local function check(lines)
    local line = vim.api.nvim_win_get_cursor(0)[1]
    if lines[line] and lines[line].func then
        local res = lines[line].func()
        if type(res) == "boolean" then
            if res then
                color_test_pass(line)
            else
                color_test_fail(line)
            end
        end
    end
end

local function expand(lines)
    local line = vim.api.nvim_win_get_cursor(0)[1]
    if lines[line] and lines[line].func then
        lines[line].func()
    end
end

local function lines_to_table(lines)
    local t = {}
    for _, v in pairs(lines) do
        table.insert(t, v.text)
    end
    return t
end

local function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local function generate(lines, opened, data, depth, names)
    local improved_table = {}
    for k, v in pairs(opened) do
        table.insert(improved_table, { i = k, v = v })
    end
    for i, v in ipairs(improved_table) do
        if type(v.v) == "table" then
            if v.v.opened then
                table.insert(lines, { text = string.rep(" ", depth) .. "⌄ " .. v.i, func = function() v.v.opened = false end, highlight = nil})
                -- table.insert(names, v.i)
                names:push(v.i)
                generate(lines, v.v, data[v.i], depth + 2, names)
            else
                table.insert(lines, { text = string.rep(" ", depth) .. "> " .. v.i, func = function() v.v.opened = true end, highlight = nil})
            end
        else
            local val = data[i]
            local copy = shallowcopy(names._et)
            if val then
                table.insert(lines, { text = string.rep(" ", depth) .. val, func = function()
                    local pattern = "" .. (copy[1] or "")
                    for index, name in ipairs(copy) do
                        if index > 1 then
                            pattern = pattern .. " > " .. name
                        end
                    end
                    local path;
                    if #pattern > 0 then
                        path = pattern .. " > " .. val
                    else
                        path = val
                    end
                    local output = execution.get_test_result(vim.fn.expand("%:t"))

                    for _, line in ipairs(output) do
                        local res = execution.check_result(line, path .. "\n")
                        if res then
                            if res == string.sub("✓", 0, 3) then
                                return true
                            else
                                return false
                            end
                        end
                    end
                end, highlight = nil })
            end
        end
    end
    if #names._et > 0 then
        names:pop()
    end
end

function M.handler()
    local HEIGHT_RATIO = config.height
    local WIDTH_RATIO = config.width

    vim.cmd.hi("BunTestFail ctermfg=red ctermbg=lightred guifg=red guibg=lightred")
    vim.cmd.hi("BunTestFailN ctermfg=red guifg=red")
    vim.cmd.hi("BunTestPass ctermfg=green ctermbg=lightgreen guifg=green guibg=lightgreen")
    vim.cmd.hi("BunTestPassN ctermfg=green guifg=green")
    vim.cmd.sign("define BunFail numhl=BunTestFailN linehl=BunTestFail")
    vim.cmd.sign("define BunPass numhl=BunTestPassN linehl=BunTestPass")

    local tests = utils.get_tests()
    local opened = {}
    transform_to_tree(tests, opened)

    local screen_w = vim.opt.columns:get()
    local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
    local window_w = screen_w * WIDTH_RATIO
    local window_h = screen_h * HEIGHT_RATIO
    local window_w_int = math.floor(window_w)
    local window_h_int = math.floor(window_h)
    local center_x = (screen_w - window_w) / 2
    local center_y = ((vim.opt.lines:get() - window_h) / 2) - vim.opt.cmdheight:get()

    local win = utils.setup_floating_window(center_x, center_y, window_w_int, window_h_int, config.border)
    vim.api.nvim_buf_set_lines(win.buf, 0, -1, true, {"Ahoj", "Cau"})

    local buf_num = vim.api.nvim_buf_get_number(win.buf)

    local lines = {}
    generate(lines, opened, tests, 0, stack:Create())
    vim.api.nvim_buf_set_lines(win.buf, 0, -1, true, lines_to_table(lines))

    vim.keymap.set("n", "<return>", function()
        vim.cmd.sign("unplace * buffer=" .. tostring(buf_num))
        expand(lines)
        lines = {}
        generate(lines, opened, tests, 0, stack:Create())
        vim.api.nvim_buf_set_lines(win.buf, 0, -1, true, lines_to_table(lines))
    end, { buffer = buf_num })

    vim.keymap.set("n", "<leader>r", function ()
        check(lines)
        -- highlighter(lines)
    end, { buffer = buf_num })
end

function M.setup(conf)

    if not conf then
        config = {
            width = 0.8,
            height = 0.8,
            border = "rounded"
        }
    else
        config = conf
    end

    if config.width == nil then
        config.width = 0.8
    end

    if config.width > 1.0 then
        config.width = 1.0
    end

    if config.height == nil then
        config.height = 0.8
    end

    if config.height > 1.0 then
        config.height = 1.0
    end

    if config.border ~= "none" and
        config.border ~= "single" and
        config.border ~= "double" and
        config.border ~= "solid" and
        config.border ~= "shadow" and
        config.border ~= "rounded" then
            config.border = "single"
        end
end

return M
