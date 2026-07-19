-- Options

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
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

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
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

if vim.fn.has("win32") ~= 1 and vim.fn.has("wsl") ~= 1 then
	vim.opt.clipboard = "unnamedplus"
end

-- Plugins
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		opts = { background = { light = "latte", dark = "mocha" } },
	},
	{
		"mofiqul/dracula.nvim",
		name = "dracula",
		lazy = false,
		priority = 1000,
	},
	{
		"f-person/auto-dark-mode.nvim",
		lazy = false,
		priority = 900,
		dependencies = { "catppuccin/nvim", "mofiqul/dracula.nvim" },
		opts = {
			update_interval = 3000,
			set_dark_mode = function()
				vim.o.background = "dark"
				pcall(vim.cmd.colorscheme, "dracula")
			end,
			set_light_mode = function()
				vim.o.background = "light"
				pcall(vim.cmd.colorscheme, "catppuccin-latte")
			end,
		},
	},
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		cmd = "Telescope",
		keys = {
			{ "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
			{ "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Live grep" },
			{ "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
			{ "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help tags" },
		},
	},
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			{ "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "File tree" },
			{ "<leader>o", "<cmd>NvimTreeFindFile<CR>", desc = "Find in tree" },
		},
		opts = {
			view = { width = 36 },
			renderer = { highlight_git = true, icons = { show = { git = true } } },
			git = { enable = true },
			filters = { dotfiles = false },
		},
	},
	{
		"neovim/nvim-lspconfig",
		lazy = false,
	},
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				-- Customize or remove this keymap to your liking
				"<leader>f",
				function()
					require("conform").format({ async = true })
				end,
				mode = "",
				desc = "Format buffer",
			},
		},
		-- This will provide type hinting with LuaLS
		---@module "conform"
		---@type conform.setupOpts
		opts = {
			-- Define your formatters
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "ruff_format" },
			},
			-- Set default options
			default_format_opts = {
				lsp_format = "fallback",
			},
			-- Set up format-on-save
			format_on_save = { timeout_ms = 500, lsp_fallback = true },
			-- Customize formatters
			formatters = {
				shfmt = {
					append_args = { "-i", "2" },
				},
			},
		},
	},
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {},
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {},
	},
})

-- LSP
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
		},
	},
})

vim.lsp.config("basedpyright", {
	settings = {
		basedpyright = {
			disableOrganizeImports = true,
		},
	},
})

vim.lsp.enable({ "lua_ls", "basedpyright", "ruff" })

vim.opt.completeopt = { "menuone", "noselect", "popup" }

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client and client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
		end
	end,
})
