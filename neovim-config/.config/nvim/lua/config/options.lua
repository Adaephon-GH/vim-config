-- Editor options. Ported from the old ~/.vim/vimrc, keeping only what deviates
-- from Neovim's (already sensible) defaults, plus a few IDE-friendly additions.

-- Leader must be set before lazy.nvim / any plugin keymaps are defined.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Use the system python3 for the provider so it keeps working inside venvs.
vim.g.python3_host_prog = "/usr/bin/python3"

-- Providers we don't use -- disabling them speeds startup and silences health.
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

local opt = vim.opt

-- Line numbers (hybrid: absolute current line + relative others)
opt.number = true
opt.relativenumber = true
opt.cursorline = true

-- Whitespace visualisation (trailing handled in autocmds.lua)
opt.list = true
opt.listchars = { tab = "»·", precedes = "«", extends = "»", eol = "¬", nbsp = "␣", trail = "␣" }
opt.showbreak = "«···"

-- Scrolling / splits
opt.scrolloff = 5
opt.sidescroll = 1
opt.sidescrolloff = 15
opt.splitright = true
opt.splitbelow = true

opt.mouse = "a"
opt.termguicolors = true
opt.signcolumn = "yes" -- reserve space so diagnostics/git signs don't jitter text
opt.updatetime = 250   -- snappier CursorHold (diagnostics, git blame)
opt.undofile = true    -- persistent undo

-- Search: case-insensitive unless the pattern contains an uppercase letter
opt.ignorecase = true
opt.smartcase = true

-- Indentation (4-space soft tabs; per-filetype overrides in autocmds.lua)
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true
opt.smarttab = true

-- Completion: blink.cmp drives the menu; these keep native completion sane too.
opt.completeopt = { "menuone", "noselect" }

-- Folding off by default (open files unfolded, as before)
opt.foldenable = false

opt.nrformats:remove("octal")

-- Spell languages (spell is switched on per prose filetype in autocmds.lua).
-- Neovim auto-downloads the German spellfile on first use.
opt.spelllang = { "en_us", "de_de" }

-- Better diffs: internal diff library + histogram algorithm, and linematch to
-- align changed regions -- fixes the "diff isn't the minimal change set" issue.
opt.diffopt:append({ "internal", "algorithm:histogram", "linematch:60" })
