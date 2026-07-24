-- LaTeX (profile group: latex). vimtex handles compilation/preview and provides
-- more accurate syntax highlighting than treesitter (treesitter `latex` highlight
-- is disabled in treesitter.lua). The texlab LSP is enabled in lsp.lua when the
-- latex group is active. Requires: TeX Live + latexmk + a PDF viewer (zathura).
return {
  {
    "lervag/vimtex",
    ft = { "tex", "latex", "bib" },
    enabled = require("config.profile").has("latex"),
    init = function()
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_mappings_prefix = "<localleader>l"
      vim.g.vimtex_quickfix_mode = 0
    end,
  },
}
