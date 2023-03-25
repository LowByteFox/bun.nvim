local ts_utils = require('nvim-treesitter.ts_utils')

local M = {}
local code_buf = nil

local get_ast_root = function()
    local node = ts_utils.get_node_at_cursor()
    if node == nil then
        error("Treesitter not found!")
    end

    local parent = node:parent()

    while (parent ~= nil) do
        node = parent
        parent = node:parent()
    end

    return node
end

local function all_trim(s)
   return s:match( "^%s*(.-)%s*$" )
end

local function get_text(rs, cs, ce)
    local str = code_buf[rs]
    return string.sub(str, cs, ce)
end

local function traverse(node, dat)
    for child in node:iter_children() do
        local type = child:type()
        if type == "call_expression" then
            local child2 = child:named_child(0)
            type = child2:type()
            if type == "identifier" then
                local rs, cs, _, ce = child2:range()
                local func_name = all_trim(get_text(rs + 1, cs, ce))
                if func_name == "describe" or func_name == "it" or func_name == "test" then
                    local first_param = child2:next_sibling():child(1):child(1);
                    rs, cs, _, ce = first_param:range()
                    local test_name = get_text(rs + 1, cs + 1, ce)
                    if func_name ~= "describe" then
                        table.insert(dat, test_name)
                    else
                        dat[test_name] = {}
                        traverse(child, dat[test_name])
                    end
                else
                    traverse(child, dat)
                end
            else
                traverse(child, dat)
            end
        else
            traverse(child, dat)
        end
    end
end

function M.get_tests()
    code_buf = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local node = get_ast_root()
    local tests = {}
    traverse(node, tests)
    return tests
end

function M.setup_floating_window(x, y, width, height, border)
    local win = {}
    win.buf = vim.api.nvim_create_buf(false, true)
    local opts = {
        relative = "editor",
        width = width,
        height = height,
        col = x,
        row = y,
        border = border
    }
    win.win = vim.api.nvim_open_win(win.buf, 0, opts)

    return win
end

function M.pair_index_iter(t)
    local i = 0
    return function()
        i = i + 1
        if t[i] ~= nil then
            return i, t[i]
        else
            local k, v = next(t, i)
            while k ~= nil and type(k) == "number" do
                i = k
                k, v = next(t, i)
            end
            if k ~= nil and type(k) ~= "number" then
                return k, v
            end
        end
    end
end

return M
