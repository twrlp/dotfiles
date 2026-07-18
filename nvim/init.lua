-- Portable base config: general editor settings + a few quality plugins.
-- Standalone: on a personal machine, symlink ~/.config/nvim -> ~/.dot/nvim.
-- On a machine that also wants a work layer, ~/.config/nvim is its own dir that
-- reuses this repo's opts.lua + plugins.lua and appends local plugins.
require("opts")

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup(require("plugins"))
