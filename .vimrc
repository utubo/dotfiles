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
set hidden
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
set shortmess+=FI
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
const a = repeat(' ', indent(v:foldstart))
if &fdm !=# 'indent'
const b = getline(v:foldstart)
->substitute(matchstr(&foldmarker, '^[^,]*'), '', '')
->trim()
return $'{a}{b} 📁'
endif
const b = $'{a}📁 {v:foldend - v:foldstart + 1}lines'
if &ft !=# 'markdown'
return b
endif
var c = matchbufline(bufnr(), '^\s*- \[[ x*]]', v:foldstart, v:foldend)
const d = c->len()
if d ==# 0
return b
endif
const e = c
->filter((index, value) => value.text[-2 : -2] !=# ' ')
->len()
return $'{b} [{e}/{d}]'
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
nn <expr> h (col('.') ==# 1 && 0 < foldlevel('.') ? 'zc' : 'h')
nn Z<Tab> <Cmd>set foldmethod=indent<CR>
nn Z{ <Cmd>set foldmethod=marker<CR>
nn Zy <Cmd>set foldmethod=syntax<CR>
xn zf <ScriptCmd>vimrc#myutil#Zf()<CR>
nn zd <ScriptCmd>vimrc#myutil#Zd()<CR>
nn g; <ScriptCmd>silent! normal! g;zO<CR>
nn <expr> ZB $"<Cmd>set background={&bg ==# 'dark' ? 'light' : 'dark'}<CR>"
au vimrc ColorSchemePre * {
g:rcsv_colorpairs = [
['105', '#9999ee'], ['117', '#99ccee'], ['120', '#99ee99'],
['228', '#eeee99'], ['212', '#ee99cc'], ['177', '#cc99ee']
]
}
def A(a: number, b: string): string
const v = synIDattr(a, b)->matchstr(has('gui') ? '.*[^0-9].*' : '^[0-9]\+$')
return !v ? 'NONE' : v
enddef
def B(a: string): any
const b = hlID(a)->synIDtrans()
return { fg: A(b, 'fg'), bg: A(b, 'bg') }
enddef
def C()
const x = has('gui') ? 'gui' : 'cterm'
const a = B('LineNr').bg
exe $'hi LspDiagSignErrorText   {x}bg={a} {x}fg={B("ErrorMsg").fg}'
exe $'hi LspDiagSignHintText    {x}bg={a} {x}fg={B("Question").fg}'
exe $'hi LspDiagSignInfoText    {x}bg={a} {x}fg={B("Pmenu").fg}'
exe $'hi LspDiagSignWarningText {x}bg={a} {x}fg={B("WarningMsg").fg}'
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
matchadd('Error', 'ERROR')
matchadd('Delimiter', '- \[ \]')
matchadd('SpellRare', '[ａ-ｚＡ-Ｚ０-９（）｛｝]')
matchadd('SpellBad', '[　¥]')
matchadd('SpellBad', 'stlye')
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
g:loaded_matchparen = 1
g:loaded_matchit = 1
if has('vim_starting')
&t_SI = "\e[0 q"
&t_EI = "\e[2 q"
&t_SR = "\e[4 q"
endif
if '~/.vimrc_local'->expand()->filereadable()
so ~/.vimrc_local
endif
if !exists('g:colors_name')
set bg=light
sil! colorscheme girly
endif
def F()
const n = line('''"')
if 1 <= n && n <= line('$')
sil! normal! g`"zOzz
endif
enddef
au vimrc BufRead * F()
au vimrc VimEnter * ++nested {
if empty(bufname())
const k = get(v:oldfiles, 0, '')->expand()
if k->filereadable()
packadd vim-gitgutter
packadd vim-log-highlighting
packadd vim-polyglot
vimrc#lsp#LazyLoad()
exe 'edit' k
endif
endif
if empty(bufname())
intro
endif
}
au vimrc SafeStateAgain * ++once vimrc#lazyload#LazyLoad()
