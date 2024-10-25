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
set cmdheight=1
set noshowcmd
set noshowmode
set dy=lastline
set ambw=double
set bo=all
set ttm=50
set wmnu
set wildcharm=<Tab>
set acd
set bsk=/var/tmp/*
set udir=~/.vim/undo
set udf
set ut=2000
set is
set hls
aug vimrc
au!
aug End
g:util_each_nest = 0
def! g:UtilEach(b: string)
const [c, d] = b->split('^\S*\zs')
g:util_each_nest += 1
for i in c->split(',')
var a = d->substitute('{0\?}', i, 'g')
if a ==# d
a = $'{i} {a}'
endif
exe a->substitute($"\{{g:util_each_nest}\}", '{}', 'g')
endfor
g:util_each_nest -= 1
enddef
com! -keepscript -nargs=* Each g:UtilEach(<q-args>)
com! -nargs=1 -complete=var Enable <args> = 1
com! -nargs=1 -complete=var Disable <args> = 0
def A(): bool
return &modified || ! empty(bufname())
enddef
def g:IndentStr(a: any): string
return matchstr(getline(a), '^\s*')
enddef
def B(a: string)
const b = getline('.')->len()
var c = getcurpos()
exe a
c[2] += getline('.')->len() - b
setpos('.', c)
enddef
def! g:VFirstLast(): list<number>
return [line('.'), line('v')]->sort('n')
enddef
def! g:VRange(): list<number>
const a = g:VFirstLast()
return range(a[0], a[1])
enddef
g:ezpack_home = expand($'{&pp->split(',')[0]}/pack/ezpack')
if !isdirectory(g:ezpack_home)
system($'git clone https://github.com/utubo/vim-ezpack.git {g:ezpack_home}/opt/vim-ezpack')
vimrc#ezpack#Install()
endif
com! EzpackInstall vimrc#ezpack#Install()
com! EzpackCleanUp vimrc#ezpack#CleanUp()
g:zenmode = {}
au vimrc User Vim9skkModeChanged zenmode#Invalidate()
g:vim9skk = {
keymap: {
toggle: ['<C-j>', ';j'],
midasi: [':', 'Q'],
}
}
g:vim9skk_mode = ''
nn ;j i<Plug>(vim9skk-enable)
au vimrc User Vim9skkEnter feedkeys('Q')
au vimrc User Vim9skkInitPre vimrc#vim9skk#ApplySettings()
Each onoremap,xnoremap ab <Plug>(textobj-multiblock-a)
Each onoremap,xnoremap ib <Plug>(textobj-multiblock-i)
g:textobj_multiblock_blocks = [
[ "(", ")" ],
[ "[", "]" ],
[ "{", "}" ],
[ '<', '>' ],
[ '"', '"', 1 ],
[ "'", "'", 1 ],
[ ">", "<", 1 ],
[ "「", "」", 1 ],
]
call textobj#user#plugin('nonwhitespace', {
'-': { 'pattern': '\S\+', 'select': ['a<Space>', 'i<Space>'], }
})
filetype plugin indent on
def! g:MyFoldText(): string
const a = getline(v:foldstart)
const b = repeat(' ', indent(v:foldstart))
if &fdm ==# 'indent'
return $'{b}📁 {v:foldend - v:foldstart + 1}lines'
else
const c = a->substitute(matchstr(&foldmarker, '^[^,]*'), '', '')->trim()
return $'{b}{c} 📁'
endif
enddef
set fdt=g:MyFoldText()
set fcs+=fold:\ 
au vimrc ColorScheme * {
hi! link Folded Delimiter
hi! link ALEVirtualTextWarning ALEWarningSign
hi! link ALEVirtualTextError ALEErrorSign
}
set fdm=marker
au vimrc FileType markdown,yaml setlocal foldlevelstart=99 foldmethod=indent
au vimrc BufReadPost * :silent! normal! zO
nn <expr> h (col('.') ==# 1 && 0 < foldlevel('.') ? 'zc' : 'h')
nn Z<Tab> <Cmd>set foldmethod=indent<CR>
nn Z{ <Cmd>set foldmethod=marker<CR>
nn Zy <Cmd>set foldmethod=syntax<CR>
xn zf <ScriptCmd>vimrc#myutil#Zf()<CR>
nn zd <ScriptCmd>vimrc#myutil#Zd()<CR>
nn <silent> g; g;zO
nn <expr> ZB $"<Cmd>set background={&bg ==# 'dark' ? 'light' : 'dark'}<CR>"
au vimrc ColorSchemePre * {
g:rcsv_colorpairs = [
['105', '#9999ee'], ['117', '#99ccee'], ['120', '#99ee99'],
['228', '#eeee99'], ['212', '#ee99cc'], ['177', '#cc99ee']
]
}
def C(a: number, b: string): string
const v = synIDattr(a, b)->matchstr(has('gui') ? '.*[^0-9].*' : '^[0-9]\+$')
return !v ? 'NONE' : v
enddef
def D(a: string): any
const b = hlID(a)->synIDtrans()
return { fg: C(b, 'fg'), bg: C(b, 'bg') }
enddef
def E()
hi! link CmdHeight0Horiz MoreMsg
const x = has('gui') ? 'gui' : 'cterm'
const a = D('LineNr').bg
exe $'hi LspDiagSignErrorText   {x}bg={a} {x}fg={D("ErrorMsg").fg}'
exe $'hi LspDiagSignHintText    {x}bg={a} {x}fg={D("Question").fg}'
exe $'hi LspDiagSignInfoText    {x}bg={a} {x}fg={D("Pmenu").fg}'
exe $'hi LspDiagSignWarningText {x}bg={a} {x}fg={D("WarningMsg").fg}'
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
matchadd('Error', 'ERROR')
matchadd('Delimiter', '- \[ \]')
matchadd('SpellRare', '[ａ-ｚＡ-Ｚ０-９（）｛｝]')
matchadd('SpellBad', '[　¥]')
matchadd('SpellBad', 'stlye')
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
set bg=light
sil! colorscheme girly
if '~/.vimrc_local'->expand()->filereadable()
so ~/.vimrc_local
endif
def H()
var a = get(v:oldfiles, 0, '')->expand()
if a->filereadable()
exe 'edit' a
endif
enddef
au vimrc VimEnter * ++nested if !A()|H()|endif
au vimrc SafeStateAgain * ++once vimrc#lazyload#LazyLoad()
