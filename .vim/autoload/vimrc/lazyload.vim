vim9script
com! -nargs=* GitAdd vimrc#git#GitAdd(<q-args>)
com! -nargs=1 -complete=customlist,vimrc#git#ConventionalCommits GitCommit Git commit -m <q-args>
com! -nargs=1 GitTagPush vimrc#git#GitTagPush(<q-args>)
nn <Space>ga <Cmd>GitAdd -A<CR>
nn <Space>gA :<C-u>Git add %
nn <Space>gc :<C-u>GitCommit<Space><Tab>
nn <Space>gp :<C-u>Git push<End>
nn <Space>gs <Cmd>Git status -sb<CR>
nn <Space>gv <Cmd>Gvdiffsplit<CR>
nn <Space>gd <Cmd>Gdiffsplit<CR>
nn <Space>gl <Cmd>Git pull<CR>
nn <Space>gt :<C-u>GitTagPush<Space>
nn <Space>gC :<C-u>Git checkout %
au vimrc FileType gh-repos {
nn <buffer> i <ScriptCmd>execute 'edit!' ['gh:/', getline('.')->matchstr('\S\+'), 'issues']->join('/')<CR>
}
au vimrc FileType gh-issues {
nn <buffer> <CR> <ScriptCmd>execute 'new' [expand('%'), getline('.')->matchstr('[0-9]\+'), 'comments']->join('/')<CR>
nn <buffer> r <ScriptCmd>execute 'edit!' expand('%:h:h') .. '/repos'<CR>
}
au vimrc FileType gh-issue-comments {
nn <buffer> <CR> <ScriptCmd>execute 'bo vsplit' [expand('%'), getline('.')->matchstr('[0-9]\+')]->join('/')<CR><Cmd>setlocal wrap<CR>
}
nn <Space>gh <Cmd>tabe gh://utubo/repos<CR>
nn <F2> <Cmd>MRUToggle<CR>
g:MRU_Exclude_Files = has('win32') ? $'{$TEMP}\\.*' : '^/tmp/.*\|^/var/tmp/.*'
vimrc#lexima#LazyLoad()
var lk = {
diagSignErrorText: '🐞',
diagSignHintText: '💡',
diagSignInfoText: '💠',
diagSignWarningText: '🐝',
showDiagWithVirtualText: true,
diagVirtualTextAlign: 'after',
}
const ll = has('win32') ? '.cmd' : ''
var lm = [{
name: 'typescriptlang',
filetype: ['javascript', 'typescript'],
path: $'typescript-language-server{ll}',
args: ['--stdio'],
}, {
name: 'vimlang',
filetype: ['vim'],
path: $'vim-language-server{ll}',
args: ['--stdio'],
}, {
name: 'htmllang',
filetype: ['html'],
path: $'html-languageserver{ll}',
args: ['--stdio'],
}, {
name: 'jsonlang',
filetype: ['json'],
path: $'vscode-json-languageserver{ll}',
args: ['--stdio'],
}]
packadd lsp
g:LspOptionsSet(lk)
g:LspAddServer(lm)
nn [l <Cmd>LspDiagPrev<CR>
nn ]l <Cmd>LspDiagNext<CR>
nn <Leader>a <Cmd>PortalAim<CR>
nn <Leader>b <Cmd>PortalAim blue<CR>
nn <Leader>o <Cmd>PortalAim orange<CR>
nn <Leader>r <Cmd>PortalReset<CR>
Enable g:sandwich_no_default_key_mappings
Enable g:operator_sandwich_no_default_key_mappings
Each nmap,xmap S <ScriptCmd>vimrc#sandwich#ApplySettings('S')<CR>
def A(): string
const c = matchstr(getline('.'), '.', col('.') - 1)
if !c || stridx(')]}>\''`」', c) ==# -1
return "\<Tab>"
else
return "\<C-o>a"
endif
enddef
Each imap,smap <expr> <Tab> vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : pumvisible() ? '<C-n>' : A()
Each imap,smap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : pumvisible() ? '<C-p>' : '<S-Tab>'
g:skipslash_autocomplete = 1
g:loaded_matchparen = 1
g:loaded_matchit = 1
nn <Space>t <ScriptCmd>tabpopupmenu#popup()<CR>
nn <Space>T <ScriptCmd>tablist#Show()<CR>
Each nnoremap,tnoremap <silent> <C-w><C-s> <Plug>(shrink-height)<C-w>w
Each nnoremap,tnoremap <silent> <C-w><C-h> <Plug>(shrink-width)<C-w>w
no <Space>s <Plug>(jumpcursor-jump)
vimrc#hlpairs#LazyLoad()
nm <C-p> <ScriptCmd>vimrc#ctrlp#LazyLoad()<CR><C-p>
nm s <ScriptCmd>vimrc#easymotion#LazyLoad()<CR>s
com! -nargs=* Fern vimrc#fern#LazyLoad(<q-args>)
nn <expr> <F1> $"\<Cmd>Fern . -reveal=% -opener={!bufname() && !&mod ? 'edit' : 'split'}\<CR>"
Enable g:rainbow_active
g:auto_cursorline_wait_ms = &ut
Each w,b,e,ge nnoremap {0} <Plug>(smartword-{0})
nn [c <Plug>(GitGutterPrevHunk)
nn ]c <Plug>(GitGutterNextHunk)
Each nnoremap,xnoremap <Space>c <Plug>(caw:hatpos:toggle)
g:vimhelpgenerator_version = ''
g:vimhelpgenerator_author = 'Author  : utubo'
g:vimhelpgenerator_defaultlanguage = 'en'
g:vimhelpgenerator_uri = 'https://github.com/utubo/'
au vimrc InsertLeave * set nopaste
au vimrc BufReadPost *.log* normal! G
xn * "vy/\V<C-r>=substitute(escape(@v,'\/'),"\n",'\\n','g')<CR><CR>
set mps+=（:）,「:」,『:』,【:】,［:］,＜:＞
Each i,a,A nnoremap <expr> {0} !empty(getline('.')) ? '{0}' : '"_cc'
Each +,-,>,< Each nmap,tmap <C-w>{0} <C-w>{0}<SID>ws
Each +,-,>,< Each nnoremap,tnoremap <script> <SID>ws{0} <C-w>{0}<SID>ws
Each nmap,tmap <SID>ws <Nop>
nn <A-J> <Cmd>copy.<CR>
nn <A-K> <Cmd>copy-1<CR>
xn <A-J> :copy'<-1<CR>gv
xn <A-K> :copy'>+0<CR>gv
def B(): string
const a = getpos('.')[2]
const b = getline('.')[0 : a - 1]
const c = matchstr(b, '\v<(\k(<)@!)*$')
return toupper(c)
enddef
ino <expr> ;l $"<C-w>{B()}"
com! -nargs=+ -complete=dir VimGrep vimrc#myutil#VimGrep(<f-args>)
au vimrc WinEnter * if winnr('$') ==# 1 && &buftype ==# 'quickfix'|q|endif
set spr
set fcs+=diff:\ 
au vimrc WinEnter * if (winnr('$') ==# 1) && !!getbufvar(winbufnr(0), '&diff')|diffoff|endif
g:reformatdate_extend_names = [{
a: ['日', '月', '火', '水', '木', '金', '土'],
A: ['日曜日', '月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日'],
}]
g:reformatdate_extend_formats = ['%m/%d(%a)']
reformatdate#init()
ino <expr> <F5> strftime('%Y/%m/%d')
cno <expr> <F5> strftime('%Y%m%d')
nn <F5> <ScriptCmd>reformatdate#reformat(localtime())<CR>
nn <C-a> <ScriptCmd>reformatdate#inc(v:count)<CR>
nn <C-x> <ScriptCmd>reformatdate#dec(v:count)<CR>
nn <Space><F5> /\d\{4\}\/\d\d\/\d\d<CR>
def C()
const a = 100
const b = getpos('.')
cursor(1, 1)
if !!search('^\t', 'nc', a)
setl noet
setl ts=3
elseif !!search('^  \S', 'nc', a)
setl et
setl ts=2
elseif !!search('^    \S', 'nc', a)
setl et
setl ts=4
endif
&sw = &ts
&st = &ts
setpos('.', b)
enddef
au vimrc BufReadPost * C()
C()
nn gn <Cmd>bnext<CR>
nn gp <Cmd>bprevious<CR>
g:recentBufnr = 0
au vimrc BufLeave * g:recentBufnr = bufnr()
nn <expr> gr $"\<Cmd>b{g:recentBufnr}\<CR>"
var ln = []
def D()
ln = []
for a in execute('ls')->split("\n")
const m = a->matchlist('^ *\([0-9]\+\) \([^"]*\)"\(.*\)" \+line [0-9]\+')
if !m->empty()
var b = {
nr: m[1],
name: m[2][2] =~# '[RF?]' ? '[Term]' : m[3]->pathshorten(),
current: m[2][0] ==# '%',
}
ln += [b]
b.width = strdisplaywidth($' {b.nr}{b.name} ')
endif
endfor
E()
g:zenmode.preventEcho = ln->len() > 1
enddef
def E()
if ln->len() <= 1
return
endif
if ['ControlP']->index(bufname('%')) !=# -1
return
endif
if mode() ==# 'c'
return
endif
redraw
var s = 0
var e = 0
var w = 0
var a = false
var c = false
var d = false
for b in ln
w += b.width
if &columns - 5 < w
if d
e -= 1
a = true
break
endif
s += 1
c = true
endif
if b.current
d = true
endif
e += 1
endfor
w = getwininfo(win_getid(1))[0].textoff
echoh TablineFill
echon repeat(' ', w)
if c
echoh Tabline
echon '< '
w += 2
endif
for b in ln[s : e]
w += b.width
if b.current
echoh TablineSel
else
echoh Tabline
endif
echon $'{b.nr} {b.name} '
endfor
if a
echoh Tabline
echon '>'
w += 1
endif
const f = &columns - 1 - w
if 0 < f
echoh TablineFill
echon repeat(' ', &columns - 1 - w)
endif
echoh Normal
enddef
au vimrc BufAdd,BufEnter,BufDelete,BufWipeout * au vimrc SafeState * ++once D()
au vimrc CursorMoved * E()
def F(a: string = '')
if &ft ==# 'qf'
return
endif
var b = a ==# 'BufReadPost'
if b && !filereadable(expand('%'))
return
endif
const c = $' {line(".")}:{col(".")}'
var e = []
add(e, ['Title', $'"{bufname()}"'])
add(e, ['Normal', ' '])
if &modified
add(e, ['Delimiter', '[+]'])
add(e, ['Normal', ' '])
endif
if !b && !filereadable(expand('%'))
add(e, ['Tag', '[New]'])
add(e, ['Normal', ' '])
endif
if &readonly
add(e, ['WarningMsg', '[RO]'])
add(e, ['Normal', ' '])
endif
const w = wordcount()
if b || w.bytes !=# 0
add(e, ['Constant', printf('%dL, %dB', w.bytes ==# 0 ? 0 : line('$'), w.bytes)])
add(e, ['Normal', ' '])
endif
add(e, ['MoreMsg', &ff])
add(e, ['Normal', ' '])
const f = empty(&fenc) ? &enc : &fenc
add(e, [f ==# 'utf-8' ? 'MoreMsg' : 'WarningMsg', f])
add(e, ['Normal', ' '])
add(e, ['MoreMsg', &ft])
var g = 0
const h = &columns - len(c) - 2
for i in reverse(range(0, len(e) - 1))
var s = e[i][1]
var d = strdisplaywidth(s)
g += d
if h < g
const l = h - g + d
while !empty(s) && l < strdisplaywidth(s)
s = s[1 :]
endwhile
e[i][1] = s
e = e[i : ]
insert(e, ['SpecialKey', '<'], 0)
break
endif
endfor
add(e, ['Normal', repeat(' ', h - g) .. c])
redraw
ec ''
for m in e
exe 'echohl' m[0]
echon m[1]
endfor
echoh Normal
enddef
nn <script> <C-g> <ScriptCmd>F()<CR>
au vimrc BufNewFile,BufReadPost,BufWritePost * F('BufNewFile')
set tabline=%!vimrc#tabline#MyTabline()
set guitablabel=%{vimrc#tabline#MyTablabel()}
nn <Space>e G?\cErr\\|Exception<CR>
nn <expr> <Space>f $'{(getreg('"') =~ '^\d\+$' ? ':' : '/')}{getreg('"')}<CR>'
nm <Space>. :
nm <Space>, /
nm g<Space> g;
for i in range(1, 10)
exe $'nmap <Space>{i % 10} <F{i}>'
endfor
nm <Space><Space>1 <F11>
nm <Space><Space>2 <F12>
nn <Space>a A
nn <Space>h ^
nn <Space>l $
nn <Space>y yiw
cno ;n <CR>
Each nnoremap,inoremap ;n <Cmd>update<CR><Esc>
ino ;m <Esc>`^
cno ;m <C-c>
no ;m <Esc>
ino ;v ;<CR>
ino ;w <C-o>e<C-o>a
ino ;k 「」<C-g>U<Left>
ino ;u <Esc>u
nn ;r "
nn ;rr "0p
Each nnoremap,inoremap ;<Tab> <ScriptCmd>StayCurPos('normal! >>')<CR>
Each nnoremap,inoremap ;<S-Tab> <ScriptCmd>StayCurPos('normal! <<')<CR>
nn <Space>; ;
map! <script> <SID>bs_ <Nop>
map! <script> ;h <SID>bs_h
no! <script> <SID>bs_h <BS><SID>bs_
xn u <ScriptCmd>undo\|normal! gv<CR>
xn <C-R> <ScriptCmd>redo\|normal! gv<CR>
xn <Tab> <ScriptCmd>StayCurPos('normal! >gv')<CR>
xn <S-Tab> <ScriptCmd>StayCurPos('normal! <gv')<CR>
const vmode = ['v', 'V', "\<C-v>", "\<ESC>"]
xn <script> <expr> v vmode[vmode->index(mode()) + 1]
Each nnoremap,xnoremap / <Cmd>noh<CR>/
Each nnoremap,xnoremap ? <Cmd>noh<CR>?
Each nnoremap,xnoremap ;c :
Each nnoremap,xnoremap ;s <Cmd>noh<CR>/
Each nnoremap,xnoremap + :
Each nnoremap,xnoremap , :
Each nnoremap,xnoremap <Space><Space>, ,
au vimrc CmdlineEnter * ++once vimrc#cmdline#ApplySettings()
if has('win32')
com! Powershell :bo terminal ++close pwsh
nn SH <Cmd>Powershell<CR>
nn <S-F1> <Cmd>silent !start explorer %:p:h<CR>
else
nn SH <Cmd>bo terminal<CR>
endif
def g:Tapi_drop(a: number, b: list<string>)
vimrc#terminal#Tapi_drop(a, b)
enddef
au vimrc TerminalOpen * ++once vimrc#terminal#ApplySettings()
def G(a: string)
if winnr() ==# winnr(a)
return
endif
exe 'wincmd' a
if mode() ==# 't'
quit!
else
confirm quit
endif
enddef
Each h,j,k,l nnoremap q{0} <ScriptCmd>G('{0}')<CR>
nn q <Nop>
nn Q q
nn <expr> qq $"\<Cmd>confirm {winnr('$') ==# 1 && execute('ls')->split("\n")->len() !=# 1 ? 'bd' : 'q'}\<CR>"
nn qa <Cmd>confirm qa<CR>
nn qOw <Cmd>confirm only<CR>
nn qt <Cmd>confirm tabclose +<CR>
nn qT <Cmd>confirm tabclose -<CR>
nn q# <Cmd>confirm tabclose #<CR>
nn qOt <Cmd>confirm tabonly<CR>
nn qb <Cmd>confirm bd<CR>
nn qn <Cmd>bn<CR><Cmd>confirm bd<CR>
nn qp <Cmd>bp<CR><Cmd>confirm bd<CR>
nn <expr> qo $"\<Cmd>vim9cmd confirm bd {range(1, last_buffer_nr())->filter((i, b) => b !=# bufnr() && buflisted(b))->join()}\<CR>"
nn q: q:
nn q/ q/
nn q? q?
nn qQ <Cmd>e #<1<CR>
cno <script> <expr> <SID>(exec_line) $'{getline('.')->substitute('^[ \t"#:]\+', '', '')}<CR>'
nn <script> g: :<C-u><SID>(exec_line)
nn <script> g9 :<C-u>vim9cmd <SID>(exec_line)
xn g: "vy:<C-u><C-r>=@v<CR><CR>
xn g9 "vy:<C-u>vim9cmd <C-r>=@v<CR><CR>
nn <expr> <Space>hl $'<Cmd>hi {synID(line('.'), col('.'), 1)->synIDattr('name')->substitute('^$', 'Normal', '')}<CR>'
if has('clipboard')
au vimrc FocusGained * @" = @+
au vimrc FocusLost * @+ = @"
endif
if has('vim_starting')
&t_SI = "\e[6 q"
&t_EI = "\e[2 q"
&t_SR = "\e[4 q"
endif
nn <F11> <ScriptCmd>vimrc#myutil#ToggleNumber()<CR>
nn <F12> <Cmd>set wrap!<CR>
nn gs :<C-u>%s///g<Left><Left><Left>
nn gS :<C-u>%s/<C-r>=escape(expand('<cword>'), '^$.*?/\[]')<CR>//g<Left><Left>
xn gs :s///g<Left><Left><Left>
xn gS "vy:<C-u>%s/<C-r>=substitute(escape(@v,'^$.*?/\[]'),"\n",'\\n','g')<CR>//g<Left><Left>
nn <CR> j0
nn Y y$
nn <Space>p $p
nn <Space>P ^P
nn <expr> j (getline('.')->match('\S') + 1 ==# col('.')) ? '+' : 'j'
nn <expr> k (getline('.')->match('\S') + 1 ==# col('.')) ? '-' : 'k'
nn TE :<C-u>tabe<Space>
nn TN <Cmd>tabnew<CR>
nn TD <Cmd>tabe ./<CR>
nn TT <Cmd>tabnext #<CR>
ono <expr> } $"\<Esc>m`0{v:count1}{v:operator}\}"
ono <expr> { $"\<Esc>m`V{v:count1}\{{v:operator}"
xn <expr> h mode() ==# 'V' ? '<Esc>h' : 'h'
xn <expr> l mode() ==# 'V' ? '<Esc>l' : 'l'
xn J j
xn K k
xn p P
xn P p
ino ｋｊ <Esc>`^
ino 「 「」<C-g>U<Left>
ino 「」 「」<C-g>U<Left>
ino （ ()<C-g>U<Left>
ino （） ()<C-g>U<Left>
nn ' "
nn m '
nn M m
au vimrc User InputCR feedkeys("\<C-g>u", 'n')
nn <Space>n <Cmd>nohlsearch<CR>
au vimrc CursorHold * feedkeys(' n') # nohはauで動かない(:help noh)
nn <silent> <F10> <ESC>1<C-w>s:1<CR><C-w>w
xn <F10> <ESC>1<C-w>s<C-w>w
nn <F9> my
nn <Space><F9> 'y
def H()
for a in get(w:, 'my_syntax', [])
sil! matchdelete(a)
endfor
w:my_syntax = []
enddef
def I(a: string, b: string)
w:my_syntax->add(matchadd(a, b))
enddef
au vimrc Syntax * H()
au vimrc Syntax javascript {
I('SpellRare', '\s[=!]=\s')
}
au vimrc Syntax vim {
I('SpellRare', '\s[=!]=\s')
I('SpellBad', '\s[=!]==\s')
I('SpellBad', '\s\~[=!][=#]\?\s')
I('SpellRare', '\<normal!\@!')
}
set report=9999
def g:EchoYankText(t: number)
vimrc#echoyanktext#EchoYankText()
enddef
au vimrc TextYankPost * timer_start(1, g:EchoYankText)
def J()
normal! "vygv
var a = @v->substitute('\n', '', 'g')
popup_create($'{strlen(a)}chars', {
pos: 'botleft',
line: 'cursor-1',
col: 'cursor+1',
moved: 'any',
padding: [1, 1, 1, 1],
})
enddef
xn <C-g> <ScriptCmd>J()<CR>
com! -nargs=1 Brep vimrc#myutil#Brep(<q-args>, <q-mods>)
Each f,b nmap <C-{0}> <C-{0}><SID>(hold-ctrl)
Each f,b nnoremap <script> <SID>(hold-ctrl){0} <C-{0}><SID>(hold-ctrl)
nm <SID>(hold-ctrl) <Nop>
ono A <Plug>(textobj-twochars-a)
ono I <Plug>(textobj-twochars-i)
nn <Space>w <C-w>w
nn <Space>o <C-w>w
nn <Space>d "_d
nn <Tab> <Cmd>call search('\(^\\|\t\\|, *\)\S\?', 'e')<CR>
nn <S-Tab> <Cmd>call search('\(^\\|\t\\|, *\)\S\?', 'be')<CR>
au vimrc FileType html,xml,svg {
nn <buffer> <silent> <Tab> <Cmd>call search('>')<CR><Cmd>call search('\S')<CR>
nn <buffer> <silent> <S-Tab> <Cmd>call search('>', 'b')<CR><Cmd>call search('>', 'b')<CR><Cmd>call search('\S')<CR>
}
nn <Space><Tab>u <Cmd>call vimrc#recentlytabs#ReopenRecentlyTab()<CR>
nn <Space><Tab>l <Cmd>call vimrc#recentlytabs#ShowMostRecentlyClosedTabs()<CR>
if strftime('%d') ==# '91'
au vimrc VimEnter * {
notification#show("✨ Today, Let's enjoy the default key mapping ! ✨")
mapclear
imapclear
xmapclear
cmapclear
omapclear
tmapclear
nn <Space>n <Nop>
}
endif
export def LazyLoad()
enddef