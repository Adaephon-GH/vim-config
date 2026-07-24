-- Neovim IDE configuration.
--
-- This is a STANDALONE Lua config -- it no longer sources ~/.vim/vimrc. Classic
-- Vim keeps its own lean vimscript config; Neovim is the full IDE (LSP,
-- completion, treesitter, telescope, Claude Code, remote dev).
--
-- Layout:
--   lua/config/options.lua   editor options (also sets <leader>, before lazy)
--   lua/config/keymaps.lua   general, non-plugin keymaps
--   lua/config/autocmds.lua  autocommands (spell, yank-highlight, ...)
--   lua/config/profile.lua   host profile -> enabled language groups
--   lua/config/lazy.lua      bootstraps lazy.nvim and imports lua/plugins/*
--   lua/plugins/*.lua        plugin specs (one file per concern)
--   lua/plugins/lang/*.lua   per-language specs, gated by the host profile
--
-- Machine-specific overrides live in lua/config/local.lua (git-ignored); see
-- lua/config/local.lua.example.

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
