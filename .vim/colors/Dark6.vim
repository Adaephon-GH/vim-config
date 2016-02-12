" 本配色方案由 gui2term.py 程序增加彩色终端支持。
"
" A color scheme that uses the colors from "Dark", but the arrangement of
" "Light".
"


" Restore default colors
hi clear
set background=dark

if exists("syntax_on")
    syntax reset
endif

let g:colors_name = "Dark6"


hi Cursor guibg=goldenrod2 ctermbg=214 cterm=none
hi! link lCursor Cursor

hi Normal  guibg=black guifg=GhostWhite ctermfg=15 ctermbg=NONE cterm=none
"hi Folded guibg=grey45 guifg=grey90


if version >= 700
    " Just a tad off of bg
    hi CursorLine   guibg=gray7 ctermbg=233 cterm=none
    hi CursorColumn guibg=gray7 ctermbg=233 cterm=none
endif

if version >= 703
    hi ColorColumn term=reverse guibg=#5f0000 ctermbg=52
endif

"
" Grey
"

hi SpecialKey guifg=grey50 ctermfg=244 ctermbg=NONE cterm=none
hi Comment guifg=grey40 gui=none ctermfg=241 ctermbg=NONE cterm=none



"
" Tan
"
hi Statement  guifg=tan ctermfg=180 ctermbg=NONE cterm=none



"
" Red
"
hi PreProc guifg=#FF7070   gui=none ctermfg=203 ctermbg=NONE cterm=none
hi Error guibg=red3 ctermbg=160 cterm=none
hi WarningMsg guifg=red guibg=GhostWhite gui=bold ctermfg=196 ctermbg=189 cterm=bold


"
" Green
"


"
" Yellow
"
hi Special    guifg=#DDDD00 gui=none ctermfg=184 ctermbg=NONE cterm=none
"hi Visual gui=reverse guibg=fg guifg=goldenrod3 ctermfg=172 ctermbg=189 cterm=reverse
hi Visual guifg=black guibg=gold1 ctermbg=220 ctermfg=15 gui=none cterm=none
hi NonText guibg=grey17 guifg=goldenrod2 ctermfg=214 ctermbg=235 cterm=none
hi Folded guibg=grey7 guifg=goldenrod2 ctermfg=214 ctermbg=233 cterm=none
hi LineNr guibg=grey17 guifg=goldenrod2 ctermfg=214 ctermbg=235 cterm=none


"
" Blue
"
hi Identifier guifg=SkyBlue gui=none ctermfg=117 ctermbg=NONE cterm=none
hi Search guibg=LightSkyBlue3 guifg=black gui=none ctermfg=16 ctermbg=110 cterm=none
"hi IncSearch guibg=LightSkyBlue3 guifg=yellow gui=bold
hi IncSearch guibg=blue guifg=yellow gui=bold ctermfg=226 ctermbg=21 cterm=bold
hi Title gui=bold guifg=#80a0ff ctermfg=111 ctermbg=NONE cterm=bold

hi link Function Identifier


"
" Purple
"

hi Type guifg=LightPink gui=none ctermfg=218 ctermbg=NONE cterm=none


"
" Cyan
"
hi SignColumn guifg=cyan guibg=grey10 ctermfg=51 ctermbg=234 cterm=none
hi FoldColumn guibg=grey17 guifg=cyan ctermfg=51 ctermbg=235 cterm=none


"
" Orange
"
hi String guifg=orange2      gui=none ctermfg=214 ctermbg=NONE cterm=none

" Diff
hi DiffText     guibg=#5f0000 ctermbg=52
hi DiffAdd      guibg=#00005f ctermbg=17
hi DiffChange   guibg=#5f005f ctermbg=53
hi DiffDelete   guibg=grey17  ctermbg=235 guifg=#00005f ctermfg=17 gui=none cterm=none


"
" Misc
"
"hi! link SpecialKey Identifier
hi! link Directory Identifier


