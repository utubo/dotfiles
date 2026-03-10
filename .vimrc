vim9script noclear
set enc=utf-8
scripte utf-8
set fencs=ucs-bom,utf-8,iso-2022-jp,cp932,euc-jp
set noet
set ts=3
set sw=0
set st=0
set ai
set si
set bri
set backspace=indent,start,eol
set nf=alpha,hex
set ve=block
set list
set lcs=tab:\|\ ,trail:-,extends:>,precedes:<,nbsp:%
set fcs=vert:│
set hidden
set showtabline=0
set cmdheight=1
set noshowcmd
set noshowmode
set wmnu
set wildcharm=<Tab>
set dy=lastline
set ambw=single
set bo=all
set ttm=50
set acd
set bsk=/var/tmp/*
set udir=~/.vim/undo
set udf
set ut=2000
set is
set hls
set shortmess+=FI
set noru
g:maplocalleader = ';'
filetype plugin indent on
aug vimrc
au!
aug END
set titlestring=Vim\ -\ %t
set title
set titleold=
if &term =~# 'xterm\|rxvt\|screen\|interix'
au vimrc VimLeave * silent !echo -ne "\e[22;0t"
endif
g:ezpack_home = expand($'{&pp->split(',')[0]}/pack/ezpack')
if !isdirectory(g:ezpack_home)
system($'git clone https://github.com/utubo/vim-ezpack.git {g:ezpack_home}/opt/vim-ezpack')
vimrc#ezpack#Install()
endif
com! EzpackInstall vimrc#ezpack#Install()
com! EzpackCleanUp vimrc#ezpack#CleanUp()
def! g:MyFoldText(): string
const a = "\uf196"
const b = repeat(' ', indent(v:foldstart))
if &fdm ==# 'syntax'
const c = getline(v:foldstart)->trim()
return $'{b}{c}{a}'
endif
if &fdm ==# 'marker'
const c = getline(v:foldstart)
->substitute(matchstr(&foldmarker, '^[^,]*'), '', '')
->trim()
return $'{b}{c}{a}'
endif
const c = $'{b}{a}{v:foldend - v:foldstart + 1}lines'
if &ft !=# 'markdown'
return c
endif
var d = matchbufline(bufnr(), '^\s*- \[[ x*]]', v:foldstart, v:foldend)
const e = d->len()
if e ==# 0
return c
endif
const f = d
->filter((index, value) => value.text[-2 : -2] !=# ' ')
->len()
return $'{c} [{f}/{e}]'
enddef
set fdt=g:MyFoldText()
set fcs+=fold:\ 
au vimrc ColorScheme * {
hi! link Folded Directory
hi! link ALEVirtualTextWarning ALEWarningSign
hi! link ALEVirtualTextError ALEErrorSign
}
set fdm=syntax
au vimrc FileType markdown,yaml setlocal foldlevelstart=99 foldmethod=indent
au vimrc FileType vim setlocal foldmethod=marker
nn <expr> h (col('.') ==# 1 && 0 < foldlevel('.') ? 'zc' : 'h')
nn l l<Cmd>normal zv<CR>
nn <silent> n n<Cmd>normal zv<CR>
nn <silent> N N<Cmd>normal zv<CR>
nn Z<Tab> <Cmd>set foldmethod=indent<CR>
nn Z{ <Cmd>set foldmethod=marker<CR>
nn Zy <Cmd>set foldmethod=syntax<CR>
xn zf <ScriptCmd>vimrc#myutil#Zf()<CR>
nn zd <ScriptCmd>vimrc#myutil#Zd()<CR>
nn g; <ScriptCmd>silent! normal! g;zv<CR>
g:anypanel_contents = [
'anypanel#TabList(anypanel#TabBufs)',
'anypanel#HiddenBufs()->g:TabpanelIdx2Chars()',
'%=',
'anypanel#File("~/todolist.md")',
'anypanel#Padding(1)',
'get(g:, "weather", "     ") .. strftime("    %m    %H:%M")',
'anypanel#Calendar({ label: "" })',
'vimrc#ruler#MyRuler()',
]
def A(_: number)
redrawtabpanel
timer_start(60 - localtime() % 60, A)
enddef
def B(_: number)
vimrc#weather#UpdateWeather()
redrawtabpanel
const d = 60 * 60 * 24
timer_start(d - localtime() % d, B)
enddef
au vimrc VimEnter * A(0)
au vimrc VimEnter * silent! B(0)
g:idxchars = '%jklhdsanmvcgqwertyuiopzxb'
def! g:TabpanelIdx2Chars(a: string): string
return a->substitute(' \(\d\+\):', (m) => $' {g:idxchars[str2nr(m[1])] ?? m[1]}:', 'g')
enddef
def! g:Getchar2idx(): number
ec 'Input bufnr: '
const a = stridx(g:idxchars, getchar()->nr2char())
if a ==# -1
return bufnr('#')
else
return a
endif
enddef
nn <LocalLeader>f <ScriptCmd>execute $'buffer {g:Getchar2idx()}'<CR>
nn <LocalLeader>q <ScriptCmd>execute $'confirm bdel {g:Getchar2idx()}'<CR>
nn <expr> ZB $"<Cmd>set background={&bg ==# 'dark' ? 'light' : 'dark'}<CR>"
au vimrc ColorSchemePre * {
g:rcsv_colorpairs = [
['105', '#9999ee'], ['117', '#99ccee'], ['120', '#99ee99'],
['228', '#eeee99'], ['212', '#ee99cc'], ['177', '#cc99ee']
]
}
def C(a: number, b: string): string
const v = synIDattr(a, b)->matchstr(&termguicolors ? '.*[^0-9].*' : '^[0-9]\+$')
return !v ? 'NONE' : v
enddef
def D(a: string): any
const b = hlID(a)->synIDtrans()
return { fg: C(b, 'fg'), bg: C(b, 'bg') }
enddef
def E()
const x = &termguicolors ? 'gui' : 'cterm'
const c = D('LineNr').bg
for [a, b] in items({
Error: 'ErrorMsg',
Hint: 'Question',
Info: 'MoreMsg',
Warning: 'WarningMsg',
})
exe $'hi LspDiagSign{a}Text {x}bg={c} {x}fg={D(b).fg}'
endfor
hi Comment gui=none cterm=none
hi link luaParenError Error
hi! link VertSplit NonText
hi! link ZenmodeHoriz NonText
const d = D('TabPanel').bg
exe $'hi AnyPanelCalendarSun guifg={D('ErrorMsg').fg} guibg={d}'
exe $'hi AnyPanelCalendarSat guifg={D('Directory').fg} guibg={d}'
const e = hlget('CursorIM')->get(0, {})
if get(e, 'linksto', '') ==# 'Cursor'
hi! link CursorIM PMenuSel
endif
enddef
au vimrc VimEnter,ColorScheme * E()
def F()
if exists('w:my_matches') && !empty(getmatches())
return
endif
w:my_matches = 1
matchadd('String', '「[^」]*」')
matchadd('Label', '^\s*■.*$')
matchadd('Delimiter', 'WARN\|注意\|注:\|[★※][^\s()（）]*')
matchadd('Todo', 'TODO')
matchadd('Todo', '^\s*- \zs\[ \]')
matchadd('Comment', 'DONE')
matchadd('Comment', '^\s*- \zs\[x\]')
matchadd('Error', 'ERROR')
matchadd('SpellRare', '[ａ-ｚＡ-Ｚ０-９（）｛｝]')
matchadd('SpellBad', '[　¥]')
enddef
au vimrc VimEnter,WinEnter * F()
def G()
if &list && !exists('w:hi_tail')
w:hi_tail = matchadd('SpellBad', '\s\+$')
elseif !&list && exists('w:hi_tail')
matchdelete(w:hi_tail)
unlet w:hi_tail
endif
enddef
au vimrc OptionSet list silent! G()
au vimrc BufNew,BufReadPost * silent! G()
sil! syntax enable
set t_Co=256
set termguicolors
if '~/.vimrc_local'->expand()->filereadable()
so ~/.vimrc_local
endif
g:loaded_matchparen = 1
g:loaded_matchit = 1
&t_SI = "\e[0 q"
&t_EI = "\e[2 q"
&t_SR = "\e[4 q"
setcellwidths([
[0x2010, 0x24ff, 2],
[0x2571, 0x27bf, 2],
[0x3000, 0x9faf, 2],
[0xe000, 0xf8ff, 2],
[0xff01, 0xff60, 2],
[0xffa0, 0xffee, 2],
[0x1f300, 0x1fadf, 2],
[0xf0000, 0xfffff, 2],
])
if !exists('g:colors_name')
set bg=light
sil! colorscheme girly
endif
anypanel#Init()
if 60 < &columns
vimrc#tabpanel#Toggle(2)
endif
def H()
if &ft ==# 'help' || &ft ==# 'gitrebase'
return
endif
if !!&diff
return
endif
const n = line('''"')
if n < 1 || line('$') < n
return
endif
sil! normal! g`"zMzvzz
enddef
au vimrc BufRead * au vimrc SafeState * ++once H()
au vimrc VimEnter * ++nested {
if empty(bufname())
const k = get(v:oldfiles, 0, '')->expand()
if k->filereadable()
packadd vim-gitgutter
packadd vim-log-highlighting
packadd vim-polyglot
vimrc#lsp#LazyLoad()
exe 'edit' k
H()
endif
endif
if empty(bufname())
intro
endif
}
au vimrc SafeStateAgain * ++once vimrc#lazyload#LazyLoad()
