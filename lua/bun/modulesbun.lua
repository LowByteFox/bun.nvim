local M = {}

function M.register()
    vim.api.nvim_create_autocmd({ "BufEnter", "QuitPre", "WinLeave" }, {
        pattern = { "*.bun" },
        callback = function (ev)
            if ev.event ~= "BufEnter" then
                vim.cmd.setlocal("noreadonly")
                vim.cmd("u0")
                return
            end
            local handle = io.popen("cd / && /usr/bin/env bun " .. ev.file:sub(2))
            local res = {}
            if handle then
                for line in handle:lines() do
                    table.insert(res, line)
                end
                handle:close()
            end

            vim.api.nvim_buf_set_lines(0, 0, -1, true, res)
            vim.cmd.setlocal("readonly")
            vim.cmd.setfiletype("javascript")
        end
    })
end

return M
