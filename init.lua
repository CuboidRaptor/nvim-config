-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- line cursor in normal mode
-- vim.opt.guicursor = "a:ver95"

-- mini surround
require("mini.surround").setup()

-- nord colourscheme
require("catppuccin").setup({
    flavour = "macchiato",
    dim_inactive = {
        enabled = true
    }
})
vim.cmd.colorscheme "catppuccin"

-- python auto-indent settings
vim.g["python_indent"] = { 
    disable_parentheses_indenting = false,
    closed_paren_align_last_line = false,
    searchpair_timeout = 150,
    continue = "shiftwidth()",
    open_paren = "shiftwidth()",
    nested_paren = "shiftwidth()"
}

vim.cmd([[set timeoutlen=420]])
