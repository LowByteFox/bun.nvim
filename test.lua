require("bun").setup({
    close_on_exit = false,
    cwd = "current"
})

local test = require("bun.tests")

vim.keymap.set("n", "<leader>xd", test.handler)
