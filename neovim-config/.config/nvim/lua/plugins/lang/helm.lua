-- Helm charts. Neovim has no built-in Helm filetype, and treesitter only
-- supplies highlighting *per filetype* -- it never did the detection. Without
-- this, chart templates stayed `yaml`: the Go templating went unhighlighted,
-- yamlls flagged `{{ ... }}` as invalid YAML, and helm_ls (see plugins/lsp.lua)
-- could never attach, since lspconfig scopes it to the `helm` and
-- `yaml.helm-values` filetypes. On the Vim side this comes from vim-polyglot,
-- which bundles towolf/vim-helm.
--
-- Detection lives in the plugin's ftdetect/, which lazy.nvim sources eagerly for
-- `ft`-gated plugins -- so the plugin still loads on demand, no startup cost.
-- Highlighting comes from the `helm` treesitter parser (plugins/treesitter.lua),
-- whose queries inject yaml into the template body.
--
-- Not profile-gated: Kubernetes/Helm is a core language on every host.
return {
  {
    "qvalentin/helm-ls.nvim",
    ft = { "helm", "yaml.helm-values" },
    -- The plugin's ftdetect matches on path alone (`*/templates/*.yaml`,
    -- `values*.yaml`) -- its Chart.yaml check is commented out upstream, and
    -- vim-polyglot has the same blind spot on the Vim side. So any unrelated
    -- `templates/` dir or stray `values.yaml` would be claimed as Helm and lose
    -- yamlls' schema validation. Demote back to yaml when there is no chart
    -- above the file. Registered in `init` so it is in place before the first
    -- file is opened -- doing it in `config` would be too late, since loading
    -- this plugin is itself triggered by the filetype being set.
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("config_helm_guard", { clear = true }),
        -- Matched explicitly rather than via `pattern`: the values filetype is
        -- the compound `yaml.helm-values`, which FileType patterns don't match.
        pattern = "*",
        callback = function(ev)
          local ft = vim.bo[ev.buf].filetype
          if ft ~= "helm" and ft ~= "yaml.helm-values" then
            return
          end
          local name = vim.api.nvim_buf_get_name(ev.buf)
          if name == "" then
            return
          end
          local found = vim.fs.find("Chart.yaml", { upward = true, path = vim.fs.dirname(name) })
          if not found[1] then
            vim.bo[ev.buf].filetype = "yaml"
          end
        end,
      })
    end,
    config = function()
      local ok, helm_ls = pcall(require, "helm-ls")
      if ok and type(helm_ls) == "table" and type(helm_ls.setup) == "function" then
        helm_ls.setup({
          -- Replaces `{{ ... }}` with the resolved value as virtual text. Off:
          -- it hides the template you came to edit and needs conceallevel=2.
          conceal_templates = { enabled = false },
          -- Shows what `indent`/`nindent` actually do to the current line.
          indent_hints = { enabled = true, only_for_current_line = true },
          action_highlight = { enabled = true },
        })
      else
        vim.notify(
          "helm-ls.nvim loaded but no setup() found -- check the plugin's README for its API.",
          vim.log.levels.WARN
        )
      end
    end,
  },
}
