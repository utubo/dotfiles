vim9script
g:util_each_nest = 0
def! g:UtilEach(b: string)
var [c, d] = b->split('^\S*\zs')
g:util_each_nest += 1
var e = c->split(',')
const f = e[0]->split('=')
const k = len(f) ==# 1 ? '{0\?}' : f[0]
e[0] = f[-1]
for i in e
var a = d->substitute(k, i, 'g')
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
def g:IndentStr(a: any): string
return matchstr(getline(a), '^\s*')
enddef
def g:StayCurPos(a: string)
const b = getline('.')->len()
var c = getcurpos()
exe a
c[2] += getline('.')->len() - b
setpos('.', c)
enddef
def g:System(a: string): string
if !has('win32')
return system(a)
endif
var b = []
var c = job_start(a, {
out_cb: (j, s) => {
b = b + [s]
}
})
while job_status(c) ==# 'run'
sleep 10m
endwhile
return join(b, "\n")
enddef
def! g:VFirstLast(): list<number>
return [line('.'), line('v')]->sort('n')
enddef
def! g:VRange(): list<number>
const a = g:VFirstLast()
return range(a[0], a[1])
enddef
packadd lsp
packadd vim-notification
packadd vim-reformatdate
packadd vim-textobj-user
au vimrc User Vim9skkModeChanged zenmode#Invalidate()
g:vim9skk = {
keymap: {
midasi: ';',
toggle: ['<C-j>', ';j'],
complete: ['<CR>', ';;'],
},
}
g:vim9skk_mode = ''
nn ;j i<Plug>(vim9skk-enable)
au vimrc User Vim9skkInitPre vimrc#vim9skk#ApplySettings()
no <Leader>ga ga
packadd vim-headtail
HeadTailMap g G
Each nmap,xmap g% gi%
Each nmap,xmap G% Gi%
Each X=a,i Each onoremap,xnoremap Xb <Plug>(textobj-multiblock-X)
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
com! -nargs=* GitAdd vimrc#git#Add(<q-args>)
com! -nargs=1 -complete=customlist,vimrc#git#ConventionalCommits GitCommit vimrc#git#Commit(<q-args>)
com! -nargs=1 -complete=customlist,vimrc#git#ConventionalCommits GitAmend vimrc#git#Amend(<q-args>)
com! -nargs=1 GitTagPush vimrc#git#TagPush(<q-args>)
nn <Space>ga <Cmd>GitAdd -A<CR>
nn <Space>gc :<C-u>GitCommit<Space><Tab>
nn <Space>gA :<C-u>GitAmend<Space><C-r>=vimrc#git#GetLastCommitMessage()<CR>
nn <Space>gp :<C-u>Git push<End>
nn <Space>gs <Cmd>Git status -sb<CR>
nn <Space>gv <Cmd>Gvdiffsplit<CR>
nn <Space>gd <Cmd>Gdiffsplit<CR>
nn <Space>gl <Cmd>Git pull<CR>
nn <Space>gt :<C-u>GitTagPush<Space>
nn <Space>gC :<C-u>Git checkout %
def A()
const a = has('win32') ? '~/_vimrc' : '~/.vimrc'
const b = a->expand()->resolve()->fnamemodify(':h')
const c = getcwd()
chdir(b)
ec g:System($'git pull')
chdir(c)
exe $'source {has('win32') ? '~/vimfiles' : '~/.vim'}/autoload/vimrc/ezpack.vim'
EzpackInstall
enddef
nn <Space>GL <ScriptCmd>A()<CR>
nn <Space>gh <Cmd>e gh://utubo/repos<CR>
au vimrc FileType gh-repos vimrc#gh#ReposKeymap()
au vimrc FileType gh-issues vimrc#gh#IssuesKeymap()
au vimrc FileType gh-issue-comments vimrc#gh#IssueCommentsKeymap()
nn <F2> <Cmd>MRUToggle<CR>
g:MRU_Exclude_Files = has('win32') ? $'{$TEMP}\\.*' : '^/tmp/.*\|^/var/tmp/.*'
nn <Leader>a <Cmd>PortalAim<CR>
nn <Leader>b <Cmd>PortalAim blue<CR>
nn <Leader>o <Cmd>PortalAim orange<CR>
nn <Leader>r <Cmd>PortalReset<CR>
def g:MyCmdline()
var w = 10
if &columns < w
return
endif
packadd cmdline.vim
var p = screenpos(0, line('.'), col('.'))
var o = getwininfo()[0].textoff
g:x = [o, p.col - 3, &columns - w]
var x = [o, p.col - 3, &columns - w]->sort('n')[1]
g:hi_cursor = hlget('Cursor')[0]
g:hi_cursor.name = 'cmdlineCursor'
hlset([g:hi_cursor])
au CmdlineEnter * ++once au SafeState * ++once hlset([g:hi_cursor])
cmdline#set_option({
col: x,
row: p.row,
width: w,
highlight_prompt: 'PMenuKind',
highlight_window: 'PMenu',
highlight_cursor: 'cmdlineCursor',
border: 'none',
})
call cmdline#enable()
enddef
nn : <Cmd>call g:MyCmdline()<CR>:
Each /,? nnoremap {} <Cmd>call g:MyCmdline()<CR><Cmd>noh<CR>{}
export def SkipParen(): string
const c = matchstr(getline('.'), '.', col('.') - 1)
if !c || stridx(')]}>\''`」', c) ==# -1
return "\<Tab>"
else
return "\<C-o>a"
endif
enddef
Each imap,smap <expr> <Tab> vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : pumvisible() ? '<C-n>' : vimrc#lazyload#SkipParen()
Each imap,smap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : pumvisible() ? '<C-p>' : '<S-Tab>'
g:skipslash_autocomplete = 1
nn <Space>t <ScriptCmd>tabpopupmenu#popup()<CR>
nn <Space>T <ScriptCmd>tablist#Show()<CR>
Each X=s,h Each nnoremap,tnoremap <silent> <C-w><C-X> <Plug>(shrink-height)<C-w>w
no <Space>s <Plug>(jumpcursor-jump)
vimrc#lexima#LazyLoad()
vimrc#lsp#LazyLoad()
Each nmap,xmap S <ScriptCmd>vimrc#sandwich#LazyLoad('S')<CR>
nm <C-p> <ScriptCmd>vimrc#ctrlp#LazyLoad()<CR><C-p>
nm s <ScriptCmd>vimrc#easymotion#LazyLoad()<CR>s
com! -nargs=* Fern vimrc#fern#LazyLoad(<q-args>)
nn <F1> <Cmd>Fern . -reveal=% -opener=edit<CR>
Enable g:rainbow_active
g:auto_cursorline_wait_ms = &ut
Each X=w,b,e,ge nnoremap X <Plug>(smartword-X)
nn [c <Plug>(GitGutterPrevHunk)
nn ]c <Plug>(GitGutterNextHunk)
Each nnoremap,xnoremap <Space>c <Plug>(caw:hatpos:toggle)
g:vimhelpgenerator_version = ''
g:vimhelpgenerator_author = 'Author  : utubo'
g:vimhelpgenerator_defaultlanguage = 'en'
g:vimhelpgenerator_uri = 'https://github.com/utubo/'
au vimrc InsertLeave * set nopaste
au vimrc FileReadPost *.log* normal! G
xn * "vy/\V<C-r>=substitute(escape(@v,'\/'),"\n",'\\n','g')<CR><CR>
set mps+=（:）,「:」,『:』,【:】,［:］,＜:＞
Each X=i,a,A nnoremap <expr> X !empty(getline('.')) ? 'X' : '"_cc'
Each X=+,-,>,< Each nmap,tmap <C-w>X <C-w>X<SID>ws
Each X=+,-,>,< Each nnoremap,tnoremap <script> <SID>wsX <C-w>X<SID>ws
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
if &ft ==# 'help'
return
endif
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
def D()
au vimrc SafeState * ++once C()
enddef
au vimrc BufReadPost * D()
D()
g:recentBufnr = 0
au vimrc BufLeave * g:recentBufnr = bufnr()
nn <expr> gr $"\<Cmd>b{g:recentBufnr}\<CR>"
com! CtrlPBuffer delc CtrlPBuffer|vimrc#ctrlp#LazyLoad()|CtrlPBuffer
nn B <ScriptCmd>CtrlPBuffer<CR>
def E(a: string = '')
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
add(e, [&ff ==# 'unix' ? 'MoreMsg' : 'WarningMsg', &ff])
add(e, ['Normal', ' '])
const f = empty(&fenc) ? &enc : &fenc
add(e, [f ==# 'utf-8' ? 'MoreMsg' : 'WarningMsg', f])
add(e, ['Normal', ' '])
add(e, ['MoreMsg', &ft])
add(e, ['Normal', ' '])
const h = g:System('git branch')->trim()->matchstr('\w\+$')
add(e, ['WarningMsg', h])
var j = 0
const ba = &columns - len(c) - 2
for i in reverse(range(0, len(e) - 1))
var s = e[i][1]
var d = strdisplaywidth(s)
j += d
if ba < j
const l = ba - j + d
while !empty(s) && l < strdisplaywidth(s)
s = s[1 :]
endwhile
e[i][1] = s
e = e[i : ]
insert(e, ['SpecialKey', '<'], 0)
break
endif
endfor
add(e, ['Normal', repeat(' ', ba - j) .. c])
redraw
ec ''
for m in e
exe 'echohl' m[0]
echon m[1]
endfor
echoh Normal
popup_create(expand('%:p'), { line: &lines - 1, col: 1, minheight: 1, maxheight: 1, minwidth: &columns, pos: 'botleft', moved: 'any' })
enddef
nn <script> <C-g> <ScriptCmd>E()<CR>
set showtabline=0
def F(a: string)
set tabline=%!vimrc#tabline#MyTabline()
set showtabline=2
exe $'normal! g{a}'
au SafeState * ++once au CursorMoved * ++once set showtabline=0
enddef
Each X=t,T nmap gX <SID>(tab)X|nm <SID>(tab)X <ScriptCmd>F('X')<CR><SID>(tab)
def G(a: string)
set tabline=%!vimrc#bufline#MyBufline()
set showtabline=2
const b = bufnr()
while true
exe $'b{a}'
if &buftype !=# 'terminal' || bufnr() ==# b
break
endif
endwhile
au SafeState * ++once au CursorMoved * ++once set showtabline=0
enddef
Each X=n,p nmap gX <SID>(buf)X|nm <SID>(buf)X <ScriptCmd>G('X')<CR><SID>(buf)
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
def H()
if !!bufname()
update
return
endif
const a = strftime('%Y%m%d')
var b = getline(1)
->matchlist('^.\{0,10\}')[0]
->substitute("[ \t\n*?[{`$\\%#'\"|!<>]", '_', 'g')
var c = &ft
if getline(1) =~# '^vim9script\>.*'
c = 'vim'
b = ''
elseif &ft ==# 'markdown' || search('^ *- \[.\] ', 'cn')
b = getline(1)
->substitute('- \[.\]', '', 'g')
->substitute('^[ -#]*', '', 'g')
c = 'md'
elseif &ft ==# 'javascript'
c = 'js'
elseif &ft ==# 'python'
c = 'py'
elseif &ft ==# 'ruby'
c = 'rb'
elseif &ft ==# 'typescript'
c = 'ts'
elseif &ft ==# 'text' || &ft ==# 'help' || !&ft
c = 'txt'
endif
const d = $'{a}{!b ? '' : '_'}{b}.{c}'
const e = input($"{getcwd()}\n:sav ", $'{d}{repeat("\<Left>", len(c) + 1)}')
if !!e
exe 'sav' e
endif
enddef
com! AutoNamingAndSave H()
cno ;n <CR>
Each nnoremap,inoremap ;n <Esc><Cmd>AutoNamingAndSave<CR>
ino ;m <Esc>`^
cno ;m <Esc>
no ;m <Esc>
ino ;v ;<CR>
ino ;w <C-o>e<C-o>a
ino ;k 「」<C-g>U<Left>
ino ;u <Esc>u
nn ;r "
nn ;rr "0p
Each nnoremap,inoremap ;<Tab> <ScriptCmd>g:StayCurPos('normal! >>')<CR>
Each nnoremap,inoremap ;<S-Tab> <ScriptCmd>g:StayCurPos('normal! <<')<CR>
nn <Space>; ;
map! <script> <SID>bs_ <Nop>
map! <script> ;h <SID>bs_h
no! <script> <SID>bs_h <BS><SID>bs_
xn u <ScriptCmd>undo\|normal! gv<CR>
xn <C-R> <ScriptCmd>redo\|normal! gv<CR>
xn <Tab> <ScriptCmd>g:StayCurPos('normal! >gv')<CR>
xn <S-Tab> <ScriptCmd>g:StayCurPos('normal! <gv')<CR>
const vmode = ['v', 'V', "\<C-v>", "\<ESC>"]
xn <script> <expr> v vmode[vmode->index(mode()) + 1]
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
def g:QuitWin(a: string)
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
Each X=h,j,k,l nnoremap qX <ScriptCmd>g:QuitWin('X')<CR>
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
nn <F11> <ScriptCmd>vimrc#myutil#ToggleNumber()<CR>
nn <F12> <Cmd>set wrap!<CR>
nm gs :<C-u>%s///g<Left><Left><Left>
nm gS :<C-u>%s/<C-r>=escape(expand('<cword>'), '^$.*?/\[]')<CR>//g<Left><Left>
xm gs :s///g<Left><Left><Left>
xm gS "vy:<C-u>%s/<C-r>=substitute(escape(@v,'^$.*?/\[]'),"\n",'\\n','g')<CR>//g<Left><Left>
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
def I()
for a in get(w:, 'my_syntax', [])
sil! matchdelete(a)
endfor
w:my_syntax = []
enddef
def J(a: string, b: string)
w:my_syntax->add(matchadd(a, b))
enddef
au vimrc Syntax * I()
au vimrc Syntax javascript {
J('SpellRare', '\s[=!]=\s')
}
au vimrc Syntax vim {
J('SpellRare', '\s[=!]=\s')
J('SpellBad', '\s[=!]==\s')
J('SpellBad', '\s\~[=!][=#]\?\s')
J('SpellRare', '\<normal!\@!')
}
set report=9999
def g:EchoYankText(t: number)
vimrc#echoyanktext#EchoYankText()
enddef
au vimrc TextYankPost * timer_start(1, g:EchoYankText)
def BA()
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
xn <C-g> <ScriptCmd>BA()<CR>
com! -nargs=1 Brep vimrc#myutil#Brep(<q-args>, <q-mods>)
Each $=f,b nmap <C-$> <C-$><SID>(hold-ctrl)
Each $=f,b nnoremap <script> <SID>(hold-ctrl)$ <C-$><SID>(hold-ctrl)
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
if strftime('%d') ==# '01'
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
