vim9script
g:util_each_nest = 0
def! g:UtilEach(a: string)
var [b, d] = a->split('^\S*\zs')
g:util_each_nest += 1
const e = b->split('=')
const f = len(e) ==# 1 ? ['{0\?}'] : e[0]->split(',')
const h = e[-1]->split(',')
const j = match(d, f[0]) !=# -1
var i = 0
while i < h->len()
var c = d
var v = h[i]
if j
for k in f
c = c->substitute(k, v, 'g')
i += 1
endfor
else
c = $'{v} {c}'
i += 1
endif
exe c->substitute($"\{{g:util_each_nest}\}", '{}', 'g')
endwhile
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
packadd vim-reformatdate
packadd vim-textobj-user
packadd vim-headtail
packadd vim-popselect
au vimrc User Vim9skkModeChanged zenmode#Invalidate()
g:vim9skk = {
keymap: {
midasi: ['Q', '; '],
toggle: ['<C-j>', ';j'],
complete: ['<CR>', ';;'],
},
}
nn ;j i<Plug>(vim9skk-enable)
au vimrc User Vim9skkInitPre vimrc#vim9skk#ApplySettings()
au vimrc User Vim9skkEnter feedkeys('Q')
au vimrc ModeChanged [ic]:n au SafeState * ++once vim9skk#Disable()
au vimrc User Vim9skkEnter hi! link vim9skkMidasi PMenuSel
no <Leader>ga ga
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
nn <Space>gA :<C-u><Cmd>call setcmdline($'GitAmend {vimrc#git#GetLastCommitMessage()}')<CR>
nn <Space>gP :<C-u>Git push<End>
nn <Space>gs <Cmd>Git status -sb<CR>
nn <Space>gv <Cmd>Gvdiffsplit<CR>
nn <Space>gd <Cmd>Gdiffsplit<CR>
nn <Space>gp <Cmd>Git pull<CR>
nn <Space>gl <Cmd>Git log<CR>
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
au CmdlineEnter * ++once silent! cunmap <C-r><C-g>
nn <Space>gh <Cmd>e gh://utubo/repos<CR>
au vimrc FileType gh-repos vimrc#gh#ReposKeymap()
au vimrc FileType gh-issues vimrc#gh#IssuesKeymap()
au vimrc FileType gh-issue-comments vimrc#gh#IssueCommentsKeymap()
nn <F1> <ScriptCmd>popselect#dir#Popup()<CR>
nn <F2> <ScriptCmd>popselect#mru#Popup()<CR>
nn <F3> <ScriptCmd>popselect#buffers#Popup()<CR>
nn <F4> <ScriptCmd>popselect#tabpages#Popup()<CR>
nn <C-p> <ScriptCmd>popselect#projectfiles#PopupWithMRU({ filter_focused: true })<CR>
Each X=t,T nnoremap gX gX<Cmd>call popselect#tabpages#Popup()<CR>
def B(a: string)
const b = bufnr()
while true
exe $'b{a}'
if &buftype !=# 'terminal' || bufnr() ==# b
break
endif
endwhile
popselect#buffers#Popup({ extra_show: false })
enddef
Each X=n,p nnoremap gX <ScriptCmd>B('X')<CR>
nn gr <Cmd>buffer #<CR>
nn <Leader>a <Cmd>PortalAim<CR>
nn <Leader>b <Cmd>PortalAim blue<CR>
nn <Leader>o <Cmd>PortalAim orange<CR>
nn <Leader>r <Cmd>PortalReset<CR>
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
Enable g:skipslash_autocomplete
Each X=s,h Each nnoremap,tnoremap <silent> <C-w><C-X> <Plug>(shrink-height)<C-w>w
vimrc#lexima#LazyLoad()
vimrc#lsp#LazyLoad()
Each nmap,xmap S <ScriptCmd>vimrc#sandwich#LazyLoad('S')<CR>
nm s <ScriptCmd>vimrc#easymotion#LazyLoad()<CR>s
com! -nargs=* Fern vimrc#fern#LazyLoad(<q-args>)
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
set mps+=（:）,「:」,『:』,【:】,［:］,＜:＞
Each X=i,a,A nnoremap <expr> X !empty(getline('.')) ? 'X' : '"_cc'
Each X=+,-,>,< Each nmap,tmap <C-w>X <C-w>X<SID>ws
Each X=+,-,>,< Each nnoremap,tnoremap <script> <SID>wsX <C-w>X<SID>ws
Each nmap,tmap <SID>ws <Nop>
nn <A-J> <Cmd>copy.<CR>
nn <A-K> <Cmd>copy-1<CR>
xn <A-J> :copy'<-1<CR>gv
xn <A-K> :copy'>+0<CR>gv
def C(): string
const a = getpos('.')[2]
const b = getline('.')[0 : a - 1]
const c = matchstr(b, '\v<(\k(<)@!)*$')
return toupper(c)
enddef
ino <expr> ;l $"<C-w>{C()}"
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
def D()
setl sw=0
setl st=0
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
setpos('.', b)
enddef
def SetupTabstopLazy()
au vimrc SafeState * ++once D()
enddef
au vimrc BufReadPost * SetupTabstopLazy()
SetupTabstopLazy()
nn <script> <C-g> <ScriptCmd>vimrc#myutil#ShowBufInfo()<CR><ScriptCmd>vimrc#myutil#PopupCursorPos()<CR>
xn <C-g> <ScriptCmd>vimrc#myutil#PopupVisualLength()<CR>
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
def F()
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
com! Sav F()
cno ;n <CR>
Each nnoremap,inoremap ;n <Esc><Cmd>Sav<CR>
no ;m <Esc>
ino ;m <Esc>`^
cno ;m <Cmd>call feedkeys("\e", 'nt')<CR>
ino ;v ;<CR>
ino ;w <C-o>e<C-o>a
ino ;k 「」<C-g>U<Left>
ino ;u <Esc>u
nn ;r "
nn ;rr "0p
cno ;r <C-r>
cno <expr> ;rr trim(@")->substitute('\n', ' \| ', 'g')
cno <expr> ;re escape(@", '~^$.*?/\[]')->substitute('\n', '\\n', 'g')
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
au vimrc CmdlineEnter * ++once vimrc#cmdmode#ApplySettings()
Each n,v {}noremap : <Cmd>call vimrc#cmdmode#Popup()<CR>:
Each /,? nnoremap {} <Cmd>call vimrc#cmdmode#Popup()<CR><Cmd>noh<CR>{}
nn \: :
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
xn g: :<C-u><Cmd>call getregion(getpos('v'), getpos('.'))->setcmdline()<CR><CR>
xn g9 :<C-u>vim9cmd <Cmd>call getregion(getpos('v'), getpos('.'))->setcmdline()<CR><CR>
if has('clipboard')
au vimrc FocusGained * @" = @+
au vimrc FocusLost * @+ = @"
endif
nn <F11> <ScriptCmd>vimrc#myutil#ToggleNumber()<CR>
nn <F12> <Cmd>set wrap!<CR>
nm gs :<C-u>%s///g<Left><Left><Left>
nm gS :<C-u><Cmd>call setcmdline($'%s/{expand('<cword>')->escape('^$.*?/\[]')}//g')<CR><Left><Left>
xm gs :s///g<Left><Left><Left>
xn <SID>(setup-region-to-search) <Cmd>let @/ = $'\V{getregion(getpos('v'), getpos('.'))->join("\n")->escape('\')->substitute("\n", '\n', 'g')}'<CR>
xm gS <SID>(setup-region-to-search)<Esc>:<C-u><Cmd>call setcmdline($'%s/{@/}//g')<CR><Left><Left>
xm * <SID>(setup-region-to-search)<Esc>/<CR>
nn <CR> j0
nn Y y$
nn <Space>p $p
nn <Space>P ^P
Each A,B=j,+,k,- nnoremap <expr> A ((getline('.')->match('\S') + 1 ==# col('.')) ? 'B' : 'A') .. '<Cmd>noh<CR>'
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
nn <silent> <F10> <ESC>1<C-w>s:1<CR><C-w>w
xn <F10> <ESC>1<C-w>s<C-w>w
nn <F9> my
nn <Space><F9> 'y
def G()
for a in get(w:, 'my_syntax', [])
sil! matchdelete(a)
endfor
w:my_syntax = []
enddef
def H(a: string, b: string)
w:my_syntax->add(matchadd(a, b))
enddef
au vimrc Syntax * G()
au vimrc Syntax javascript {
H('SpellRare', '\s[=!]=\s')
}
au vimrc Syntax vim {
H('SpellRare', '\s[=!]=\s')
H('SpellBad', '\s[=!]==\s')
H('SpellBad', '\s\~[=!][=#]\?\s')
H('SpellRare', '\<normal!\@!')
}
set report=9999
def g:EchoYankText(t: number)
vimrc#echoyanktext#EchoYankText()
enddef
au vimrc TextYankPost * timer_start(1, g:EchoYankText)
com! -nargs=1 Brep vimrc#myutil#Brep(<q-args>, <q-mods>)
Each $=f,b nmap <C-$> <C-$><SID>(hold-ctrl)
Each $=f,b nnoremap <script> <SID>(hold-ctrl)$ <C-$><SID>(hold-ctrl)
nm <SID>(hold-ctrl) <Nop>
com! -nargs=1 -complete=packadd HelpPlugins vimrc#myutil#HelpPlugins(<q-args>)
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
echow "✨ Today, Let's enjoy the default key mapping ! ✨"
mapclear
imapclear
xmapclear
cmapclear
omapclear
tmapclear
}
endif
export def LazyLoad()
enddef
