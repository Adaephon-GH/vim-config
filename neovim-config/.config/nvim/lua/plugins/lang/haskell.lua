-- Haskell (profile group: haskell). haskell-tools.nvim configures
-- haskell-language-server itself; no lspconfig entry needed. Requires: GHCup +
-- haskell-language-server on PATH.
return {
  {
    "mrcjkb/haskell-tools.nvim",
    version = "^6",
    ft = { "haskell", "lhaskell", "cabal", "cabalproject" },
    enabled = require("config.profile").has("haskell"),
  },
}
