-- Colorscheme: gruvbox (treesitter-aware Lua port of the community theme).
return {
  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 1000, -- load before other plugins so colors apply immediately
    opts = {
      contrast = "hard",
      bold = true,
      italic = { strings = false, comments = true, folds = true, operators = false },
    },
    config = function(_, opts)
      require("gruvbox").setup(opts)
      vim.o.background = "dark"
      vim.cmd.colorscheme("gruvbox")
    end,
  },
}
