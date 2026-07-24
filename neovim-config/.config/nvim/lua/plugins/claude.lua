-- Claude Code integration (official Coder plugin; pure Lua, same WebSocket/MCP
-- protocol as the VS Code / JetBrains extensions). Uses the native terminal so
-- no extra terminal dependency (snacks.nvim) is required.
return {
  {
    "coder/claudecode.nvim",
    cmd = {
      "ClaudeCode", "ClaudeCodeFocus", "ClaudeCodeSend",
      "ClaudeCodeStatus", "ClaudeCodeAdd", "ClaudeCodeDiffAccept", "ClaudeCodeDiffDeny",
    },
    keys = {
      { "<leader>a", nil, desc = "+claude" },
      { "<leader>ac", "<Cmd>ClaudeCode<CR>", desc = "Toggle Claude Code" },
      { "<leader>af", "<Cmd>ClaudeCodeFocus<CR>", desc = "Focus Claude Code" },
      { "<leader>as", "<Cmd>ClaudeCodeSend<CR>", mode = "v", desc = "Send selection to Claude" },
      { "<leader>as", "<Cmd>ClaudeCodeAdd %<CR>", desc = "Add current file to Claude" },
    },
    opts = {
      terminal = { provider = "native" },
    },
  },
}
