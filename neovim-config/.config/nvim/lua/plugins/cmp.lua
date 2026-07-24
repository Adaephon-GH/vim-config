-- Completion + signature help (blink.cmp). Replaces supertab + omnicomplete.
return {
  {
    "saghen/blink.cmp",
    version = "1.*", -- uses prebuilt fuzzy binary; no cargo needed
    event = { "InsertEnter", "CmdlineEnter" },
    opts = {
      -- <Tab>/<S-Tab> to accept/expand and navigate -- preserves the supertab
      -- muscle memory natively.
      keymap = { preset = "super-tab" },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        menu = { border = "rounded" },
        ghost_text = { enabled = true },
      },
      signature = { enabled = true, window = { border = "rounded" } },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
  },
}
