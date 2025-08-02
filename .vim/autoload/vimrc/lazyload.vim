vim9script
def A(a: string)
var [b, d] = a->split('^\S*\zs')
const e = b->split('=')
const f = e[-1]->split(',')
var g = ['<UtilEach>']
if len(e) ==# 1
d = $'{g[0]} {d}'
else
g = e[0]->split(',')
endif
var i = 0
while i < f->len()
var c = d
var v = f[i]
for k in g
c = c->substitute(k, f[i], 'g')
i += 1
endfor
exe c
endwhile
enddef
com! -nargs=* Each A(<q-args>)
com! -nargs=1 -complete=var Enable <args> = 1
com! -nargs=1 -complete=var Disable <args> = 0
def g:System(a: string): string
if !has('win32')
return system(a)
endif
var b = []
var c = job_start(a, {
out_cb: (j, s) => {
b->add(s)
}
})
while job_status(c) ==# 'run'
sleep 10m
endwhile
return join(b, "\n")
enddef
def B(a: string)
const b = getline('.')->len()
var c = getcurpos()
exe $'normal! {a}'
c[2] += getline('.')->len() - b
setpos('.', c)
enddef
var lk = 0
def C(a: string, b: string, c: string, ...d: list<string>)
lk += 1
const e = a->substitute('map', 'noremap', '')
const f = $'<SID>rp{lk}<Space>'
exe $'{a} <script> {f} <Nop>'
exe $'{e} <script> {f}{c} {d->join(' ')}{f}'
exe $'{a} <script> {b}{c} {f}{c}'
enddef
com! -nargs=* RLK C(<f-args>)
packadd lsp
packadd vim-reformatdate
packadd vim-textobj-user
packadd vim-headtail
packadd vim-popselect
au vimrc User Vim9skkModeChanged zenmode#Invalidate()
g:vim9skk = {
keymap: {
enable: ['<LocalLeader>j'],
disable: ['<LocalLeader>a'],
midasi: ['Q'],
midasi_toggle: ['<LocalLeader>j'],
complete: ['<CR>', '<LocalLeader><Space>', '<LocalLeader><LocalLeader>', 'l', ':'],
select_top: '.',
},
run_on_midasi: true,
}
nn <LocalLeader>j a<Plug>(vim9skk-enable)
nn <LocalLeader><LocalLeader>j i<Plug>(vim9skk-enable)
au vimrc User Vim9skkInitPre vimrc#vim9skk#ApplySettings()
au vimrc ModeChanged [ic]:n au SafeState * ++once vim9skk#Disable()
au vimrc User Vim9skkEnter hi! link vim9skkMidasi PMenuSel
au vimrc User Vim9skkMidasiInput {
const m = g:vim9skk_midasi
if m->match('*[っッ]\?[^a-zA-Zっッ]$') !=# -1
feedkeys("\<Space>")
elseif m->match('[^ぁ-わんァ-ヴー]$') !=# -1
feedkeys("\<CR>")
endif
}
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
nn <Space>gs <Cmd>Git status -sb<CR>
nn <Space>gv <Cmd>Gvdiffsplit<CR>
nn <Space>gd <Cmd>Gdiffsplit<CR>
nn <Space>gp <Cmd>Git pull<CR>
nn <Space>gl <Cmd>Git log<CR>
nm <Space>gP :<C-u>Git push<End>
nm <Space>gt :<C-u>GitTagPush<Space>
nm <Space>gC :<C-u>Git checkout %
nm <Space>gc :<C-u>GitCommit<Space><Tab>
nm <Space>gA :<C-u><Cmd>call setcmdline($'GitAmend {vimrc#git#GetLastCommitMessage()}')<CR>
def D()
const a = has('win32') ? '~/_vimrc' : '~/.vimrc'
const b = a->expand()->resolve()->fnamemodify(':h')
const c = getcwd()
chdir(b)
ec g:System($'git pull')
chdir(c)
exe $'source {has('win32') ? '~/vimfiles' : '~/.vim'}/autoload/vimrc/ezpack.vim'
EzpackInstall
enddef
nn <Space>GL <ScriptCmd>D()<CR>
au CmdlineEnter * ++once silent! cunmap <C-r><C-g>
nn <Space>gh <Cmd>e gh://utubo/repos<CR>
au vimrc FileType gh-repos vimrc#gh#ReposKeymap()
au vimrc FileType gh-issues vimrc#gh#IssuesKeymap()
au vimrc FileType gh-issue-comments vimrc#gh#IssueCommentsKeymap()
g:popselect = {
borderchars: ['-', '|', '-', '|', '.', '.', "'", "'"]
}
nn <F1> <ScriptCmd>popselect#dir#Popup()<CR>
nn <F2> <ScriptCmd>popselect#mru#Popup()<CR>
nn <F3> <ScriptCmd>popselect#buffers#Popup()<CR>
nn <F4> <ScriptCmd>popselect#tabpages#Popup()<CR>
nn <expr> <C-p> yankround#is_active() ? "\<Plug>(yankround-prev)" : "\<ScriptCmd>popselect#projectfiles#PopupWithMRU({ filter_focused: true })\<CR>"
def E()
if !vimrc#tabpanel#IsVisible()
popselect#tabpages#Popup()
endif
enddef
Each X=t,T nnoremap gX gX<ScriptCmd>E()<CR>
def F(a: string)
const b = bufnr()
while true
exe $'b{a}'
if &buftype !=# 'terminal' || bufnr() ==# b
break
endif
endwhile
if !vimrc#tabpanel#IsVisible()
popselect#buffers#Popup()
endif
enddef
Each X=n,p nnoremap gX <ScriptCmd>F('X')<CR>
nn gr <C-^>
nn <Leader>a <Cmd>PortalAim<CR>
nn <Leader>b <Cmd>PortalAim blue<CR>
nn <Leader>o <Cmd>PortalAim orange<CR>
nn <Leader>r <Cmd>PortalReset<CR>
nm p <Plug>(yankround-p)
xm p <Plug>(yankround-p)
nm P <Plug>(yankround-P)
nm <C-n> <Plug>(yankround-next)
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
g:registerslite_delay = 0.4
Enable g:skipslash_autocomplete
Each X=s,h Each nnoremap,tnoremap <silent> <C-w><C-X> <Plug>(shrink-height)<C-w>w
vimrc#lexima#LazyLoad()
vimrc#lsp#LazyLoad()
Each nmap,xmap S <ScriptCmd>vimrc#sandwich#LazyLoad('S')<CR>
nm s <ScriptCmd>vimrc#easymotion#LazyLoad()<CR>s
Each key=<Leader>j,<Leader>k map key <ScriptCmd>vimrc#easymotion#LazyLoad()<CR>key
packadd hlyank
packadd comment
nm <Space>c gcc
xm <Space>c gc
Enable g:rainbow_active
g:auto_cursorline_wait_ms = &ut
Each X=w,b,e,ge nnoremap X <Plug>(smartword-X)
nn [c <Plug>(GitGutterPrevHunk)
nn ]c <Plug>(GitGutterNextHunk)
vm mj <Plug>MoveBlockDown
vm mk <Plug>MoveBlockUp
g:vimhelpgenerator_version = ''
g:vimhelpgenerator_author = 'Author  : utubo'
g:vimhelpgenerator_defaultlanguage = 'en'
g:vimhelpgenerator_uri = 'https://github.com/utubo/'
au vimrc InsertLeave * set nopaste
au vimrc FileReadPost *.log* normal! G
set mps+=（:）,「:」,『:』,【:】,［:］,＜:＞
Each X=i,a,A nnoremap <expr> X !empty(getline('.')) ? 'X' : '"_cc'
Each X=+,-,>,<lt> Each Y=nmap,tmap RLK Y <C-w> X <C-w>X
Each X=+,-,>,<lt> Each Y=nmap,tmap RLK Y <C-w> X <C-w>X
nn <A-J> <Cmd>copy.<CR>
nn <A-K> <Cmd>copy-1<CR>
xn <A-J> :copy'<-1<CR>gv
xn <A-K> :copy'>+0<CR>gv
def G(): string
const a = getpos('.')[2]
const b = getline('.')[0 : a - 1]
const c = matchstr(b, '\v<(\k(<)@!)*$')
return toupper(c)
enddef
ino <expr> ;l $"<C-w>{G()}"
au vimrc TextYankPost * execute $'au SafeState * ++once execute "normal! m{v:event.operator}"'
g:maplocalleader = ';'
nn <Space><LocalLeader> ;
no <Space><LocalLeader> ;
Each map,imap,cmap <LocalLeader>n <LocalLeader>(ok)
Each map,imap,cmap <LocalLeader>m <LocalLeader>(cancel)
Each nnoremap,inoremap <LocalLeader>(ok) <Esc><Cmd>Sav<CR>
no <LocalLeader>(cancel) <Esc>
ino <LocalLeader>(cancel) <Esc>`^
nm <LocalLeader>w <C-w>
nn <LocalLeader>v <C-v>
nn <LocalLeader>a <C-a>
nn <LocalLeader>x <C-a>
ino <LocalLeader>v ;<CR>
ino <LocalLeader>w <C-o>e<C-o>a
ino <LocalLeader>k 「」<C-g>U<Left>
ino <LocalLeader>u <Esc>u
nn <LocalLeader>r "
nn <LocalLeader>rr "0p
RLK nmap <LocalLeader> <Tab> <ScriptCmd>B('>>')<CR>
RLK nmap <LocalLeader> <S-Tab> <ScriptCmd>B('<<')<CR>
RLK map! <LocalLeader> b <BS>
RLK map! <LocalLeader> h <Left>
RLK map! <LocalLeader> l <Right>
nn <Space>e G?\cErr\\|Exception<CR>
nn <expr> <Space>f $'{(getreg('"') =~ '^\d\+$' ? ':' : '/')}{getreg('"')}<CR>'
nm <Space>. :
nm <Space>; :
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
xn u <ScriptCmd>undo\|normal! gv<CR>
xn <C-R> <ScriptCmd>redo\|normal! gv<CR>
xn <Tab> <ScriptCmd>B('>gv')<CR>
xn <S-Tab> <ScriptCmd>B('<gv')<CR>
const vmode = ['v', 'V', "\<C-v>", "\<ESC>"]
xn <script> <expr> v vmode[vmode->index(mode()) + 1]
Each nmap,xmap <LocalLeader>c :
Each nmap,xmap <LocalLeader>s /
Each nmap,xmap + :
Each nmap,xmap , :
Each nmap,xmap <Space><Space>, ,
au vimrc CmdlineEnter * ++once vimrc#cmdmode#ApplySettings()
Each X=n,v Xnoremap : <Cmd>call vimrc#cmdmode#Popup()<CR>:
Each X=/,? nnoremap X <Cmd>call vimrc#cmdmode#Popup()<CR><Cmd>noh<CR>X
Each X=:,/,? nnoremap <Leader>X X
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
def H()
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
au vimrc SafeState * ++once H()
enddef
au vimrc BufReadPost * SetupTabstopLazy()
SetupTabstopLazy()
nn <script> <C-g> <ScriptCmd>vimrc#myutil#ShowBufInfo()<CR><ScriptCmd>vimrc#myutil#PopupCursorPos()<CR>
xn <C-g> <ScriptCmd>vimrc#myutil#PopupVisualLength()<CR>
def J()
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
com! Sav J()
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
au vimrc BufHidden * {
const b = getbufinfo('%')[0]
if !b.name && !b.changed
timer_start(0, (_) => execute($'silent! bdelete {b.bufnr}'))
endif
}
cno <script> <expr> <SID>(exec_line) $'{getline('.')->substitute('^[ \t"#:]\+', '', '')}<CR>'
nn <script> g: :<C-u><SID>(exec_line)
nn <script> g9 :<C-u>vim9cmd <SID>(exec_line)
xn g: :<C-u><Cmd>call getregion(getpos('v'), getpos('.'))->setcmdline()<CR><CR>
xn g9 :<C-u>vim9cmd <Cmd>call getregion(getpos('v'), getpos('.'))->setcmdline()<CR><CR>
vimrc#ruler#Apply()
if has('clipboard')
au vimrc FocusGained * @" = @+
au vimrc FocusLost * @+ = @"
endif
au vimrc WinEnter * if winnr('$') ==# 1 && &buftype ==# 'quickfix'|q|endif
nn <F10> <ScriptCmd>vimrc#tabpanel#Toggle()<CR>
nn <F11> <Cmd>set number!<CR>
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
nn TB <Cmd>tabnew %<CR>g;
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
set spell spelllang=en_us,cjk
nn <F8> <Cmd>set spell! spell?<CR>
nn <silent> <F9> <ESC>1<C-w>s:1<CR><C-w>w
xn <F9> <ESC>1<C-w>s<C-w>w
nn <F7> my
nn <Space><F7> 'y
def BA()
for a in get(w:, 'my_syntax', [])
sil! matchdelete(a)
endfor
w:my_syntax = []
enddef
def BB(a: string, b: string)
w:my_syntax->add(matchadd(a, b))
enddef
au vimrc Syntax * BA()
au vimrc Syntax javascript {
BB('SpellRare', '\s[=!]=\s')
}
au vimrc Syntax vim {
BB('SpellRare', '\s[=!]=\s')
BB('SpellBad', '\s[=!]==\s')
BB('SpellBad', '\s\~[=!][=#]\?\s')
BB('SpellRare', '\<normal!\@!')
}
com! -nargs=1 Brep vimrc#myutil#Brep(<q-args>, <q-mods>)
nn <Tab> >
nn <Tab><Tab> >>
nn <S-Tab> <
nn <S-Tab><S-Tab> <<
nn <C-k> <C-i>
nn ]t <C-]>
nn [t <C-t>
com! -nargs=1 -complete=packadd HelpPlugins vimrc#myutil#HelpPlugins(<q-args>)
ono A <Plug>(textobj-twochars-a)
ono I <Plug>(textobj-twochars-i)
nm <LocalLeader><LocalLeader>a <F1>
nm <LocalLeader><LocalLeader>s <F2>
nm <LocalLeader><LocalLeader>d <F3>
nm <LocalLeader><LocalLeader>f <F4>
nn <Space>w <C-w>w
nn <Space>o <C-w>w
nn <Space>d "_d
au vimrc FileType tsv,csv {
nn <buffer> <Tab> <Cmd>call search('\(^\\|\t\\|, *\)\S\?', 'e')<CR>
nn <buffer> <S-Tab> <Cmd>call search('\(^\\|\t\\|, *\)\S\?', 'be')<CR>
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
