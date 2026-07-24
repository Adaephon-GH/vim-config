-- Odoo (profile group: odoo). Client for the official odoo-ls language server,
-- giving Odoo-aware go-to-definition/hover/diagnostics across Python/XML/JS.
--
-- NOTE: odoo-ls is BETA and may be unstable. It needs:
--   * the odoo-ls server binary on PATH (see github.com/odoo/odoo-ls), and
--   * an `odools.toml` in each project root (addons path, python path, stubs).
-- Basic Python/XML editing still works via basedpyright + lemminx if odoo-ls is
-- unavailable. Setup is wrapped in pcall so a missing/renamed module can't break
-- startup on the work profile.
return {
  {
    "Whenrow/odoo-ls.nvim",
    enabled = require("config.profile").has("odoo"),
    ft = { "python", "xml" },
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      local ok, odoo = pcall(require, "odoo-ls")
      if ok and type(odoo) == "table" and type(odoo.setup) == "function" then
        odoo.setup({})
      else
        vim.notify(
          "odoo-ls.nvim loaded but no setup() found -- check the plugin's README for its API.",
          vim.log.levels.WARN
        )
      end
    end,
  },
}
