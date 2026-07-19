-- General editor settings + keymaps (portable; used by base and by the local
-- overlay). No plugins, no work/LSP config here.

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 400
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.termguicolors = true

-- Indentation / display (ported from vim/vimrc)
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.copyindent = true
vim.opt.textwidth = 120
vim.opt.wrap = true
vim.opt.scrolloff = 3
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.showmatch = true

vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")
-- (Day/night colorscheme switching is handled by auto-dark-mode.nvim in plugins.lua.)
