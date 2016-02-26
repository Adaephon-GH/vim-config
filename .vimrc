scriptencoding utf-8
" ^^ Please leave the above line at the start of the file.
" vim: set fenc=utf-8 tw=80 sw=2 sts=2 et foldmethod=marker :
" Default configuration file for Vim
" $Header: /var/cvsroot/gentoo-x86/app-editors/vim-core/files/vimrc-r3,v 1.1 2006/03/25 20:26:27 genstef Exp $

" Written by Aron Griffis <agriffis@gentoo.org>
" Modified by Ryan Phillips <rphillips@gentoo.org>
" Modified some more by Ciaran McCreesh <ciaranm@gentoo.org>
" Added Redhat's vimrc info by Seemant Kulleen <seemant@gentoo.org>

" Startup Profiler
"let g:startup_profile_csv = "/tmp/vim_startup.csv" 
"runtime macros/startup_profile.vim


" {{{ General settings
" The following are some sensible defaults for Vim for most users.
" We attempt to change as little as possible from Vim's defaults,
" deviating only where it makes sense
set nocompatible        " Use Vim defaults (much better!)
set bs=2                " Allow backspacing over everything in insert mode
set ai                  " Always set auto-indenting on
set history=500         " keep 50 lines of command history
set ruler               " Show the cursor position all the time
set incsearch
set laststatus=2
set tabpagemax=50

set viminfo='20,\"500   " Keep a .viminfo file.

language messages C

" Don't use Ex mode, use Q for formatting
map Q gq

" When doing tab completion, give the following files lower priority. You may
" wish to set 'wildignore' to completely ignore files, and 'wildmenu' to enable
" enhanced tab completion. These can be done in the user vimrc file.
set suffixes+=.info,.aux,.log,.dvi,.bbl,.out,.o,.lo

" When displaying line numbers, don't use an annoyingly wide number column. This
" doesn't enable line numbers -- :set number will do that. The value given is a
" minimum width to use for the number column, not a fixed size.
if v:version >= 700
  set numberwidth=3
endif

let mapleader=","
" }}}

" {{{ Unicode settings
" If we have a BOM, always honour that rather than trying to guess.
if &fileencodings !~? "ucs-bom"
  set fileencodings^=ucs-bom
endif

" Always check for UTF-8 when trying to determine encodings.
if &fileencodings !~? "utf-8"
  set fileencodings+=utf-8
endif

" Make sure we have a sane fallback for encoding detection
set fileencodings+=default
" }}}

" {{{ Syntax highlighting settings
" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif
if maparg('<C-L>', 'n') ==# ''
  nnoremap <silent> <C-L> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>
endif
" }}}

" {{{ Terminal fixes
if &term ==? "xterm"
  set t_Sb=^[4%dm
  set t_Sf=^[3%dm
  set ttymouse=xterm2
  set mouse=a
endif

if &term ==? "gnome" && has("eval")
  " Set useful keys that vim doesn't discover via termcap but are in the
  " builtin xterm termcap. See bug #122562. We use exec to avoid having to
  " include raw escapes in the file.
  exec "set <C-Left>=\eO5D"
  exec "set <C-Right>=\eO5C"
endif
" }}}

" {{{ Filetype plugin settings
" Enable plugin-provided filetype settings, but only if the ftplugin
" directory exists (which it won't on livecds, for example).
if isdirectory(expand("$VIMRUNTIME/ftplugin"))
  filetype plugin on

  " Uncomment the next line (or copy to your ~/.vimrc) for plugin-provided
  " indent settings. Some people don't like these, so we won't turn them on by
  " default.
  filetype indent on
endif
" }}}

" {{{ Fix &shell, see bug #101665.
if "" == &shell
  if executable("/bin/zsh")
    set shell=/bin/zsh
  elseif executable("/bin/bash")
    set shell=/bin/bash
  elseif executable("/bin/sh")
    set shell=/bin/sh
  endif
endif
"}}}

" {{{ Our default /bin/sh is bash, not ksh, so syntax highlighting for .sh
" files should default to bash. See :help sh-syntax and bug #101819.
if has("eval")
  let is_bash=1
endif
" }}}


set modeline
set modelines=5

"" Format of display 
"if has("gui_running")
"  colorscheme Dark4t
"else
"  colorscheme elflord
"endif
colorscheme Dark6
set number
set listchars=tab:»·,precedes:«,extends:»,eol:· ",trail:·
set list
set showbreak=«···
set showcmd
set cursorline

set wrap
set scrolloff=5
set sidescroll=1
set sidescrolloff=15
set splitright
set splitbelow
 " Better autocompletion
set wildmode=list:longest,full
set wildmenu

set completeopt=menuone,preview
"autocmd CursorMovedI * if pumvisible() == 0|pclose|endif 
autocmd InsertLeave * if pumvisible() == 0|pclose|endif

" Functions
function! Mosh_Tab_Or_Complete()
  if col('.')>1 && strpart( getline('.'), col('.')-2, 3 ) =~ '^\w'
    return "\<C-N>"
  else
    return "\<Tab>"
  endif
endfunction


" Commands
command Pc !perl -c %

" Keymaps
imap <F2> <Esc>:w<CR>a
nmap <F2> :w<CR>
nmap <C-F2> :wa<CR>
nmap <F4> :noh<CR>
nmap <F3> @:
inoremap <Tab> <C-R>=Mosh_Tab_Or_Complete()<CR>
inoremap <C-Space> <C-X><C-O>

"" Now handled by tpope/vim-unimpaired
"nmap ]l :lnext<CR>
"nmap [l :lprevious<CR>
"nmap ]q :cnext<CR>
"nmap [q :cprevious<CR>

" Format of text and source code
set smartindent
set smarttab
set shiftwidth=4
set expandtab
set tabstop=4
set softtabstop=4
au FileType make setlocal noexpandtab
au FileType python setlocal ts=4 sw=4
au FileType python,perl,bash setlocal cino=#1 commentstring=\ ##%s

set nrformats-=octal
set formatoptions+=j

" Transparent editing of gpg encrypted files.
" By Wouter Hanegraaff <wouter@blub.net>
"augroup encrypted
"    au!

"    " First make sure nothing is written to ~/.viminfo while editing
"    " an encrypted file.
"    autocmd BufReadPre,FileReadPre      *.gpg set viminfo=
"    " We don't want a swap file, as it writes unencrypted data to disk
"    autocmd BufReadPre,FileReadPre      *.gpg set noswapfile
"    " Switch to binary mode to read the encrypted file
"    autocmd BufReadPre,FileReadPre      *.gpg set bin
"    autocmd BufReadPre,FileReadPre      *.gpg let ch_save = &ch|set ch=2
"    autocmd BufReadPre,FileReadPre      *.gpg let shsave=&sh
"    autocmd BufReadPre,FileReadPre      *.gpg let &sh='sh'
"    autocmd BufReadPre,FileReadPre      *.gpg let ch_save = &ch|set ch=2
"    autocmd BufReadPost,FileReadPost    *.gpg '[,']!gpg --decrypt --default-recipient-self 2> /dev/null
"    autocmd BufReadPost,FileReadPost    *.gpg let &sh=shsave

"    " Switch to normal mode for editing
"    autocmd BufReadPost,FileReadPost    *.gpg set nobin
"    autocmd BufReadPost,FileReadPost    *.gpg let &ch = ch_save|unlet ch_save
"    autocmd BufReadPost,FileReadPost    *.gpg execute ":doautocmd BufReadPost " . expand("%:r")

"    " Convert all text to encrypted text before writing
"    autocmd BufWritePre,FileWritePre    *.gpg set bin
"    autocmd BufWritePre,FileWritePre    *.gpg let shsave=&sh
"    autocmd BufWritePre,FileWritePre    *.gpg let &sh='sh'
"    autocmd BufWritePre,FileWritePre    *.gpg '[,']!gpg --armor --encrypt --default-recipient-self 2>/dev/null
"    autocmd BufWritePre,FileWritePre    *.gpg let &sh=shsave

"    " Undo the encryption so we are back in the normal text, directly
"    " after the file has been written.
"    autocmd BufWritePost,FileWritePost  *.gpg   silent u
"    autocmd BufWritePost,FileWritePost  *.gpg set nobin
"augroup END

augroup itsalltext
    autocmd!

    " Set textwidth=0 for text files edited with the itsalltext firefox-
    " plugin because automatik linebreaks tend to complicate editing
    " sometimes, for example wiki-entries
    autocmd BufNewFile,BufRead ~/.mozilla/firefox/*/itsalltext/*.txt set tw=0
augroup END

" Treat files in ~/.Xresources.d as xdefaults
autocmd BufRead,BufNewFile ~/.Xresources.d/* set filetype=xdefaults

if filereadable($HOME."/.vim/vimrc.local")
  source ~/.vim/vimrc.local
endif

if filereadable($HOME."/.vim/vim-plug.conf.vim")
  call plug#begin('~/.vim/plugged')
  source ~/.vim/vim-plug.conf.vim
  call plug#end()
endif

let g:gruvbox_italic=1
let g:gruvbox_contrast_dark="hard"
set background=dark
colorscheme gruvbox
