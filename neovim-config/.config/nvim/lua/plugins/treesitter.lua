-- Treesitter: accurate highlighting, indentation, and structural text objects.
-- Replaces vim-polyglot on the Neovim side.

-- Text objects, mapped by hand. The plugin is pinned to its `main` branch (see
-- lazy-lock.json), which no longer plugs into nvim-treesitter `master`'s module
-- system -- configuring it through `nvim-treesitter.configs` silently mapped
-- nothing. Same chords as before, now declared where lazy.nvim can lazy-load on
-- them.
local textobjects = {
  { lhs = "af", query = "@function.outer", desc = "a function" },
  { lhs = "if", query = "@function.inner", desc = "inner function" },
  { lhs = "ac", query = "@class.outer", desc = "a class" },
  { lhs = "ic", query = "@class.inner", desc = "inner class" },
  { lhs = "aa", query = "@parameter.outer", desc = "an argument" },
  { lhs = "ia", query = "@parameter.inner", desc = "inner argument" },
}

local function textobject_keys()
  local keys = {}
  for _, obj in ipairs(textobjects) do
    keys[#keys + 1] = {
      obj.lhs,
      function()
        require("nvim-treesitter-textobjects.select").select_textobject(obj.query, "textobjects")
      end,
      mode = { "x", "o" },
      desc = obj.desc,
    }
  end
  keys[#keys + 1] = {
    "]m",
    function()
      require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
    end,
    mode = { "n", "x", "o" },
    desc = "Next function start",
  }
  keys[#keys + 1] = {
    "[m",
    function()
      require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
    end,
    mode = { "n", "x", "o" },
    desc = "Previous function start",
  }
  return keys
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- Classic API. The `main` rewrite has a different config surface *and*
    -- builds every parser through the tree-sitter CLI (>= 0.26.1), whose
    -- released Linux binaries need glibc 2.39 -- more than Ubuntu 22.04 has.
    -- `master` is frozen at "Neovim 0.10 or 0.11", so on 0.12 its query
    -- handlers need util.ts_query_compat below; move to `main` once this host
    -- runs an OS that can supply the CLI.
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSUpdate", "TSInstall", "TSInstallInfo" },
    main = "nvim-treesitter.configs",
    -- In `init`, so the compatibility wrapper is in place before the plugin
    -- registers its query predicates.
    init = function()
      require("util.ts_query_compat").setup()
    end,
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
      -- No incremental_selection: its default chords sit on `grn`, which is
      -- Neovim's built-in LSP rename since 0.11.
    },
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    main = "nvim-treesitter-textobjects",
    keys = textobject_keys(),
    opts = {
      -- Jump forward to the next match when the cursor is outside any of them.
      select = { lookahead = true },
      move = { set_jumps = true },
    },
  },
}
