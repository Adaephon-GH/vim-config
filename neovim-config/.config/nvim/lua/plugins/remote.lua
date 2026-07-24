-- Remote development (Coder workspaces and any SSH host). remote-nvim.nvim
-- installs a headless Neovim + this config on the remote and drives it from the
-- local UI over SSH. Populate SSH hosts first with `coder config-ssh`, then run
-- :RemoteStart and pick the workspace host.
return {
  {
    "amitds1997/remote-nvim.nvim",
    cmd = { "RemoteStart", "RemoteInfo", "RemoteCleanup", "RemoteConfigDel", "RemoteLog" },
    keys = { { "<leader>rs", "<Cmd>RemoteStart<CR>", desc = "Remote: start/connect" } },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {},
  },
}
