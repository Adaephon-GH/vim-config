-- Autocommands.

local function augroup(name)
  return vim.api.nvim_create_augroup("config_" .. name, { clear = true })
end

-- Briefly highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("yank_highlight"),
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})

-- Spell checking on prose filetypes (English + German set in options.lua)
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("prose_spell"),
  pattern = { "markdown", "rst", "text", "gitcommit", "mail", "tex" },
  callback = function()
    vim.opt_local.spell = true
  end,
})

-- Filetype-specific indentation overrides (ported from vimrc)
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("indent_overrides"),
  pattern = { "make" },
  callback = function()
    vim.opt_local.expandtab = false
  end,
})

-- Hide the trailing-space listchar while typing, show it otherwise
local trail_grp = augroup("trailing")
vim.api.nvim_create_autocmd("InsertEnter", {
  group = trail_grp,
  callback = function() vim.opt_local.listchars:remove("trail") end,
})
vim.api.nvim_create_autocmd("InsertLeave", {
  group = trail_grp,
  callback = function() vim.opt_local.listchars:append({ trail = "␣" }) end,
})

-- Treat files in ~/.Xresources.d as xdefaults (ported from vimrc)
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup("xresources"),
  pattern = { "*/.Xresources.d/*" },
  callback = function() vim.bo.filetype = "xdefaults" end,
})

-- Close throwaway/utility buffers with q
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = { "help", "qf", "man", "lspinfo", "checkhealth", "notify" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<Cmd>close<CR>", { buffer = event.buf, silent = true })
  end,
})

-- Members of a *compressed* tarball cannot be written back (tar.vim can only
-- update an uncompressed .tar). Say so up front instead of erroring at :w.
vim.api.nvim_create_autocmd("BufFilePost", {
  group = augroup("archive_readonly"),
  pattern = "tarfile::*",
  callback = function(event)
    local src = vim.b[event.buf].tarfile
    local archive = src and src:match("^tarfile:(.-)::")
    if archive and not archive:lower():match("%.tar$") then
      vim.bo[event.buf].modifiable = false
      vim.bo[event.buf].readonly = true
    end
  end,
})
