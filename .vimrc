vim9script
set enc=utf-8
scripte utf-8
set fencs=ucs-bom,utf-8,iso-2022-jp,cp932,euc-jp
set noet
set ts=3
set shiftwidth=0
set st=0
set ai
set si
set bri
set nf=alpha,hex
set ve=block
set list
set lcs=tab:\|\ ,trail:-,extends:>,precedes:<,nbsp:%
set fcs=
set ls=2
set ru
set display=lastline
set ambw=double
set bo=all
set ttm=50
set wmnu
set acd
set bsk=/var/tmp/*
set udir=~/.vim/undo
set undofile
set is
set hls
noh
aug vimrc
au!
aug End
def A(b: string)
const q = b->substitute('^\S*', '', '')
for c in b->matchstr('^\S*')->split(',')
const a = q
->substitute('<if-' .. c .. '>', '<>', 'g')
->substitute('<if-.\{-1,}\(<if-\|<>\|$\)', '', 'g')
->substitute('<>', '', 'g')
exe c .. a
endfor
enddef
com! -nargs=* MultiCmd A(<q-args>)
com! -nargs=1 -complete=var Enable <args> = 1
com! -nargs=1 -complete=var Disable <args> = 0
def B(a: number)
exe 'silent! ' .. a .. 's/\s\+$//'
exe 'silent! ' .. a .. 's/^\s*\n//'
enddef
def C(): bool
return &modified || ! empty(bufname())
enddef
def D(a: any): string
return matchstr(getline(a), '^\s*')
enddef
def E(): string
const a = @"
sil normal! gvy
const b = @"
@" = a
return b
enddef
const lk = has('win32') ? '~/vimfiles' : '~/.vim'
const ll = executable('deno')
const lm = expand(lk .. '/pack/jetpack/opt/vim-jetpack/plugin/jetpack.vim')
const ln = filereadable(lm)
if ! ln
const lo = 'https://raw.githubusercontent.com/tani/vim-jetpack/master/plugin/jetpack.vim'
system(printf('curl -fsSLo %s --create-dirs %s', lm, lo))
endif
packadd vim-jetpack
jetpack#begin()
Jetpack 'tani/vim-jetpack', { 'opt': 1 }
Jetpack 'airblade/vim-gitgutter'
Jetpack 'alvan/vim-closetag'
Jetpack 'ctrlpvim/ctrlp.vim'
Jetpack 'cohama/lexima.vim'
Jetpack 'delphinus/vim-auto-cursorline'
Jetpack 'dense-analysis/ale'
Jetpack 'easymotion/vim-easymotion'
Jetpack 'hrsh7th/vim-vsnip'
Jetpack 'hrsh7th/vim-vsnip-integ'
Jetpack 'itchyny/lightline.vim'
Jetpack 'kana/vim-textobj-user'
Jetpack 'luochen1990/rainbow'
Jetpack 'machakann/vim-sandwich'
Jetpack 'mattn/ctrlp-matchfuzzy'
Jetpack 'mattn/vim-notification'
Jetpack 'matze/vim-move'
Jetpack 'mechatroner/rainbow_csv'
Jetpack 'michaeljsmith/vim-indent-object'
Jetpack 'osyo-manga/vim-textobj-multiblock'
Jetpack 'othree/html5.vim'
Jetpack 'othree/yajs.vim'
Jetpack 'prabirshrestha/asyncomplete-buffer.vim'
Jetpack 'prabirshrestha/asyncomplete.vim'
Jetpack 'rafamadriz/friendly-snippets'
Jetpack 'thinca/vim-portal'
Jetpack 'tpope/vim-fugitive'
Jetpack 'tyru/caw.vim'
Jetpack 'yami-beta/asyncomplete-omni.vim'
Jetpack 'yegappan/mru'
Jetpack 'utubo/jumpcuorsor.vim'
Jetpack 'utubo/vim-colorscheme-girly'
Jetpack 'utubo/vim-minviml'
Jetpack 'utubo/vim-textobj-twochars'
Jetpack 'utubo/vim-reformatdate'
Jetpack 'utubo/vim-tabpopupmenu'
Jetpack 'utubo/vim-tabtoslash'
Jetpack 'utubo/vim-portal-aim'
Jetpack 'utubo/vim-shrink'
Jetpack 'utubo/vim-tablist'
if ll
Jetpack 'vim-denops/denops.vim'
Jetpack 'vim-skk/skkeleton'
endif
jetpack#end()
if ! ln
jetpack#sync()
endif
Enable g:EasyMotion_smartcase
Enable g:EasyMotion_use_migemo
Enable g:EasyMotion_enter_jump_first
Disable g:EasyMotion_do_mapping
g:EasyMotion_keys = 'asdghklqwertyuiopzxcvbnmfjASDGHKLQWERTYUIOPZXCVBNMFJ;'
map s <Plug>(easymotion-s)
au vimrc VimEnter,BufEnter * EMCommandLineNoreMap <Space><Space> <Esc>
g:sandwich#recipes = deepcopy(g:sandwich#default_recipes)
g:sandwich#recipes += [
{ buns: ["\r", '' ], input: ["\r"], command: ["normal! a\r"] },
{ buns: ['', '' ], input: ['q'] },
{ buns: ['「', '」'], input: ['k'] },
{ buns: ['>', '<' ], input: ['>'] },
{ buns: ['{ ', ' }'], input: ['{'] },
{ buns: ['${', '}' ], input: ['${'] },
{ buns: ['%{', '}' ], input: ['%{'] },
{ buns: ['CommentString(0)', 'CommentString(1)'], expr: 1, input: ['c'] },
]
def! g:CommentString(a: number): string
return &commentstring->split('%s')->get(a, '')
enddef
Enable g:sandwich_no_default_key_mappings
Enable g:operator_sandwich_no_default_key_mappings
MultiCmd nmap,vmap Sd <Plug>(operator-sandwich-delete)<if-nmap>ab
MultiCmd nmap,vmap Sr <Plug>(operator-sandwich-replace)<if-nmap>ab
MultiCmd nmap,vmap Sa <Plug>(operator-sandwich-add)<if-nmap>iw
MultiCmd nmap,vmap S <Plug>(operator-sandwich-add)<if-nmap>iw
nm S^ v^S
nm S$ vg_S
nm <expr> SS (matchstr(getline('.'), '[''"]', getpos('.')[2]) ==# '"') ? 'Sr"''' : 'Sr''"'
def F()
var c = g:operator#sandwich#object.cursor
if g:fix_sandwich_pos[1] != c.inner_head[1]
c.inner_head[2] = getline(c.inner_head[1])->match('\S') + 1
c.inner_tail[2] = getline(c.inner_tail[1])->match('$') + 1
endif
enddef
au vimrc User OperatorSandwichAddPre g:fix_sandwich_pos = getpos('.')
au vimrc User OperatorSandwichAddPost F()
def G()
setpos("'<", g:operator#sandwich#object.cursor.inner_head)
setpos("'>", g:operator#sandwich#object.cursor.inner_tail)
enddef
nm <silent> S. :<C-u>call <SID>G()<CR>gvSa
var lp = []
def H(a: bool = false)
const c = a ? g:operator#sandwich#object.cursor.inner_head[1 : 2] : []
if ! a || lp !=# c
lp = c
au vimrc User OperatorSandwichAddPost ++once H(true)
feedkeys(a ? 'S.' : 'gvSa')
endif
enddef
nm Sm viwSm
vm <silent> Sm :<C-u>call <SID>H()<CR>
def I()
const c = g:operator#sandwich#object.cursor
B(c.tail[1])
B(c.head[1])
enddef
au vimrc User OperatorSandwichDeletePost I()
g:MRU_Filename_Format = {
formatter: 'fnamemodify(v:val, ":t") . " > " . v:val',
parser: '> \zs.*',
syntax: '^.\{-}\ze >'
}
def J(a: bool)
b:use_tab = a
setl number
redraw
echoh Question
ec printf('[1]..[9] => open with a %s.', a ? 'tab' : 'window')
echoh None
const c = a ? 't' : '<CR>'
for i in range(1, 9)
exe printf('nmap <buffer> <silent> %d :<C-u>%d<CR>%s', i, i, c)
endfor
enddef
def BA()
Enable b:auto_cursorline_disabled
setl cursorline
nn <buffer> <silent> w :<C-u>call <SID>J(!b:use_tab)<CR>
nn <buffer> R :<C-u>MruRefresh<CR>:normal u<CR>
J(C())
enddef
au vimrc FileType mru BA()
au vimrc ColorScheme * hi link MruFileName Directory
nn <silent> <F2> :<C-u>MRUToggle<CR>
g:MRU_Exclude_Files = has('win32') ? $TEMP .. '\\.*' : '^/tmp/.*\|^/var/tmp/.*'
def BB(a: string, b: list<string>, c: list<string>)
exe printf("asyncomplete#register_source(asyncomplete#sources#%s#get_source_options({ name: '%s', whitelist: %s, blacklist: %s, completor: asyncomplete#sources#%s#completor }))", a, a, b, c, a)
enddef
BB('omni', ['*'], ['c', 'cpp', 'html'])
BB('buffer', ['*'], ['go'])
MultiCmd imap,smap <expr> JJ vsnip#expandable() ? '<Plug>(vsnip-expand)' : 'JJ'
MultiCmd imap,smap <expr> <C-l> vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
MultiCmd imap,smap <expr> <Tab> vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : pumvisible() ? '<C-n>' : '<Tab>'
MultiCmd imap,smap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : pumvisible() ? '<C-p>' : '<S-Tab>'
Enable g:lexima_accept_pum_with_enter
Enable g:ale_set_quickfix
Enable g:ale_fix_on_save
Disable g:ale_lint_on_insert_leave
Disable g:ale_set_loclist
g:ale_sign_error = '🐞'
g:ale_sign_warning = '🐝'
g:ale_fixers = { typescript: ['deno'] }
g:ale_lint_delay = 3000
nm <silent> [a <Plug>(ale_previous_wrap)
nm <silent> ]a <Plug>(ale_next_wrap)
g:ll_reg = ''
def BC()
var a = substitute(v:event.regcontents[0], '\t', ' ', 'g')
if len(v:event.regcontents) !=# 1 || len(a) > 10
a = substitute(a, '^\(.\{0,8\}\).*', '\1..', '')
endif
g:ll_reg = '📎[' .. a .. ']'
enddef
au vimrc TextYankPost * BC()
g:ll_tea_break = '0:00'
g:ll_tea_break_opentime = localtime()
def! g:VimrcTimer60s(a: any)
const b = (localtime() - g:ll_tea_break_opentime) / 60
const c = b % 60
const d = c >= 45 ? '☕🍴🍰' : ''
g:ll_tea_break = d .. printf('%d:%02d', b / 60, c)
lightline#update()
if (c == 45)
notification#show("       ☕🍴🍰\nHave a break time !")
endif
enddef
timer_stop(get(g:, 'vimrc_timer_60s', 0))
g:vimrc_timer_60s = timer_start(60000, 'VimrcTimer60s', { repeat: -1 })
if has('win32')
def! g:LLFF(): string
return &ff !=# 'dos' ? &ff : ''
enddef
else
def! g:LLFF(): string
return &ff ==# 'dos' ? &ff : ''
enddef
endif
def! g:LLNotUtf8(): string
return &fenc ==# 'utf-8' ? '' : &fenc
enddef
g:lightline = {
colorscheme: 'wombat',
active: { right: [['teabreak'], ['ff', 'notutf8', 'li'], ['reg']] },
component: { teabreak: '%{g:ll_tea_break}', reg: '%{g:ll_reg}', li: '%2c,%l/%L' },
component_function: { ff: 'LLFF', notutf8: 'LLNotUtf8' },
}
au vimrc VimEnter * set tabline=
if ll
if ! empty($SKK_JISYO_DIR)
skkeleton#config({
globalJisyo: expand($SKK_JISYO_DIR .. 'SKK-JISYO.L'),
userJisyo: expand($SKK_JISYO_DIR .. '.skkeleton'),
})
endif
skkeleton#config({
eggLikeNewline: true,
keepState: true,
showCandidatesCount: 1,
})
map! <C-j> <Plug>(skkeleton-toggle)
endif
om ab <Plug>(textobj-multiblock-a)
om ib <Plug>(textobj-multiblock-i)
xm ab <Plug>(textobj-multiblock-a)
xm ib <Plug>(textobj-multiblock-i)
g:textobj_multiblock_blocks = [ [ "(", ")" ], [ "[", "]" ], [ "{", "}" ], [ '<', '>' ], [ '"', '"', 1 ], [ "'", "'", 1 ], [ ">", "<", 1 ], [ "「", "」", 1 ],
]
nn <Leader>a :<C-u>PortalAim<CR>
nn <Leader>b :<C-u>PortalAim blue<CR>
nn <Leader>o :<C-u>PortalAim orange<CR>
nn <Leader>r :<C-u>PortalReset<CR>
Enable g:rainbow_active
g:auto_cursorline_wait_ms = 3000
g:ctrlp_match_func = {'match': 'ctrlp_matchfuzzy#matcher'}
g:ctrlp_cmd = 'CtrlPMixed'
nn <silent> <Space>gv :<C-u>Gvdiffsplit<CR>
nn <silent> <Space>gd :<C-u>Gdiffsplit<CR>
nn <Space>ga :<C-u>Git add %
nn <Space>gc :<C-u>Git commit -m ''<Left>
nn <Space>gp :<C-u>Git push
nn <Space>gl :<C-u>Git pull<CR>
nn <silent> <Space>t :<C-u>call tabpopupmenu#popup()<CR>
nn <silent> <Space>T :<C-u>call tablist#Show()<CR>
MultiCmd nmap,vmap <Space>c <Plug>(caw:hatpos:toggle)
MultiCmd nmap,tmap <silent> <C-w><C-s> <Plug>(shrink-height)<C-w>w
MultiCmd nmap,tmap <silent> <C-w><C-h> <Plug>(shrink-width)<C-w>w
nm <Space>s <Plug>(jumpcursor-jump)
const lq = expand(lk .. '/pack/local/opt/*')
if lq !=# ''
&runtimepath = substitute(lq, '\n', ',', 'g') .. ',' .. &runtimepath
endif
filetype plugin indent on
au vimrc InsertLeave * set nopaste
au vimrc BufReadPost *.log* normal! G
vn <silent> * "vy/\V<C-r>=substitute(escape(@v,'\/'),"\n",'\\n','g')<CR><CR>
ino kj <Esc>`^
ino kk <Esc>`^
ino <CR> <CR><C-g>u
set matchpairs+=（:）,「:」,『:』,【:】,［:］,＜:＞
nn <expr> i len(getline('.')) !=# 0 ? 'i' : '"_cc'
nn <expr> a len(getline('.')) !=# 0 ? 'a' : '"_cc'
nn <expr> A len(getline('.')) !=# 0 ? 'A' : '"_cc'
def BD()
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
au vimrc BufReadPost * BD()
def BE(a: string, ...b: list<string>)
var c = join(b, ' ')
if empty(c)
c = expand('%:e') ==# '' ? '*' : ('*.' .. expand('%:e'))
endif
const d = C() && c !=# '%'
if d
tabnew
endif
exe printf('silent! lvimgrep %s %s', a, c)
if ! empty(getloclist(0))
lwindow
else
echoh ErrorMsg
echom 'Not found.: ' .. a
echoh None
if d
tabn -
tabc +
endif
endif
enddef
com! -nargs=+ MyVimgrep BE(<f-args>)
nn <Space>/ :<C-u>MyVimgrep<Space>
def BF()
nn <buffer> <silent> ; <CR>:silent! normal! zv<CR><C-W>w
nn <buffer> <silent> w <C-W><CR>:silent! normal! zv<CR><C-W>w
nn <buffer> <silent> t <C-W><CR>:silent! normal! zv<CR><C-W>T
nn <buffer> <silent> <nowait> q :<C-u>lexpr ''<CR>:q<CR>
nn <buffer> f <C-f>
nn <buffer> b <C-b>
exe printf('nnoremap <buffer> T <C-W><CR><C-W>T%dgt', tabpagenr())
enddef
au vimrc FileType qf BF()
au vimrc WinEnter * if winnr('$') == 1 && &buftype ==# 'quickfix'|q|endif
set splitright
set fcs+=diff:\ 
au vimrc WinEnter * if (winnr('$') == 1) && !!getbufvar(winbufnr(0), '&diff')|diffoff|endif
ino <F5> <C-r>=strftime('%Y/%m/%d')<CR>
cno <F5> <C-r>=strftime('%Y%m%d')<CR>
nn <silent> <F5> :<C-u>call reformatdate#reformat(localtime())<CR>
nn <silent> <C-a> <C-a>:call reformatdate#reformat()<CR>
nn <silent> <C-x> <C-x>:call reformatdate#reformat()<CR>
nn <Space><F5> /\d\{4\}\/\d\d\/\d\d<CR>
nn <Space>zz :<C-u>q!<CR>
nn <Space>e G?\cErr\\|Exception<CR>
nn <Space>y yiw
nn <expr> <Space>f (@" =~ '^\d\+$' ? ':' : '/').@" .. "\<CR>"
nm <Space>, :
for i in range(1, 10)
exe printf('nmap <Space>%d <F%d>', i % 10, i)
endfor
nm <Space><Space>1 <F11>
nm <Space><Space>2 <F12>
def BG(): string
const x = getline('.')->match('\S') + 1
if x != 0 || !exists('w:my_hat')
w:my_hat = col('.') == x ? '^' : ''
endif
return w:my_hat
enddef
nn <expr> j 'j' .. <SID>BG()
nn <expr> k 'k' .. <SID>BG()
def! g:MyFoldText(): string
const a = getline(v:foldstart)
const b = repeat(' ', indent(v:foldstart))
const c = &foldmethod ==# 'indent' ? '' : a->substitute(matchstr(&foldmarker, '^[^,]*'), '', '')->trim()
return b .. c .. '📁'
enddef
set foldtext=g:MyFoldText()
set fcs+=fold:\ 
au vimrc ColorScheme * hi! link Folded Delimiter
def BH()
if line("'<") != line('.')
return
endif
const a = line("'<")
const b = line("'>")
exe ':' a 's/\v(\S)?$/\1 /'
exe ':' b "normal! o\<Esc>i" .. D(a)
cursor([a, 1])
normal! V
cursor([b + 1, 1])
normal! zf
enddef
vn <silent> zf :call <SID>BH()<CR>
def BI()
if foldclosed(line('.')) == -1
normal! zc
endif
const a = foldclosed(line('.'))
const b = foldclosedend(line('.'))
if a == -1
return
endif
const c = getpos('.')
normal! zd
B(b)
B(a)
setpos('.', c)
enddef
nn <silent> zd :Zd()<CR>
set foldmethod=marker
au vimrc FileType markdown,yaml setlocal foldlevelstart=99|setl foldmethod=indent
au vimrc BufReadPost * :silent! normal! zO
nn <expr> h (col('.') == 1 && 0 < foldlevel('.') ? 'zc' : 'h')
nn Z<Tab> :<C-u>set foldmethod=indent<CR>
nn Z{ :<C-u>set foldmethod=marker<CR>
nn Zy :<C-u>set foldmethod=syntax<CR>
def BJ(a: string)
const b = getcurpos()
exe a
setpos('.', b)
enddef
vn u <Cmd>call <SID>BJ('undo')<CR>
vn <C-R> <Cmd>call <SID>BJ('redo')<CR>
vn <Tab> <Cmd>normal! >gv<CR>
vn <S-Tab> <Cmd>normal! <gv<CR>
cno <C-h> <Space><BS><Left>
cno <C-l> <Space><BS><Right>
cno <C-r><C-r> <C-r>=trim(@")<CR>
nn q; :q
nn ; :
vn ; :
nn <Space>; ;
cnoreabbrev cs colorscheme
cno kk <C-c>
cno <expr> jj (empty(getcmdline()) && getcmdtype() == ':' ? 'update<CR>' : '<CR>')
ino ;jj <Esc>`^:update<CR>
if has('win32')
com! Powershell :bo terminal ++close pwsh
nn <silent> SH :<C-u>Powershell<CR>
nn <silent> <S-F1> :<C-u>silent !start explorer %:p:h<CR>
else
nn <silent> SH :<C-u>bo terminal<CR>
endif
tno <C-w>; <C-w>:
tno <C-w><C-w> <C-w>w
tno <C-w>q exit
tno <C-w><C-q> <C-w>:quit!<CR>
def CA()
const a = getline('.')
var b = substitute(a, '^\(\s*\)- \[ \]', '\1- [x]', '')
if a ==# b
b = substitute(a, '^\(\s*\)- \[x\]', '\1- [ ]', '')
endif
if a ==# b
b = substitute(a, '^\(\s*\)\(- \)*', '\1- [ ] ', '')
endif
setline('.', b)
var c = getpos('.')
c[2] += len(b) - len(a)
setpos('.', c)
enddef
no <silent> <Space>x :call <SID>CA()<CR>
def CB(a: bool = true)
if &ft ==# 'qf'
return
endif
if a && ! filereadable(expand('%'))
return
endif
var b = []
add(b, ['Title', '"' .. bufname() .. '"'])
add(b, ['Normal', ' '])
if &modified
add(b, ['Delimiter', '[+]'])
add(b, ['Normal', ' '])
endif
if !a
add(b, ['Tag', '[New]'])
add(b, ['Normal', ' '])
endif
if &readonly
add(b, ['WarningMsg', '[RO]'])
add(b, ['Normal', ' '])
endif
const w = wordcount()
if a || w.bytes !=# 0
add(b, ['Constant', printf('%dL, %dB', w.bytes ==# 0 ? 0 : line('$'), w.bytes)])
add(b, ['Normal', ' '])
endif
add(b, ['MoreMsg', printf('%s %s %s', &ff, (empty(&fenc) ? &enc : &fenc), &ft)])
var c = 0
const e = &columns - 2
for i in reverse(range(0, len(b) - 1))
var s = b[i][1]
var d = strdisplaywidth(s)
c += d
if e < c
const l = e - c + d
while !empty(s) && l < strdisplaywidth(s)
s = s[1 :]
endwhile
b[i][1] = s
b = b[i : ]
insert(b, ['NonText', '<'], 0)
break
endif
endfor
redraw
for m in b
exe 'echohl' m[0]
echon m[1]
endfor
echoh Normal
redraw
enddef
no <silent> <C-g> :<C-u>call <SID>CB()<CR>
au vimrc BufNewFile * CB(false)
au vimrc BufReadPost * CB(true)
def CC(a: string = '')
if ! empty(a)
if winnr() == winnr(a)
return
endif
exe 'wincmd ' .. a
endif
if mode() ==# 't'
quit!
else
confirm quit
endif
enddef
nn <silent> qh :<C-u>call <SID>CC('h')<CR>
nn <silent> qj :<C-u>call <SID>CC('j')<CR>
nn <silent> qk :<C-u>call <SID>CC('k')<CR>
nn <silent> ql :<C-u>call <SID>CC('l')<CR>
nn <silent> qq :<C-u>call <SID>CC()<CR>
nn q <Nop>
nn q: q:
nn q/ q/
nn q? q?
nn Q q
def CD(a: string)
const b = expand('%')
const c = expand(a)
if ! empty(b) && filereadable(b)
if filereadable(c)
echoh Error
ec 'file "' .. a .. '" already exists.'
echoh None
return
endif
rename(b, c)
endif
exe 'saveas! ' .. c
edit
enddef
com! -nargs=1 -complete=file MoveFile call <SID>CD(<f-args>)
cnoreabbrev mv MoveFile
def CE()
var a = execute('reg')
->substitute('\^I', '›', 'g')
->substitute('\^J', '↵', 'g')
->split('\n')
popup_atcursor(a, {
cursorline: true,
mapping: 0,
maxwidth: 40,
moved: 'any',
wrap: false,
filter: (id, key) => {
if key ==# "\<C-n>" || key ==# "\<TAB>"
return popup_filter_menu(id, 'j')
elseif key ==# "\<C-p>" || key ==# "\<S-TAB>"
return popup_filter_menu(id, 'k')
elseif key ==# "\<CR>" || key ==# " "
return popup_filter_menu(id, ' ')
else
popup_close(id, -1)
feedkeys('"' .. key, 'n')
return true
endif
},
callback: (id, result) => {
if result <= 1
return
endif
var m = matchlist(a[result - 1], '^\s*\S\s*"\(.\)')
feedkeys('"' .. m[1], 'n')
},
})
enddef
nn <silent> " :<C-u>call <SID>CE()<CR>
nn <expr> g: ":\<C-u>" .. substitute(getline('.'), '^[\t "#:]\+', '', '') .. "\<CR>"
nn <expr> g9 ":\<C-u>vim9cmd " .. substitute(getline('.'), '^[\t "#:]\+', '', '') .. "\<CR>"
vn g: "vy:<C-u><C-r>=@v<CR><CR>
vn g9 "vy:<C-u>vim9cmd <C-r>=@v<CR><CR>
nn <expr> <Space>gh ':<C-u>hi ' .. substitute(synIDattr(synID(line('.'), col('.'), 1), 'name'), '^$', 'Normal', '') .. '<CR>'
if has('clipboard')
au vimrc FocusGained * @" = @+
au vimrc FocusLost * @+ = @"
endif
nn <silent> <F11> :<C-u>set number! \| let &cursorline=&number<CR>
nn <silent> <F12> :<C-u>set wrap! wrap?<CR>
exe 'nnoremap gs :<C-u>%s///g \| nohlsearch' .. repeat('<Left>', 16)
exe 'vnoremap gs :s///g \| nohlsearch' .. repeat('<Left>', 16)
exe 'nnoremap gS :<C-u>%s/<C-r>=escape(expand("<cword>"), "^$.*?/\[]")<CR>//g \| nohlsearch' .. repeat('<Left>', 15)
nn Y y$
nn <Space>p $p
nn <Space>P ^P
nn <Space><Space>p o<Esc>P
nn <Space><Space>P O<Esc>p
nn TE :<C-u>tabe<Space>
nn TN :<C-u>tabnew<CR>
nn TD :<C-u>tabe ./<CR>
ono <expr> } '<Esc>m`0' .. v:count1 .. v:operator .. '}``'
ono <expr> { '<Esc>m`V' .. v:count1 .. '{' .. v:operator .. '``'
vn <expr> h mode() ==# 'V' ? "\<Esc>h" : 'h'
vn <expr> l mode() ==# 'V' ? "\<Esc>l" : 'l'
vn J j
vn K k
ino <C-r><C-r> <C-r>"
ino ｋｊ <Esc>`^
ino 「 「」<Left>
ino 「」 「」<Left>
ino （ ()<Left>
ino （） ()<Left>
au vimrc FileType vim if getline(1) ==# 'vim9script'|&commentstring = '#%s'|endif
nm <CR> <Space>
vn <expr> p '"_s<C-R>' .. v:register .. '<ESC>'
vn P p
nn <Space>h ^
nn <Space>l $
nn <Space>d "_d
cno <C-r><C-e> <C-r>=escape(@", '^$.*?/\[]')<CR><Right>
nn / :<C-u>nohlsearch<CR>/
nn ? :<C-u>nohlsearch<CR>?
nn <silent> <Space>n :<C-u>nohlsearch<CR>
au vimrc CursorHold * feedkeys(" n")
nn <Space>w <C-w>w
nn <Space>o <C-w>w
nn <silent> <F10> <ESC>1<C-w>s:1<CR><C-w>w
vn <F10> <ESC>1<C-w>s<C-w>w
nn ' "
nn <Space>' '
ino jj <C-o>
ino jjh <C-o>^
ino jjl <C-o>$
ino jje <C-o>e<C-o>a
ino jj; <C-o>$;
ino jj, <C-o>$,
ino jj{ <C-o>$ {
ino jj} <C-o>$ }
ino jj<CR> <C-o>$<CR>
ino jjk 「」<Left>
ino jjx <Cmd>call <SID>CA()<CR>
ino <M-h> <C-o>^
ino <M-l> <C-o>$
ino <M-e> <C-o>e<C-o>a
ino <M-k> 「」<Left>
ino <M-x> <Cmd>call <SID>CA()<CR>
def CF()
for a in get(w:, 'my_syntax', [])
matchdelete(a)
endfor
w:my_syntax = []
enddef
def CG(a: string, b: string)
w:my_syntax->add(matchadd(a, b))
enddef
au vimrc Syntax * CF()
au vimrc Syntax javascript,vim CG('SpellRare', '\s[=!]=\s') # 「==#」とかの存在を忘れないように
au vimrc Syntax vim CG('SpellRare', '\<normal!\@!') # 基本的には再マッピングさせないように「!」を付ける
nn <silent> g<Leader> :<C-u>tabnext #<CR>
nn <Space>a A
nn <expr> <Space>m ':<C-u>' .. getpos("'<")[1] .. ',' .. getpos("'>")[1] .. 'move ' .. getpos('.')[1] .. '<CR>'
if strftime('%d') ==# '01'
def CH()
notification#show("✨ Today, Let's enjoy the default key mapping ! ✨")
imapclear
mapclear
enddef
au vimrc VimEnter * CH()
endif
def CI()
g:rainbow_conf = {
guifgs: ['#9999ee', '#99ccee', '#99ee99', '#eeee99', '#ee99cc', '#cc99ee'],
ctermfgs: ['105', '117', '120', '228', '212', '177']
}
g:rcsv_colorpairs = [
['105', '#9999ee'], ['117', '#99ccee'], ['120', '#99ee99'],
['228', '#eeee99'], ['212', '#ee99cc'], ['177', '#cc99ee']
]
enddef
au vimrc ColorSchemePre * CI()
def CJ()
if exists('w:my_matches') && !empty(getmatches())
return
endif
w:my_matches = 1
matchadd('SpellBad', '　\|¥\|\s\+$')
matchadd('String', '「[^」]*」')
matchadd('Label', '^\s*■.*$')
matchadd('Delimiter', 'WARN\|注意\|注:\|[★※][^\s()（）]*')
matchadd('Todo', 'TODO')
matchadd('Error', 'ERROR')
matchadd('Delimiter', '- \[ \]')
matchadd('SpellBad', 'stlye')
enddef
au vimrc VimEnter,WinEnter * CJ()
set t_Co=256
syntax on
set background=dark
sil! colorscheme girly
if filereadable(expand('~/.vimrc_local'))
so ~/.vimrc_local
endif
