require("bun").setup({
    close_on_exit = false,
    cwd = "current"
})

local test = require("bun.tests")

test.setup({
    width = 0.9,
    border = "solid"
})

vim.keymap.set("n", "<leader>xd", test.handler)
