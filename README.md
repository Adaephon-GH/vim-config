# Vim & Neovim configuration

Two **separate** configurations that share this repo but not their code:

| Path | Editor | Role |
|------|--------|------|
| `vim-config/.vim/` | classic **Vim** | lean, instant-startup editor for quick edits; no LSP, works on older Vim (e.g. Ubuntu 22.04). Managed by `vim-plug`. |
| `neovim-config/.config/nvim/` | **Neovim** | full IDE: native LSP, `blink.cmp` completion + signature help, treesitter, telescope, git/diff, Claude Code, Coder workspaces. Managed by `lazy.nvim`. |

The folder layout mirrors `$HOME`, so both trees are meant to be symlinked/stowed
into your home directory (e.g. with GNU stow).

Both editors share a few chords on purpose, e.g. `<leader>uc` toggles a sticky
context header (the enclosing class/function of the top visible line, like
PyCharm's "Sticky Lines"). In Neovim it is treesitter-based and on by default; in
Vim it is indent-based and stays unloaded until you ask for it, so startup is
unaffected.

## Neovim layout

```
neovim-config/.config/nvim/
  init.lua
  lua/config/    options, keymaps, autocmds, profile, lazy bootstrap
  lua/plugins/   plugin specs (one file per concern)
  lua/plugins/lang/  per-language specs, enabled per host profile
  lua/util/      standalone helper modules used by plugin specs (e.g. custom colorizer parser)
```

### Per-host profiles

Heavy/situational language groups (Rust, Haskell, LaTeX, Odoo, Terraform) are
toggled per machine so plugins/servers you don't need aren't installed. Core
languages (Python, shell, JS, YAML/k8s/Helm, JSON, XML, Markdown/reST, SQL) are
always on.

- Pick a profile with `export NVIM_PROFILE=home|work|coder` (or map a hostname in
  `lua/config/profile.lua`). Default is `home`.
- Override per machine in `lua/config/local.lua` (git-ignored) — copy
  `lua/config/local.lua.example`.

### External tools

Note: Neovim has no built-in Helm filetype (on the Vim side this comes from
vim-polyglot). `helm-ls.nvim` supplies the detection, gated on a `Chart.yaml`
being present, which is what lets `helm_ls` attach and keeps `yamlls` off chart
templates.

`:Mason` installs the language servers, but they need the matching runtime
present (Node ≥ 18, Python 3, a JRE for the XML server, a C compiler for
treesitter, plus rustup / GHCup / TeX Live for the Rust / Haskell / LaTeX
groups). Missing a tool degrades gracefully — the file still opens with
treesitter highlighting, just without that server's IDE features.

### Remote development (Coder)

Handled by the `coder-nvim` script in `neovim-config/.config/nvim/bin/`, not by a plugin
(remote-nvim.nvim was archived upstream). It keeps a **headless Neovim running on
the workspace** that survives disconnects, ships your local Neovim AppImage there
so both ends are the same build, syncs this config, and attaches a UI to it.
Its workspace half, `bin/coder-nvim-remote`, is part of this config, so the sync
itself delivers it — a fresh workspace needs no preparation.

1. `coder config-ssh` to add the workspace SSH hosts to `~/.ssh/config`.
2. From a terminal: `coder-nvim <workspace>` (no argument prompts you to pick
   one). `coder-nvim -w <workspace>` opens it in a new kitty window instead.
3. From inside a running Neovim: `:CoderStart` (`<leader>rs`) hands this UI over
   to the workspace; `:CoderBack` returns to the local session.

The remote server runs with `NVIM_PROFILE=work`. `coder-nvim --status <ws>` reports
whether it is running and whether the workspace's copy of this config matches the
local one; `coder-nvim --stop <ws>` stops it.

The config is pushed automatically whenever it has changed. A *running* workspace
server reads its config only at startup, though, so edits reach an open session
only after `coder-nvim --restart <ws>` (which discards unsaved buffers there).
`coder-nvim --sync <ws>` pushes without restarting.

## First run

- **Neovim:** launch `nvim`; lazy.nvim bootstraps itself and installs plugins.
  **Open a file of your language** (e.g. a `.py`) — this loads the LSP layer, and
  Mason then **auto-installs** the servers for your profile in the background
  (`ensure_installed`). IDE features (go-to-definition, completion, hover) light
  up once the relevant server finishes installing. Watch progress with `:MasonLog`.
  `:Mason` opens the installer UI at any time (also `<leader>M`) — it no longer
  requires a file to be open.
- **Vim:** launch `vim`; run `:PlugInstall`.
