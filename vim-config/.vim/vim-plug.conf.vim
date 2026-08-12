"" Lean plugin set for classic Vim (managed by vim-plug).
"" Neovim has its OWN Lua config under ~/.config/nvim -- do NOT add IDE/LSP
"" plugins here. Vim is kept light so it stays fast for quick edits and works on
"" older Vim (e.g. Ubuntu 22.04). Everything below is pure-vimscript, low-churn
"" and dependency-free.

" {{{ Editing / motions (tpope & friends)
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-characterize'
Plug 'michaeljsmith/vim-indent-object'

" Tab-triggered insert completion (pure vimscript; keeps the <Tab> muscle
" memory). 'context' makes <Tab> use omni-completion after a '.', keyword
" completion otherwise.
Plug 'ervandew/supertab'
let g:SuperTabDefaultCompletionType = "context"
let g:SuperTabContextDefaultCompletionType = "<c-n>"

" Cycle/toggle words and values (replaces the abandoned zef/vim-cycle).
Plug 'AndrewRadev/switch.vim'
" Preserve the old <Leader>cn / <Leader>cp chords. switch.vim cycles a value
" through its list; most switches are two-state, so this covers both cases.
nmap <unique> <Leader>cn :Switch<CR>
nmap <unique> <Leader>cp :Switch<CR>
" }}}

" {{{ Git
Plug 'tpope/vim-fugitive'
" }}}

" {{{ UI: statusline + colorscheme
Plug 'tpope/vim-flagship'
Plug 'gruvbox-community/gruvbox'
let g:gruvbox_italic=1
let g:gruvbox_contrast_dark="hard"
" }}}

" {{{ File explorer (loaded on demand)
Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
nnoremap <Leader>e :NERDTreeToggle<CR>
" }}}

" {{{ Sticky context header (loaded on demand)
" Pins the enclosing class/function of the top visible line, like PyCharm's
" "Sticky Lines". Indent-based rather than syntax-aware (Neovim gets the
" treesitter version instead). Kept off until asked for: it hooks cursor
" movement and scrolling, which this config exists to stay out of the way of.
" Same <Leader>uc chord as Neovim; the 'on' stub loads the plugin on first use.
Plug 'wellle/context.vim', { 'on': ['ContextEnable', 'ContextToggle', 'ContextPeek'] }
let g:context_enabled = 0
let g:context_max_height = 11
let g:context_max_per_indent = 5
nnoremap <Leader>uc :ContextToggle<CR>
" }}}

" {{{ Diff helpers
Plug 'AndrewRadev/linediff.vim', { 'on': 'Linediff' }
Plug 'will133/vim-dirdiff'
" }}}

" {{{ Filetypes & misc
" Broad syntax / ftplugin coverage for many languages (loads per-filetype):
" YAML, Terraform, Helm, Jinja, JSON, TOML, Markdown, reST, and many more.
Plug 'sheerun/vim-polyglot'
" Transparent editing of gpg-encrypted files.
Plug 'jamessan/vim-gnupg'
" }}}
