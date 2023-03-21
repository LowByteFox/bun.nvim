local ok, term = pcall(require, 'toggleterm.terminal')

if not ok then
    vim.cmd.echoerr("Missing 'toggleterm', please install 'akinsho/toggleterm.nvim'")
    return
end

local M = {}

local config = {}

local function run_term(args)
    local pth = ""
    if config.cwd == "current" then
        pth = vim.fn.getcwd()
    elseif config.cwd == "relative" then
        pth = vim.fn.expand("%:p:h")
    else
        pth = vim.fn.getcwd()
    end

    term.Terminal:new({
        cmd = "bun " .. args,
        close_on_exit = config.close_on_exit,
        direction = config.direction,
        hidden = false,
        dir = pth,
        auto_scroll = true
    }):toggle()
end

function M.run_current()
    local path = vim.fn.expand("%:p")
    print(path)
    run_term("run " .. path)
end

function M.setup(conf)
    if not conf then
        config = {
            close_on_exit = true,
            direction = "horizontal",
            cwd = "current"
        }
    else
        config = conf
    end

    if config.close_on_exit == nil then
        config.close_on_exit = true
    end

    if config.cwd == nil then
        config.cwd = "current"
    end

    if config.direction == nil then
        config.direction = "horizontal"
    end

    if config.direction ~= "horizontal" and config.direction ~= "float" then
        config.direction = "horizontal"
    end

    if config.cwd ~= "current" and config.cwd ~= "relative" then
        config.direction = "current"
    end

    vim.api.nvim_create_user_command('Bun',
    function(opts)
        if opts.fargs[1] ~= "run_current" then
            run_term(table.concat(opts.fargs, " "))
        else
            M.run_current()
        end
    end,
    {
        nargs = 1,
        complete = function()
            return { "run", "run_current", "x", "test", "init", "create", "install", "add", "link", "remove", "unlink", "pm", "dev", "bun", "upgrade", "completions", "discord", "help"}
        end
    }
)

end

return M
