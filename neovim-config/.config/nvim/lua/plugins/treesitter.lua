-- Treesitter: accurate highlighting, indentation, and structural text objects.
-- Replaces vim-polyglot on the Neovim side.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master", -- classic API (the `main` rewrite has a different config surface)
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSUpdate", "TSInstall", "TSInstallInfo" },
    main = "nvim-treesitter.configs",
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    opts = {
      ensure_installed = {
        "bash", "python", "javascript", "typescript", "tsx",
        "json", "jsonc", "yaml", "toml", "xml", "html", "css",
        "sql", "markdown", "markdown_inline", "rst",
        "lua", "vim", "vimdoc", "regex", "comment", "diff",
        "dockerfile", "terraform", "hcl", "helm",
        "gitcommit", "gitignore", "git_rebase",
        "rust", "haskell", "bibtex", "groovy",
      },
      -- NB: the `latex` parser is intentionally NOT installed -- it requires the
      -- tree-sitter CLI to generate, and vimtex provides better LaTeX
      -- highlighting anyway (still disabled here in case it's installed later).
      highlight = {
        enable = true,
        disable = { "latex" },
      },
      indent = { enable = true },
      incremental_selection = { enable = true },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = { ["]m"] = "@function.outer" },
          goto_previous_start = { ["[m"] = "@function.outer" },
        },
      },
    },
  },
}
