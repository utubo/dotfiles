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
set fcs=
set cursorline
set hidden
set showtabline=0
set tabpanelopt=align:right
set cmdheight=1
set noshowcmd
set noshowmode
set wmnu
set wildcharm=<Tab>
set dy=lastline
set ambw=double
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
g:maplocalleader = ';'
filetype plugin indent on
aug vimrc
au!
aug END
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
hi! link Folded Delimiter
hi! link ALEVirtualTextWarning ALEWarningSign
hi! link ALEVirtualTextError ALEErrorSign
}
set fdm=syntax
au vimrc FileType markdown,yaml setlocal foldlevelstart=99 foldmethod=indent
au vimrc FileType vim setlocal foldmethod=marker
nn <expr> h (col('.') ==# 1 && 0 < foldlevel('.') ? 'zc' : 'h') .. '<Cmd>noh<CR>'
nn l l<Cmd>normal zv<CR><Cmd>noh<CR>
nn <silent> n n<Cmd>normal zv<CR>
nn <silent> N N<Cmd>normal zv<CR>
nn Z<Tab> <Cmd>set foldmethod=indent<CR>
nn Z{ <Cmd>set foldmethod=marker<CR>
nn Zy <Cmd>set foldmethod=syntax<CR>
xn zf <ScriptCmd>vimrc#myutil#Zf()<CR>
nn zd <ScriptCmd>vimrc#myutil#Zd()<CR>
nn g; <ScriptCmd>silent! normal! g;zv<CR>
nn <expr> ZB $"<Cmd>set background={&bg ==# 'dark' ? 'light' : 'dark'}<CR>"
au vimrc ColorSchemePre * {
g:rcsv_colorpairs = [
['105', '#9999ee'], ['117', '#99ccee'], ['120', '#99ee99'],
['228', '#eeee99'], ['212', '#ee99cc'], ['177', '#cc99ee']
]
}
def A(a: number, b: string): string
const v = synIDattr(a, b)->matchstr(&termguicolors ? '.*[^0-9].*' : '^[0-9]\+$')
return !v ? 'NONE' : v
enddef
def B(a: string): any
const b = hlID(a)->synIDtrans()
return { fg: A(b, 'fg'), bg: A(b, 'bg') }
enddef
def C()
const x = &termguicolors ? 'gui' : 'cterm'
const c = B('LineNr').bg
for [a, b] in items({
Error: 'ErrorMsg',
Hint: 'Question',
Info: 'MoreMsg',
Warning: 'WarningMsg',
})
exe $'hi LspDiagSign{a}Text {x}bg={c} {x}fg={B(b).fg}'
endfor
hi link luaParenError Error
enddef
au vimrc VimEnter,ColorScheme * C()
def D()
if exists('w:my_matches') && !empty(getmatches())
return
endif
w:my_matches = 1
matchadd('String', '「[^」]*」')
matchadd('Label', '^\s*■.*$')
matchadd('Delimiter', 'WARN\|注意\|注:\|[★※][^\s()（）]*')
matchadd('Todo', 'TODO')
matchadd('Todo', '^\s*- \zs\[ \]')
matchadd('Error', 'ERROR')
matchadd('SpellRare', '[ａ-ｚＡ-Ｚ０-９（）｛｝]')
matchadd('SpellBad', '[　¥]')
enddef
au vimrc VimEnter,WinEnter * D()
def E()
if &list && !exists('w:hi_tail')
w:hi_tail = matchadd('SpellBad', '\s\+$')
elseif !&list && exists('w:hi_tail')
matchdelete(w:hi_tail)
unlet w:hi_tail
endif
enddef
au vimrc OptionSet list silent! E()
au vimrc BufNew,BufReadPost * silent! E()
sil! syntax enable
set t_Co=256
set termguicolors
g:loaded_matchparen = 1
g:loaded_matchit = 1
if has('vim_starting')
&t_SI = "\e[0 q"
&t_EI = "\e[2 q"
&t_SR = "\e[4 q"
endif
vimrc#tabpanel#Toggle(2)
g:zenmode = { ruler: true }
var k = 0
var o = 0
var q = ''
au vimrc WinEnter * {
k = winnr()
o = winbufnr(k)
q = ''
const r = getbufvar(o, '&ff')
if r ==# 'mac'
q = ' CR'
elseif r ==# 'unix'
if has('win32')
q = ' LF'
endif
elseif !has('win32')
q = ' CRLF'
endif
const s = getbufvar(o, '&fenc')
if s !=# 'utf-8'
q ..= $' {s}'
endif
}
def! g:MyRuler(): string
const p = getcurpos(k)
var a = $'{p[1]}/{getbufinfo(o)[0].linecount}:{p[2]}{q}'
return repeat(' ', 9 - len(a) / 2) .. a
enddef
set ru
set rulerformat=%{g:MyRuler()}
g:anypanel = [
'',
'anypanel#TabBufs()',
'anypanel#HiddenBufs()->g:TabpanelIdx2Chars()',
[
'anypanel#Padding(1)',
'anypanel#File("~/todolist.md")',
'anypanel#Padding(1)',
'anypanel#Calendar()',
],
]
g:idxchars = '%jklhdsanmvcgqwertyuiopzxb'
def! g:TabpanelIdx2Chars(a: string): string
return a->substitute('\(%#TabPanel# \)\(\d\+\)', (m) => m[1] .. (g:idxchars[str2nr(m[2])] ?? m[2]), 'g')
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
nn <LocalLeader>d <ScriptCmd>execute $'confirm bdel {g:Getchar2idx()}'<CR>
if '~/.vimrc_local'->expand()->filereadable()
so ~/.vimrc_local
endif
if !exists('g:colors_name')
set bg=light
sil! colorscheme girly
endif
anypanel#Init()
def F()
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
sil! normal! g`"zvzz
enddef
au vimrc BufRead * au vimrc SafeState * ++once F()
au vimrc VimEnter * ++nested {
if empty(bufname())
const t = get(v:oldfiles, 0, '')->expand()
if t->filereadable()
packadd vim-gitgutter
packadd vim-log-highlighting
packadd vim-polyglot
vimrc#lsp#LazyLoad()
exe 'edit' t
endif
endif
if empty(bufname())
intro
endif
}
au vimrc SafeStateAgain * ++once vimrc#lazyload#LazyLoad()
