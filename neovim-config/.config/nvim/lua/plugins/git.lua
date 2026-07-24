-- Git: inline hunks (gitsigns), commands (fugitive), rich diff UI (diffview).
return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      on_attach = function(buffer)
        local gs = require("gitsigns")
        local function m(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc })
        end
        m("n", "]c", function() gs.nav_hunk("next") end, "Next git hunk")
        m("n", "[c", function() gs.nav_hunk("prev") end, "Previous git hunk")
        m("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
        m("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
        m("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
        m("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
      end,
    },
  },

  {
    "tpope/vim-fugitive",
    cmd = { "G", "Git", "Gdiffsplit", "Gread", "Gwrite", "Gedit", "Gblame", "Glog", "GBrowse" },
    keys = { { "<leader>gs", "<Cmd>Git<CR>", desc = "Git status (fugitive)" } },
  },

  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    keys = {
      { "<leader>gd", "<Cmd>DiffviewOpen<CR>", desc = "Diffview: open" },
      { "<leader>gh", "<Cmd>DiffviewFileHistory %<CR>", desc = "Diffview: file history" },
    },
    opts = {},
  },
}
