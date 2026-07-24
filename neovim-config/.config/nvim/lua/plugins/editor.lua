-- Editing / UI plugins: modern replacements for the old vim-plug set, plus the
-- lightweight tpope plugins that are still best-in-class.
return {
  -- File explorer (replaces NERDTree)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    keys = {
      { "<leader>e", "<Cmd>Neotree toggle<CR>", desc = "File explorer" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      filesystem = {
        follow_current_file = { enabled = true },
        hijack_netrw_behavior = "open_default",
      },
      window = { width = 32 },
    },
  },

  -- Symbol outline (replaces taglist)
  {
    "stevearc/aerial.nvim",
    cmd = { "AerialToggle", "AerialOpen" },
    keys = { { "<leader>o", "<Cmd>AerialToggle<CR>", desc = "Symbol outline" } },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = { backends = { "lsp", "treesitter", "markdown" } },
  },

  -- Surround (replaces vim-surround)
  { "kylechui/nvim-surround", event = "VeryLazy", version = "*", opts = {} },

  -- Indent guides (replaces vim-indent-guides)
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = { indent = { char = "│" }, scope = { enabled = true } },
  },

  -- Rainbow parentheses/brackets (treesitter-based; replaces luochen1990/rainbow)
  { "HiPhish/rainbow-delimiters.nvim", event = { "BufReadPost", "BufNewFile" } },

  -- Color-code highlighting (replaces lilydjwg/colorizer; ends the vim/nvim split)
  {
    "catgoose/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "ColorizerToggle", "ColorizerAttachToBuffer" },
    opts = {},
  },

  -- TODO/FIXME highlighting + search (replaces tasklist.vim)
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = { { "<leader>ft", "<Cmd>TodoTelescope<CR>", desc = "Todo comments" } },
    opts = {},
  },

  -- Cycle/toggle values (replaces the abandoned zef/vim-cycle; keeps the chords)
  {
    "AndrewRadev/switch.vim",
    cmd = "Switch",
    keys = {
      { "<Leader>cn", "<Cmd>Switch<CR>", desc = "Switch/cycle value" },
      { "<Leader>cp", "<Cmd>Switch<CR>", desc = "Switch/cycle value" },
      { "gs", "<Cmd>Switch<CR>", desc = "Switch/cycle value" },
    },
  },

  -- Lightweight tpope & friends (still the best at what they do)
  { "tpope/vim-repeat", event = "VeryLazy" },
  { "tpope/vim-abolish", event = "VeryLazy" },
  { "tpope/vim-unimpaired", event = "VeryLazy" },
  { "tpope/vim-characterize", event = "VeryLazy" },
  { "michaeljsmith/vim-indent-object", event = "VeryLazy" },
  {
    "tpope/vim-eunuch",
    cmd = { "Delete", "Unlink", "Move", "Rename", "Chmod", "Mkdir", "Cfind", "Clocate", "SudoWrite", "SudoEdit" },
  },
  -- Transparent editing of gpg-encrypted files (must be ready before BufReadPre)
  { "jamessan/vim-gnupg", lazy = false },
}
