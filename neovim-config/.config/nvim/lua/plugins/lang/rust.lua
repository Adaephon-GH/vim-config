-- Rust (profile group: rust). rustaceanvim configures rust-analyzer itself
-- (uses the rustup component); no lspconfig entry needed. Requires: rustup +
-- `rustup component add rust-analyzer`.
return {
  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    ft = "rust",
    enabled = require("config.profile").has("rust"),
  },
}
