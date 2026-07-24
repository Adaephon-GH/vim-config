-- General, non-plugin keymaps. Plugin-specific maps live in their plugin specs;
-- buffer-local LSP maps are set on LspAttach in lua/plugins/lsp.lua.

local map = vim.keymap.set

-- Clear search highlight + redraw + refresh diffs (ported <C-L> behaviour)
map("n", "<C-l>", "<Cmd>nohlsearch<Bar>diffupdate<CR><C-l>", { desc = "Clear search highlight" })

-- Muscle-memory maps carried over from the old vimrc
map("n", "<F4>", "<Cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
map("n", "<F3>", "@:", { desc = "Repeat last : command" })

-- Diagnostics under the cursor (:Inspect replaces the old SynGroup() function)
map("n", "<F12>", "<Cmd>Inspect<CR>", { desc = "Inspect highlight/treesitter under cursor" })

-- Q formats (don't drop into Ex mode), as before
map({ "n", "x" }, "Q", "gq", { desc = "Format" })

-- Diagnostics navigation and view
map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Previous diagnostic" })
map("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Next diagnostic" })
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Line diagnostics" })

-- Terminal: leave insert mode with <Esc><Esc>
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
