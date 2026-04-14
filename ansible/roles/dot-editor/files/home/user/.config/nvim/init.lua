-----------------------------------------------------------
-- Plugin loading (builtin packages)
-----------------------------------------------------------
-- Plugins are cloned into:
--   ~/.local/share/nvim/site/pack/plugins/opt
-- and loaded here via :packadd.

vim.cmd.packadd("gitsigns.nvim")
vim.cmd.packadd("guess-indent.nvim")
vim.cmd.packadd("lualine.nvim")
vim.cmd.packadd("nightfox.nvim")
vim.cmd.packadd("snacks.nvim")



-----------------------------------------------------------
-- UI / colors
-----------------------------------------------------------

vim.cmd("syntax on")
vim.cmd("filetype plugin indent on")

vim.opt.clipboard = "unnamedplus" -- Use system clipboard.
vim.opt.termguicolors = true      -- Enable 24-bit color.



-----------------------------------------------------------
-- Leader keys
-----------------------------------------------------------

vim.g.mapleader = " "             -- <leader> is <Space>
vim.g.maplocalleader = "\\"       -- <localleader> is '\':w



-----------------------------------------------------------
-- General behavior
-----------------------------------------------------------

vim.opt.hidden = true             -- Hide buffers when they are abandoned.
vim.opt.joinspaces = false        -- Use one space after a period.
vim.opt.showmatch = true          -- Show matching brackets.
vim.opt.tabpagemax = 200          -- Increase max number of tab pages.
vim.opt.title = true              -- Set terminal title.
vim.opt.visualbell = true         -- No audible bell.

-- Enables a menu at the bottom of the window.
vim.opt.wildmode = "list:longest,full"

-- Don't copy
vim.api.nvim_set_keymap('n', 'c', '"_c', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'C', '"_C', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'd', '"_d', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'D', '"_D', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'x', '"_x', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'c', '"_c', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'd', '"_d', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'x', '"_x', { noremap = true, silent = true })



-----------------------------------------------------------
-- Searching
-----------------------------------------------------------

vim.opt.ignorecase = true         -- Case-insensitive search by default.
vim.opt.infercase = true          -- Infer case in insert-mode completion.
vim.opt.smartcase = true          -- Override ignorecase if search has uppercase.



-----------------------------------------------------------
-- Key mappings
-----------------------------------------------------------

-- jj in insert mode = <Esc>
vim.keymap.set("i", "jj", "<Esc>", { noremap = true, desc = "Exit insert mode" })



-----------------------------------------------------------
-- Filetype detection and indentation
-----------------------------------------------------------

local ft_group = vim.api.nvim_create_augroup("FiletypeIndent", { clear = true })

local function ft(pattern, command)
  vim.api.nvim_create_autocmd("FileType", {
    group = ft_group,
    pattern = pattern,
    command = command,
  })
end

-- For all text files set 'textwidth' to 80 characters.
ft("text", "setlocal textwidth=80")

-- Indentation options per filetype:
ft("ant", "setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=120")
ft("bash,sh,c,cpp", "setlocal tabstop=8 softtabstop=8 shiftwidth=8 noexpandtab textwidth=80")
ft("conf", "setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=80")
ft("groovy", "setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab textwidth=100")
ft("java,javascript,json,xml,xsd,css,html", "setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=120")
ft("python", "setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=80")
ft("ruby,yaml", "setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab textwidth=80")



-----------------------------------------------------------
-- Highlight trailing whitespace
-----------------------------------------------------------

local ws_group = vim.api.nvim_create_augroup("ExtraWhitespace", { clear = true })

vim.api.nvim_set_hl(0, "ExtraWhitespace", { bg = "red" })

vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter", "InsertLeave" }, {
  group = ws_group,
  pattern = "*",
  command = [[match ExtraWhitespace /\s\+$/]],
})

vim.api.nvim_create_autocmd("WinLeave", {
  group = ws_group,
  pattern = "*",
  command = [[match none]],
})



-----------------------------------------------------------
-- C-mode options
-----------------------------------------------------------
-- t   auto-wrap comments
-- c   allow 'textwidth' to work on comments
-- q   allow use of gq* for auto formatting
-- l   don't break long lines in insert mode
-- r   insert '*' on <CR> in comments
-- o   insert '*' on 'o' in comments
-- n   recognize numbered bullets in comments
vim.opt.formatoptions = "tcqlron"
-- N   number of spaces
-- Ns  number of spaces * shiftwidth
-- >N  default indent
-- eN  extra indent if the { is at the end of a line
-- nN  extra indent if there is no {} block
-- fN  indent of the { of a function block
-- gN  indent of the C++ class scope declarations (public, private, protected)
-- {N  indent of a { on a new line after an if,while,for...
-- }N  indent of a } in reference to a {
-- ^N  extra indent inside a function {}
-- :N  indent of case labels
-- =N  indent of case body
-- lN  align case {} on the case line
-- tN  indent of function return type
-- +N  indent continued algibreic expressions
-- cN  indent of comment line after /*
-- )N  vim searches for closing )'s at most N lines away
-- *N  vim searches for closing */ at most N lines away
vim.opt.cinoptions = "+0.5s,(0.5s,u0,:0"



-----------------------------------------------------------
-- Plugin configuration
-----------------------------------------------------------

-- Nightfox setup
require("nightfox").setup({
  options = {
    transparent = true,
  },
})
vim.cmd("colorscheme nordfox")

-- Lualine
require("lualine").setup({
  options = {
    theme = "nordfox",
    icons_enabled = true,
  },
  tabline = {
    lualine_a = {
      {
        'tabs',
        mode = 1,
	max_length = function()
          return vim.o.columns
        end,
      },
    },
  },
})

-- Gitsigns
require("gitsigns").setup({})

-- Guess-indent
require("guess-indent").setup({})



-----------------------------------------------------------
-- Snacks configuration
-----------------------------------------------------------

local Snacks = require("snacks")

Snacks.setup({
  explorer = {
    enabled = true,
  },
})

vim.keymap.set("n", "<leader>e", function()
  Snacks.explorer()
end, { desc = "Open Snacks explorer" })
