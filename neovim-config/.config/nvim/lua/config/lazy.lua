-- Bootstrap lazy.nvim and load all plugin specs.

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins" },      -- lua/plugins/*.lua
    { import = "plugins.lang" }, -- lua/plugins/lang/*.lua (profile-gated)
  },
  defaults = { lazy = true }, -- everything lazy-loads unless a spec opts out
  install = { colorscheme = { "gruvbox", "habamax" } },
  checker = { enabled = true, notify = false }, -- check for updates quietly
  change_detection = { notify = false },
  performance = {
    rtp = {
      -- Built-in plugins we don't need; keeps startup lean for quick edits.
      -- gzip/tarPlugin/zipPlugin stay enabled: they provide archive browsing
      -- (~0.5 ms of startup), see the archive_readonly autocmd in autocmds.lua.
      disabled_plugins = { "tohtml", "tutor" },
    },
  },
})

-- :Lazy update / :Lazy sync to manage plugins.
vim.keymap.set("n", "<leader>L", "<Cmd>Lazy<CR>", { desc = "Lazy plugin manager" })
