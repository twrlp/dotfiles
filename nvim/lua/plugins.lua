-- Base (portable) plugin specs: a good general editor. No LSP, completion, AI,
-- or work/diff-review plugins — those live in the machine-local overlay.
return {
  -- Colorscheme with matching dark/light flavours.
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = { background = { light = "latte", dark = "mocha" } },
  },

  -- Follow the system appearance (macOS + Linux): dark -> mocha, light -> latte.
  {
    "f-person/auto-dark-mode.nvim",
    lazy = false,
    priority = 900,
    dependencies = { "catppuccin/nvim" },
    opts = {
      update_interval = 3000,
      set_dark_mode = function()
        vim.o.background = "dark"
        pcall(vim.cmd.colorscheme, "catppuccin-mocha")
      end,
      set_light_mode = function()
        vim.o.background = "light"
        pcall(vim.cmd.colorscheme, "catppuccin-latte")
      end,
    },
  },

  -- Fuzzy finder.
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

  -- File tree.
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

  -- Git gutter signs + hunk navigation (general).
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      on_attach = function(buffer)
        local gs = require("gitsigns")
        local function map(m, k, fn, d)
          vim.keymap.set(m, k, fn, { buffer = buffer, desc = d })
        end
        map("n", "]c", function() gs.nav_hunk("next") end, "Next hunk")
        map("n", "[c", function() gs.nav_hunk("prev") end, "Prev hunk")
        map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
        map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
        map("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle line blame")
      end,
    },
  },

  -- Syntax.
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    main = "nvim-treesitter.configs",
    opts = { highlight = { enable = true }, auto_install = true },
  },
}
