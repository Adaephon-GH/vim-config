"" general plugins
" extended features
Plug 'xolox/vim-misc' | Plug 'xolox/vim-colorscheme-switcher'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-speeddating'
"Plug 'AndrewRadev/switch.vim'
Plug 'zef/vim-cycle'
let g:cycle_no_mappings=1
nmap <unique> <Leader>cn <Plug>CycleNext
nmap <unique> <Leader>cp <Plug>CyclePrevious

Plug 'tpope/vim-abolish'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-flagship'
Plug 'ervandew/supertab'

" color schemes
Plug 'morhetz/gruvbox'
let g:gruvbox_italic=1
let g:gruvbox_contrast_dark="hard"
Plug 'sjl/badwolf'
Plug 'tomasr/molokai'
Plug 'Lokaltog/vim-distinguished', { 'branch': 'develop' }
Plug 'vim-scripts/xoria256.vim'
Plug 'gotchacode/vim-tomorrow-theme'
Plug 'w0ng/vim-hybrid'
Plug 'alem0lars/vim-colorscheme-darcula'


" development
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
" replace it with commentary?
"Plug 'scrooloose/nerdcommenter'
Plug 'wesleyche/SrcExpl'
Plug 'vim-scripts/taglist.vim'
Plug 'vim-scripts/tasklist.vim'

Plug 'nathanaelkane/vim-indent-guides'
Plug 'luochen1990/rainbow'
Plug 'lilydjwg/colorizer'
let g:colorizer_startup = 0


" diff
Plug 'AndrewRadev/linediff.vim', { 'on': 'Linediff' }
Plug 'will133/vim-dirdiff'

"" File type specific
" bash
Plug 'vim-scripts/bash-support.vim'
" gnupg
Plug 'jamessan/vim-gnupg'
" perl
Plug 'vim-scripts/perl-support.vim', { 'for': 'perl' }
" python (http://unlogic.co.uk/2013/02/08/vim-as-a-python-ide/)
Plug 'klen/python-mode', { 'for': 'python' }
"Plug 'davidhalter/jedi-vim'
" Salt Stack
Plug 'saltstack/salt-vim', { 'for': 'sls' }
Plug 'Glench/Vim-Jinja2-Syntax', { 'for': ['sls', 'jinja'] }
" i3
Plug 'PotatoesMaster/i3-vim-syntax'
