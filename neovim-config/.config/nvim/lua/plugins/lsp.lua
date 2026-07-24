-- LSP: mason installs servers, nvim-lspconfig/vim.lsp.config wires them up.
-- Core languages are always enabled; latex/terraform servers are profile-gated.
-- Rust and Haskell are handled by dedicated plugins in lua/plugins/lang/.
return {
  -- Mason as its own spec so `:Mason` and friends are available on demand
  -- (even before any file is opened). It is also a dependency of nvim-lspconfig
  -- below, so it is set up before the servers are wired up.
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUninstallAll", "MasonLog", "MasonUpdate" },
    keys = { { "<leader>M", "<Cmd>Mason<CR>", desc = "Mason (LSP/tool installer)" } },
    opts = {},
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      local profile = require("config.profile")

      -- server name (as known to lspconfig) -> per-server settings
      local servers = {
        basedpyright = {},
        ruff = {},
        bashls = {},
        vtsls = {},
        eslint = {},
        jsonls = {},
        yamlls = {
          settings = {
            yaml = {
              keyOrdering = false,
              schemaStore = { enable = true, url = "https://www.schemastore.org/api/json/catalog.json" },
            },
          },
        },
        helm_ls = {},
        lemminx = {},
        taplo = {},
        marksman = {},
        esbonio = {},
        sqls = {},
      }
      if profile.has("latex") then servers.texlab = {} end
      if profile.has("terraform") then servers.terraformls = {} end

      -- Advertise blink.cmp's completion capabilities to every server.
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      vim.lsp.config("*", { capabilities = capabilities })

      for name, cfg in pairs(servers) do
        vim.lsp.config(name, cfg)
      end

      -- mason itself is set up by its own spec (opts = {}) before this runs.
      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(servers),
        automatic_enable = true,
      })

      -- Diagnostics presentation
      vim.diagnostic.config({
        virtual_text = true,
        severity_sort = true,
        float = { border = "rounded", source = true },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "E",
            [vim.diagnostic.severity.WARN] = "W",
            [vim.diagnostic.severity.INFO] = "I",
            [vim.diagnostic.severity.HINT] = "H",
          },
        },
      })

      -- Buffer-local, vim-idiomatic keymaps once a server attaches.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("config_lsp_attach", { clear = true }),
        callback = function(ev)
          local function m(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = "LSP: " .. desc })
          end
          m("gd", vim.lsp.buf.definition, "Go to definition")
          m("gD", vim.lsp.buf.declaration, "Go to declaration")
          m("gi", vim.lsp.buf.implementation, "Go to implementation")
          m("gy", vim.lsp.buf.type_definition, "Go to type definition")
          m("gr", vim.lsp.buf.references, "References")
          m("K", vim.lsp.buf.hover, "Hover documentation")
          m("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          m("<leader>ca", vim.lsp.buf.code_action, "Code action")
          m("<leader>cf", function() vim.lsp.buf.format({ async = true }) end, "Format buffer")
          vim.keymap.set({ "i", "n" }, "<C-s>", vim.lsp.buf.signature_help,
            { buffer = ev.buf, desc = "LSP: Signature help" })
        end,
      })
    end,
  },
}
