local utils =  require("bun.utils")

local M = {}

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

local function expand(lines)
    local line = vim.api.nvim_win_get_cursor(0)[1]
    if lines[line] and lines[line].func then
        lines[line].func()
    end
end

local function lines_to_table(lines)
    local t = {}
    for i, v in pairs(lines) do
        table.insert(t, v.text)
    end
    return t
end

local function generate(lines, opened, data, depth)
    local improved_table = {}
    for k, v in pairs(opened) do
        table.insert(improved_table, { i = k, v = v })
    end
    for i, v in ipairs(improved_table) do
        if type(v.v) == "table" then
            if v.v.opened then
                table.insert(lines, { text = string.rep(" ", depth) .. "⌄ " .. v.i, func = function() v.v.opened = false end})
                generate(lines, v.v, data[v.i], depth + 2)
            else
                table.insert(lines, { text = string.rep(" ", depth) .. "> " .. v.i, func = function() v.v.opened = true end})
            end
        else
            local val = data[i]
            if val then
                table.insert(lines, { text = string.rep(" ", depth) .. val, func = nil })
            end
        end
        ::continue::
    end
end

function M.handler()
    local HEIGHT_RATIO = 0.8 -- You can change this
    local WIDTH_RATIO = 0.8  -- You can change this too

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

    local win = utils.setup_floating_window(center_x, center_y, window_w_int, window_h_int, "rounded")
    vim.api.nvim_buf_set_lines(win.buf, 0, -1, true, {"Ahoj", "Cau"})

    local buf_num = vim.api.nvim_buf_get_number(win.buf)


    local lines = {}
    generate(lines, opened, tests, 0)
    vim.api.nvim_buf_set_lines(win.buf, 0, -1, true, lines_to_table(lines))

    vim.keymap.set("n", "<return>", function()
        expand(lines)
        lines = {}
        generate(lines, opened, tests, 0)
        vim.api.nvim_buf_set_lines(win.buf, 0, -1, true, lines_to_table(lines))
    end, { buffer = buf_num })
end

return M
