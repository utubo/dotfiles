vim9script
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
set cmdheight=0
set ls=2
set noru
set noshowcmd
set noshowmode
set dy=lastline
set ambw=double
set bo=all
set ttm=50
set wmnu
set acd
set bsk=/var/tmp/*
set udir=~/.vim/undo
set udf
set ut=2000
set is
set hls
noh
aug vimrc
au!
aug End
const lk = has('win32') ? '~/vimfiles' : '~/.vim'
const ll = executable('deno')
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
sil! exe ':' a 's/\s\+$//'
sil! exe ':' a 's/^\s*\n//'
enddef
def C(): bool
return &modified || ! empty(bufname())
enddef
def D(a: any): string
return matchstr(getline(a), '^\s*')
enddef
def E(a: string, b: number): string
var d = ''
for c in a->split('\zs')
if strdisplaywidth(d) > b
return d->substitute('..$', '>', '')
endif
d ..= c
endfor
return d
enddef
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
Jetpack 'LeafCage/vimhelpgenerator'
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
Jetpack 'utubo/vim-auto-hide-cmdline'
Jetpack 'utubo/vim-colorscheme-girly'
Jetpack 'utubo/vim-minviml'
Jetpack 'utubo/vim-portal-aim'
Jetpack 'utubo/vim-registers-lite'
Jetpack 'utubo/vim-reformatdate'
Jetpack 'utubo/vim-tabtoslash'
Jetpack 'utubo/vim-textobj-twochars'
Jetpack 'utubo/vim-shrink'
Jetpack 'utubo/vim-tablist'
Jetpack 'utubo/vim-tabpopupmenu'
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
map s <Plug>(ahc)<Plug>(easymotion-s)
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
if g:fix_sandwich_pos[1] !=# c.inner_head[1]
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
nm S. <Cmd>call <SID>G()<CR>gvSa
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
vm Sm <Cmd>call <SID>H()<CR>
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
if &cmdheight !=# 0
echoh Question
ec printf('[1]..[9] => open with a %s.', a ? 'tab' : 'window')
echoh None
endif
const c = a ? 't' : '<CR>'
for i in range(1, 9)
exe printf('nmap <buffer> <silent> %d :<C-u>%d<CR>%s', i, i, c)
endfor
enddef
def BA()
Enable b:auto_cursorline_disabled
setl cursorline
nn <buffer> w <Cmd>call <SID>J(!b:use_tab)<CR>
nn <buffer> R <Cmd>MruRefresh<CR><Cmd>normal! u
nn <buffer> <Esc> <Cmd>q!<CR>
J(C())
enddef
au vimrc FileType mru BA()
au vimrc ColorScheme * hi link MruFileName Directory
nn <F2> <Cmd>MRUToggle<CR>
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
ino <C-l> <Cmd>lexima#insmode#leave(1, '<LT>C-G>U<LT>RIGHT>')<CR>
Enable g:ale_set_quickfix
Enable g:ale_fix_on_save
Disable g:ale_lint_on_insert_leave
Disable g:ale_set_loclist
g:ale_sign_error = '🐞'
g:ale_sign_warning = '🐝'
g:ale_fixers = { typescript: ['deno'] }
g:ale_lint_delay = &ut
nm <silent> [a <Plug>(ale_previous_wrap)
nm <silent> ]a <Plug>(ale_next_wrap)
Disable g:ale_echo_cursor
g:ll_are = ''
def BC()
var a = ale#util#FindItemAtCursor(bufnr())[1]
if !empty(a)
g:ll_ale = a.type ==# 'E' ? '🐞' : '🐝'
g:ll_ale ..= ' '
g:ll_ale ..= get(a, 'detail', a.text)->split('\n')[0]
->substitute('^\[[^]]*\] ', '', '')
else
g:ll_ale = ''
endif
enddef
au vimrc CursorMoved * BC()
g:ll_reg = ''
def BD()
var a = v:event.regcontents
->join('\n')
->substitute('\t', ' ', 'g')
->E(20)
g:ll_reg = '📋:' .. a
enddef
au vimrc TextYankPost * BD()
g:ll_tea_break = '0:00'
g:ll_tea_break_opentime = localtime()
def! g:VimrcTimer60s(a: any)
const b = (localtime() - g:ll_tea_break_opentime) / 60
const c = b % 60
const d = c >= 45 ? '☕🍴🍰' : ''
g:ll_tea_break = d .. printf('%d:%02d', b / 60, c)
lightline#update()
if (c ==# 45)
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
active: {
left: [['mode', 'paste'], ['fugitive', 'filename'], ['ale']],
right: [['teabreak'], ['ff', 'notutf8', 'li'], ['reg']]
},
component: { teabreak: '%{g:ll_tea_break}', reg: '%{g:ll_reg}', ale: '%=%{g:ll_ale}', li: '%2c,%l/%L' },
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
nn <Leader>a <Cmd>PortalAim<CR>
nn <Leader>b <Cmd>PortalAim blue<CR>
nn <Leader>o <Cmd>PortalAim orange<CR>
nn <Leader>r <Cmd>PortalReset<CR>
g:vimhelpgenerator_version = ''
g:vimhelpgenerator_author = 'Author  : utubo'
g:vimhelpgenerator_defaultlanguage = 'en'
g:auto_hide_cmdline_switch_statusline = 1
MultiCmd nnoremap,vnoremap : <Plug>(ahc-switch):
MultiCmd nnoremap,vnoremap / <Plug>(ahc-switch)<Cmd>noh<CR>/
MultiCmd nnoremap,vnoremap ? <Plug>(ahc-switch)<Cmd>noh<CR>?
MultiCmd nmap,vmap <Space>; ;
MultiCmd nmap,vmap ; :
nn <Space>: :
Enable g:rainbow_active
g:auto_cursorline_wait_ms = &ut
g:ctrlp_match_func = {'match': 'ctrlp_matchfuzzy#matcher'}
g:ctrlp_cmd = 'CtrlPMixed'
nm [c <Plug>(ahc)<Plug>(GitGutterPrevHunk)
nm ]c <Plug>(ahc)<Plug>(GitGutterNextHunk)
nm <Space>ga :<C-u>Git add %
nm <Space>gc :<C-u>Git commit -m ''<Left>
nm <Space>gp :<C-u>Git push
nn <Space>gv <Cmd>Gvdiffsplit<CR>
nn <Space>gd <Cmd>Gdiffsplit<CR>
nn <Space>gl <Cmd>Git pull<CR>
nn <Space>t <Cmd>call tabpopupmenu#popup()<CR>
nn <Space>T <Cmd>call tablist#Show()<CR>
MultiCmd nmap,vmap <Space>c <Plug>(caw:hatpos:toggle)
MultiCmd nmap,tmap <silent> <C-w><C-s> <Plug>(shrink-height)<C-w>w
MultiCmd nmap,tmap <silent> <C-w><C-h> <Plug>(shrink-width)<C-w>w
no <Space>s <Plug>(jumpcursor-jump)
const lq = expand(lk .. '/pack/local/opt/*')
if lq !=# ''
&runtimepath = substitute(lq, '\n', ',', 'g') .. ',' .. &runtimepath
endif
filetype plugin indent on
au vimrc InsertLeave * set nopaste
au vimrc BufReadPost *.log* normal! G
vn * "vy/\V<Cmd>substitute(escape(@v,'\/'),"\n",'\\n','g')<CR><CR>
ino kj <Esc>`^
ino kk <Esc>`^
ino <CR> <CR><C-g>u
set mps+=（:）,「:」,『:』,【:】,［:］,＜:＞
nn <expr> i len(getline('.')) !=# 0 ? 'i' : '"_cc'
nn <expr> a len(getline('.')) !=# 0 ? 'a' : '"_cc'
nn <expr> A len(getline('.')) !=# 0 ? 'A' : '"_cc'
def BE()
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
au vimrc BufReadPost * BE()
def BF(a: string, ...b: list<string>)
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
com! -nargs=+ VimGrep BF(<f-args>)
nm <Space>/ :<C-u>VimGrep<Space>
def BG()
nn <buffer> <silent> ; <CR>:silent! normal! zv<CR><C-W>w
nn <buffer> <silent> w <C-W><CR>:silent! normal! zv<CR><C-W>w
nn <buffer> <silent> t <C-W><CR>:silent! normal! zv<CR><C-W>T
nn <buffer> <nowait> q <Cmd>lexpr ''<CR>:q<CR>
nn <buffer> f <C-f>
nn <buffer> b <C-b>
exe printf('nnoremap <buffer> T <C-W><CR><C-W>T%dgt', tabpagenr())
enddef
au vimrc FileType qf BG()
au vimrc WinEnter * if winnr('$') ==# 1 && &buftype ==# 'quickfix'|q|endif
set spr
set fcs+=diff:\ 
au vimrc WinEnter * if (winnr('$') ==# 1) && !!getbufvar(winbufnr(0), '&diff')|diffoff|endif
g:reformatdate_extend_names = [{
a: ['日', '月', '火', '水', '木', '金', '土'],
A: ['日曜日', '月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日'],
}]
ino <expr> <F5> strftime('%Y/%m/%d')
cno <expr> <F5> strftime('%Y%m%d')
nn <F5> <Cmd>call reformatdate#reformat(localtime())<CR>
nn <C-a> <Cmd>call reformatdate#inc(v:count)<CR>
nn <C-x> <Cmd>call reformatdate#dec(v:count)<CR>
nn <Space><F5> /\d\{4\}\/\d\d\/\d\d<CR>
nn <Space>zz <Cmd>q!<CR>
nn <Space>e G?\cErr\\|Exception<CR>
nn <Space>y yiw
nn <expr> <Space>f (getreg('"') =~ '^\d\+$' ? ':' : '/') .. getreg('"') .. '<CR>'
nm <Space>. :
nm <Space>, /
for i in range(1, 10)
exe printf('nmap <Space>%d <F%d>', i % 10, i)
endfor
nm <Space><Space>1 <F11>
nm <Space><Space>2 <F12>
def BH(): string
const x = getline('.')->match('\S') + 1
if x !=# 0 || !exists('w:my_hat')
w:my_hat = col('.') ==# x ? '^' : ''
endif
return w:my_hat
enddef
nn <expr> j 'j' .. <SID>BH()
nn <expr> k 'k' .. <SID>BH()
def! g:MyFoldText(): string
const a = getline(v:foldstart)
const b = repeat(' ', indent(v:foldstart))
const c = &fdm ==# 'indent' ? '' : a->substitute(matchstr(&foldmarker, '^[^,]*'), '', '')->trim()
return b .. c .. '📁'
enddef
set fdt=g:MyFoldText()
set fcs+=fold:\ 
au vimrc ColorScheme * hi! link Folded Delimiter
def BI()
const a = min([line('.'), line('v')])
const b = max([line('.'), line('v')])
exe ':' a 's/\v(\S)?$/\1 /'
append(b, D(a))
cursor([a, 1])
cursor([b + 1, 1])
normal! zf
enddef
vn zf <Cmd>call <SID>BI()<CR>
def BJ()
if foldclosed(line('.')) ==# -1
normal! zc
endif
const a = foldclosed(line('.'))
const b = foldclosedend(line('.'))
if a ==# -1
return
endif
const c = getpos('.')
normal! zd
B(b)
B(a)
setpos('.', c)
enddef
nn zd <Cmd>call <SID>BJ()<CR>
set fdm=marker
au vimrc FileType markdown,yaml setlocal foldlevelstart=99|setl fdm=indent
au vimrc BufReadPost * :silent! normal! zO
nn <expr> h (col('.') ==# 1 && 0 < foldlevel('.') ? 'zc' : 'h')
nn Z<Tab> <Cmd>set foldmethod=indent<CR>
nn Z{ <Cmd>set foldmethod=marker<CR>
nn Zy <Cmd>set foldmethod=syntax<CR>
def CA(a: string)
const b = getcurpos()
exe a
setpos('.', b)
enddef
vn u <Cmd>call <SID>CA('undo')<CR>
vn <C-R> <Cmd>call <SID>CA('redo')<CR>
vn <Tab> <Cmd>normal! >gv<CR>
vn <S-Tab> <Cmd>normal! <gv<CR>
cno <C-h> <Space><BS><Left>
cno <C-l> <Space><BS><Right>
cno <expr> <C-r><C-r> trim(@")
cno <expr> <C-r><C-e> escape(@", '~^$.*?/\[]')
nn q; :q
cnoreabbrev cs colorscheme
cno kk <C-c>
cm <expr> jj (empty(getcmdline()) && getcmdtype() ==# ':' ? 'update<CR>' : '<CR>')
ino ;jj <Esc>`^:update<CR>
if has('win32')
com! Powershell :bo terminal ++close pwsh
nn SH <Cmd>Powershell<CR>
nn <S-F1> <Cmd>silent !start explorer %:p:h<CR>
else
nn SH <Cmd>bo terminal<CR>
endif
tno <C-w>; <C-w>:
tno <C-w><C-w> <C-w>w
tno <C-w><C-q> exit<CR>
def CB()
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
no <Space>x <Cmd>call <SID>CB()<CR>
def CC(a: string = '')
if &ft ==# 'qf'
return
endif
var b = a ==# 'BufReadPost'
if b && ! filereadable(expand('%'))
return
endif
var c = []
add(c, ['Title', '"' .. bufname() .. '"'])
add(c, ['Normal', ' '])
if &modified
add(c, ['Delimiter', '[+]'])
add(c, ['Normal', ' '])
endif
if !b
add(c, ['Tag', '[New]'])
add(c, ['Normal', ' '])
endif
if &readonly
add(c, ['WarningMsg', '[RO]'])
add(c, ['Normal', ' '])
endif
const w = wordcount()
if b || w.bytes !=# 0
add(c, ['Constant', printf('%dL, %dB', w.bytes ==# 0 ? 0 : line('$'), w.bytes)])
add(c, ['Normal', ' '])
endif
add(c, ['MoreMsg', printf('%s %s %s', &ff, (empty(&fenc) ? &enc : &fenc), &ft)])
var e = 0
const f = &columns - 2
for i in reverse(range(0, len(c) - 1))
var s = c[i][1]
var d = strdisplaywidth(s)
e += d
if f < e
const l = f - e + d
while !empty(s) && l < strdisplaywidth(s)
s = s[1 :]
endwhile
c[i][1] = s
c = c[i : ]
insert(c, ['NonText', '<'], 0)
break
endif
endfor
redraw
ec ''
for m in c
exe 'echohl' m[0]
echon m[1]
endfor
echoh Normal
enddef
no <C-g> <Plug>(ahc)<Cmd>call <SID>CC()<CR>
def CD(a: string = '')
if ! empty(a)
if winnr() ==# winnr(a)
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
nn q <Nop>
nn Q q
nn qh <Cmd>call <SID>CD('h')<CR>
nn qj <Cmd>call <SID>CD('j')<CR>
nn qk <Cmd>call <SID>CD('k')<CR>
nn ql <Cmd>call <SID>CD('l')<CR>
nn qq <Cmd>call <SID>CD()<CR>
nn q: q:
nn q/ q/
nn q? q?
def CE(a: string)
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
com! -nargs=1 -complete=file MoveFile call <SID>CE(<f-args>)
cnoreabbrev mv MoveFile
cno <expr> <SID>(exec_line) substitute(getline('.'), '^[ \t"#:]\+', '', '') .. '<CR>'
nm g: <Plug>(ahc):<C-u><SID>(exec_line)
nm g9 <Plug>(ahc):<C-u>vim9cmd <SID>(exec_line)
vm g: "vy<Plug>(ahc):<C-u><C-r>=@v<CR><CR>
vm g9 "vy<Plug>(ahc):<C-u>vim9cmd <C-r>=@v<CR><CR>
nn <expr> <Space>gh '<Cmd>hi ' .. substitute(synIDattr(synID(line('.'), col('.'), 1), 'name'), '^$', 'Normal', '') .. '<CR>'
if has('clipboard')
au vimrc FocusGained * @" = @+
au vimrc FocusLost * @+ = @"
endif
nn <F11> <Cmd>set number! \| let &cursorline=&number<CR>
nn <F12> <Cmd>set wrap!<CR>
cno <expr> <SID>(left16) repeat('<Left>', 16)
nm gs :<C-u>%s///g \| nohlsearch<SID>(left16)
vm gs :s///g \| nohlsearch<SID>(left16)
nm gS :<C-u>%s/<C-r>=escape(expand("<cword>"), "^$.*?/\[]")<CR>//g \| nohlsearch<SID>(left16)<Right>
nn Y y$
nn <Space>p $p
nn <Space>P ^P
nn <Space><Space>p o<Esc>P
nn <Space><Space>P O<Esc>p
nn TE :<C-u>tabe<Space>
nn TN <Cmd>tabnew<CR>
nn TD <Cmd>tabe ./<CR>
ono <expr> } '<Esc>m`0' .. v:count1 .. v:operator .. '}'
ono <expr> { '<Esc>m`V' .. v:count1 .. '{' .. v:operator
vn <expr> h mode() ==# 'V' ? '<Esc>h' : 'h'
vn <expr> l mode() ==# 'V' ? '<Esc>l' : 'l'
vn J j
vn K k
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
nn <Space>n <Cmd>nohlsearch<CR>
au vimrc CursorHold * feedkeys(" n") # nohはauで動かない(:help noh)
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
ino jjx <Cmd>call <SID>CB()<CR>
ino <M-x> <Cmd>call <SID>CB()<CR>
im ql <C-l>
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
nn g<Leader> <Cmd>tabnext #<CR>
nn <Space>a A
nn <expr> <Space>m '<Cmd>' .. getpos("'<")[1] .. ',' .. getpos("'>")[1] .. 'move ' .. getpos('.')[1] .. '<CR>'
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
set bg=dark
sil! colorscheme girly
if filereadable(expand('~/.vimrc_local'))
so ~/.vimrc_local
endif
