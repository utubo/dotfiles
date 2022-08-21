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
aug vimrc
au!
aug End
const lk = has('win32') ? '~/vimfiles' : '~/.vim'
const ll = executable('deno')
def A(b: string)
const [c, d] = b->split('^\S*\zs')
for e in c->split(',')
const a = d
->substitute($'<if-{e}>', '<>', 'g')
->substitute('<if-.\{-1,}\(<>\|$\)', '', 'g')
->substitute('<>', '', 'g')
exe e a
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
return strdisplaywidth(a) <= b ? a : $'{a->matchstr($'.*\%<{b + 1}v')}>'
enddef
const lm = expand( $'{lk}/pack/jetpack/opt/vim-jetpack/plugin/jetpack.vim')
const ln = filereadable(lm)
if ! ln
const lo = 'https://raw.githubusercontent.com/tani/vim-jetpack/master/plugin/jetpack.vim'
system($'curl -fsSLo {lm} --create-dirs {lo}')
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
Jetpack 'vim-jp/vital.vim'
Jetpack 'utubo/jumpcuorsor.vim'
Jetpack 'utubo/vim-auto-hide-cmdline'
Jetpack 'utubo/vim-colorscheme-girly'
Jetpack 'utubo/vim-minviml'
Jetpack 'utubo/vim-portal-aim'
Jetpack 'utubo/vim-registers-lite'
Jetpack 'utubo/vim-reformatdate'
Jetpack 'utubo/vim-tabtoslash'
Jetpack 'utubo/vim-shrink'
Jetpack 'utubo/vim-tablist'
Jetpack 'utubo/vim-tabpopupmenu'
Jetpack 'utubo/vim-textobj-twochars'
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
g:sandwich#recipes = deepcopy(g:sandwich#default_recipes)
g:sandwich#recipes += [
{ buns: ["\r", '' ], input: ["\r"], command: ["normal! a\r"] },
{ buns: ['', '' ], input: ['q'] },
{ buns: ['「', '」'], input: ['k'] },
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
MultiCmd nnoremap,vnoremap Sd <Plug>(operator-sandwich-delete)<if-nnoremap>ab
MultiCmd nnoremap,vnoremap Sr <Plug>(operator-sandwich-replace)<if-nnoremap>ab
MultiCmd nnoremap,vnoremap Sa <Plug>(operator-sandwich-add)<if-nnoremap>iw
MultiCmd nnoremap,vnoremap S <Plug>(operator-sandwich-add)<if-nnoremap>iw
nm S^ v^S
nm S$ vg_S
nm <expr> SS (matchstr(getline('.'), '[''"]', col('.')) ==# '"') ? 'Sr''' : 'Sr"'
def F()
var c = g:operator#sandwich#object.cursor
if g:fix_sandwich_pos[1] !=# c.inner_head[1]
c.inner_head[2] = getline(c.inner_head[1])->match('\S') + 1
c.inner_tail[2] = getline(c.inner_tail[1])->match('$') + 1
endif
enddef
au vimrc User OperatorSandwichAddPre g:fix_sandwich_pos = getpos('.')
au vimrc User OperatorSandwichAddPost F()
var lp = []
def G(a: bool = true)
const c = g:operator#sandwich#object.cursor.inner_head[1 : 2]
if a || lp !=# c
lp = c
au vimrc User OperatorSandwichAddPost ++once G(false)
if a
feedkeys('Sa')
else
setpos("'<", g:operator#sandwich#object.cursor.inner_head)
setpos("'>", g:operator#sandwich#object.cursor.inner_tail)
feedkeys('gvSa')
endif
endif
enddef
nm Sm viwSm
vm Sm <ScriptCmd>G()<CR>
def H()
const c = g:operator#sandwich#object.cursor
B(c.tail[1])
B(c.head[1])
enddef
au vimrc User OperatorSandwichDeletePost H()
g:MRU_Filename_Format = {
formatter: 'fnamemodify(v:val, ":t") . " > " . v:val',
parser: '> \zs.*',
syntax: '^.\{-}\ze >'
}
def I(a: bool)
b:use_tab = a
setl number
redraw
if &cmdheight !=# 0
echoh Question
ec $'[1]..[9] => open with a {a ? 'tab' : 'window'}.'
echoh None
endif
const c = a ? 't' : '<CR>'
for i in range(1, 9)
exe $'nmap <buffer> <silent> {i} :<C-u>{i}<CR>{c}'
endfor
enddef
def J()
Enable b:auto_cursorline_disabled
setl cursorline
nn <buffer> w <ScriptCmd>I(!b:use_tab)<CR>
nn <buffer> R <Cmd>MruRefresh<CR><Cmd>normal! u
nn <buffer> <Esc> <Cmd>q!<CR>
I(C())
enddef
au vimrc FileType mru J()
au vimrc ColorScheme * hi link MruFileName Directory
nn <F2> <Cmd>MRUToggle<CR>
g:MRU_Exclude_Files = has('win32') ? $'{$TEMP}\\.*' : '^/tmp/.*\|^/var/tmp/.*'
def BA(a: string, b: list<string>, c: list<string>)
exe printf("asyncomplete#register_source(asyncomplete#sources#%s#get_source_options({ name: '%s', whitelist: %s, blacklist: %s, completor: asyncomplete#sources#%s#completor }))", a, a, b, c, a)
enddef
BA('omni', ['*'], ['c', 'cpp', 'html'])
BA('buffer', ['*'], ['go'])
MultiCmd inoremap,snoremap <expr> JJ vsnip#expandable() ? '<Plug>(vsnip-expand)' : 'JJ'
MultiCmd inoremap,snoremap <expr> <C-l> vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
MultiCmd inoremap,snoremap <expr> <Tab> vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : pumvisible() ? '<C-n>' : '<Tab>'
MultiCmd inoremap,snoremap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : pumvisible() ? '<C-p>' : '<S-Tab>'
Enable g:lexima_accept_pum_with_enter
Enable g:ale_set_quickfix
Enable g:ale_fix_on_save
Disable g:ale_lint_on_insert_leave
Disable g:ale_set_loclist
g:ale_sign_error = '🐞'
g:ale_sign_warning = '🐝'
g:ale_fixers = { typescript: ['deno'] }
g:ale_lint_delay = &ut
nn <silent> [a <Plug>(ale_previous_wrap)
nn <silent> ]a <Plug>(ale_next_wrap)
Disable g:ale_echo_cursor
g:ll_are = ''
def BB()
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
au vimrc CursorMoved * BB()
g:ll_reg = ''
def BC()
var a = v:event.regcontents
->join('↵')
->substitute('\t', '›', 'g')
->E(20)
g:ll_reg = $'📋:{a}'
enddef
au vimrc TextYankPost * BC()
g:ll_tea_break = '0:00'
g:ll_tea_break_opentime = get(g:, 'll_tea_break_opentime', localtime())
def! g:VimrcTimer60s(a: any)
const b = (localtime() - g:ll_tea_break_opentime) / 60
const c = b % 60
const d = c >= 45 ? '☕🍴🍰' : ''
g:ll_tea_break = printf('%s%d:%02d', d, b / 60, c)
lightline#update()
if (c ==# 45)
notification#show("       ☕🍴🍰\nHave a break time !")
endif
enddef
timer_stop(get(g:, 'vimrc_timer_60s', 0))
g:vimrc_timer_60s = timer_start(60000, 'VimrcTimer60s', { repeat: -1 })
g:ll_mdcb = ''
def! g:LLMdcb()
var a = 0
var b = 0
if mode() !=? 'V'
if &ft !=# 'markdown'
g:ll_mdcb = ''
return
endif
a = line('.')
b = a
const c = indent(a)
for l in range(a + 1, line('$'))
if indent(l) <= c
break
endif
b = l
endfor
else
a = min([line('.'), line('v')])
b = max([line('.'), line('v')])
endif
const d = 99 - 1
var e = ''
if a + d < b
e = '+'
b = a + d
endif
var f = 0
var h = 0
for l in range(a, b)
const i = getline(l)
if i->match('^\s*- \[x\]') !=# -1
f += 1
elseif i->match('^\s*- \[ \]') !=# -1
h += 1
endif
endfor
if f ==# 0 && h ==# 0
g:ll_mdcb = ''
else
g:ll_mdcb = $'[x]:{f}/{f + h}{e}'
endif
enddef
au vimrc CursorMoved * g:LLMdcb()
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
right: [['teabreak'], ['ff', 'notutf8', 'li'], ['reg', 'mdcb']]
},
component: { teabreak: '%{g:ll_tea_break}', mdcb: '%{g:ll_mdcb}', reg: '%{g:ll_reg}', ale: '%=%{g:ll_ale}', li: '%2c,%l/%L' },
component_function: { ff: 'LLFF', notutf8: 'LLNotUtf8' },
}
au vimrc VimEnter * set tabline=
if ll
if ! empty($SKK_JISYO_DIR)
skkeleton#config({
globalJisyo: expand($'{$SKK_JISYO_DIR}SKK-JISYO.L'),
userJisyo: expand($'{$SKK_JISYO_DIR}.skkeleton'),
})
endif
skkeleton#config({
eggLikeNewline: true,
keepState: true,
showCandidatesCount: 1,
})
map! <C-j> <Plug>(skkeleton-toggle)
endif
MultiCmd onoremap,xnoremap ab <Plug>(textobj-multiblock-a)
MultiCmd onoremap,xnoremap ib <Plug>(textobj-multiblock-i)
g:textobj_multiblock_blocks = [ [ "(", ")" ], [ "[", "]" ], [ "{", "}" ], [ '<', '>' ], [ '"', '"', 1 ], [ "'", "'", 1 ], [ ">", "<", 1 ], [ "「", "」", 1 ],
]
nn <Leader>a <Cmd>PortalAim<CR>
nn <Leader>b <Cmd>PortalAim blue<CR>
nn <Leader>o <Cmd>PortalAim orange<CR>
nn <Leader>r <Cmd>PortalReset<CR>
g:vimhelpgenerator_version = ''
g:vimhelpgenerator_author = 'Author  : utubo'
g:vimhelpgenerator_defaultlanguage = 'en'
Enable g:auto_hide_cmdline_switch_statusline
MultiCmd nnoremap,vnoremap : <Plug>(ahc-switch):
MultiCmd nnoremap,vnoremap / <Plug>(ahc-switch)<Cmd>noh<CR>/
MultiCmd nnoremap,vnoremap ? <Plug>(ahc-switch)<Cmd>noh<CR>?
MultiCmd nmap,vmap ; :
nn <Space>; ;
nn <Space>: :
Enable g:rainbow_active
g:auto_cursorline_wait_ms = &ut
g:ctrlp_match_func = {'match': 'ctrlp_matchfuzzy#matcher'}
g:ctrlp_cmd = 'CtrlPMixed'
nn [c <Plug>(ahc)<Plug>(GitGutterPrevHunk)
nn ]c <Plug>(ahc)<Plug>(GitGutterNextHunk)
nm <Space>ga :<C-u>Git add %
nm <Space>gc :<C-u>Git commit -m ''<Left>
nm <Space>gp :<C-u>Git push
nn <Space>gv <Cmd>Gvdiffsplit<CR>
nn <Space>gd <Cmd>Gdiffsplit<CR>
nn <Space>gl <Cmd>Git pull<CR>
nn <Space>t <ScriptCmd>tabpopupmenu#popup()<CR>
nn <Space>T <ScriptCmd>tablist#Show()<CR>
MultiCmd nnoremap,vnoremap <Space>c <Plug>(caw:hatpos:toggle)
MultiCmd nnoremap,tnoremap <silent> <C-w><C-s> <Plug>(shrink-height)<C-w>w
MultiCmd nnoremap,tnoremap <silent> <C-w><C-h> <Plug>(shrink-width)<C-w>w
no <Space>s <Plug>(jumpcursor-jump)
const lq = expand($'{lk}/pack/local/opt/*')
if lq !=# ''
&runtimepath = $'{substitute(lq, '\n', ',', 'g')},{&runtimepath}'
endif
filetype plugin indent on
au vimrc InsertLeave * set nopaste
au vimrc BufReadPost *.log* normal! G
vn * "vy/\V<Cmd>substitute(escape(@v,'\/'),"\n",'\\n','g')<CR><CR>
ino kj <Esc>`^
ino kk <Esc>`^
ino <CR> <CR><C-g>u
set mps+=（:）,「:」,『:』,【:】,［:］,＜:＞
nn <expr> i !empty(getline('.')) ? 'i' : '"_cc'
nn <expr> a !empty(getline('.')) ? 'a' : '"_cc'
nn <expr> A !empty(getline('.')) ? 'A' : '"_cc'
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
c = expand('%:e') ==# '' ? '*' : ($'*.{expand('%:e')}')
endif
const d = C() && c !=# '%'
if d
tabnew
endif
exe $'silent! lvimgrep {a} {c}'
if ! empty(getloclist(0))
lwindow
else
echoh ErrorMsg
echom $'Not found.: {a}'
echoh None
if d
tabn -
tabc +
endif
endif
enddef
com! -nargs=+ VimGrep BE(<f-args>)
nm <Space>/ :<C-u>VimGrep<Space>
def BF()
nn <buffer> <silent> ; <CR>:silent! normal! zv<CR><C-W>w
nn <buffer> <silent> w <C-W><CR>:silent! normal! zv<CR><C-W>w
nn <buffer> <silent> t <C-W><CR>:silent! normal! zv<CR><C-W>T
nn <buffer> <nowait> q <Cmd>lexpr ''<CR>:q<CR>
nn <buffer> f <C-f>
nn <buffer> b <C-b>
exe $'nnoremap <buffer> T <C-W><CR><C-W>T{tabpagenr()}gt'
enddef
au vimrc FileType qf BF()
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
nn <Space>zz <Cmd>q!<CR>
nn <Space>e G?\cErr\\|Exception<CR>
nn <Space>y yiw
nn <expr> <Space>f $'{(getreg('"') =~ '^\d\+$' ? ':' : '/')}{getreg('"')}<CR>'
nm <Space>. :
nm <Space>, /
for i in range(1, 10)
exe $'nmap <Space>{i % 10} <F{i}>'
endfor
nm <Space><Space>1 <F11>
nm <Space><Space>2 <F12>
def BG(): string
const x = getline('.')->match('\S') + 1
if x !=# 0 || !exists('w:my_hat')
w:my_hat = col('.') ==# x ? '^' : ''
endif
return w:my_hat
enddef
nn <expr> j $'j{<SID>BG()}'
nn <expr> k $'k{<SID>BG()}'
def! g:MyFoldText(): string
const a = getline(v:foldstart)
const b = repeat(' ', indent(v:foldstart))
const c = &fdm ==# 'indent' ? '' : a->substitute(matchstr(&foldmarker, '^[^,]*'), '', '')->trim()
return $'{b}{c} 📁'
enddef
set fdt=g:MyFoldText()
set fcs+=fold:\ 
au vimrc ColorScheme * hi! link Folded Delimiter
def BH()
const a = min([line('.'), line('v')])
const b = max([line('.'), line('v')])
exe ':' a 's/\v(\S)?$/\1 /'
append(b, D(a))
cursor([a, 1])
cursor([b + 1, 1])
normal! zf
enddef
vn zf <ScriptCmd>BH()<CR>
def BI()
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
nn zd <ScriptCmd>BI()<CR>
set fdm=marker
au vimrc FileType markdown,yaml setlocal foldlevelstart=99|setl fdm=indent
au vimrc BufReadPost * :silent! normal! zO
nn <expr> h (col('.') ==# 1 && 0 < foldlevel('.') ? 'zc' : 'h')
nn Z<Tab> <Cmd>set foldmethod=indent<CR>
nn Z{ <Cmd>set foldmethod=marker<CR>
nn Zy <Cmd>set foldmethod=syntax<CR>
def BJ(a: string)
const b = getcurpos()
exe a
setpos('.', b)
enddef
vn u <ScriptCmd>BJ('undo')<CR>
vn <C-R> <ScriptCmd>BJ('redo')<CR>
vn <Tab> <Cmd>normal! >gv<CR>
vn <S-Tab> <Cmd>normal! <gv<CR>
cno <C-h> <Space><BS><Left>
cno <C-l> <Space><BS><Right>
cno <expr> <C-r><C-r> trim(@")->substitute('\n', ' \| ', 'g')
cno <expr> <C-r><C-e> escape(@", '~^$.*?/\[]')->substitute('\n', '\\n', 'g')
cnoreabbrev cs colorscheme
cno kk <C-c>
cno <expr> jj (empty(getcmdline()) && getcmdtype() ==# ':' ? 'update<CR>' : '<CR>')
ino ;jj <Esc>`^<Cmd>update<CR>
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
no <Space>x <ScriptCmd>CA()<CR>
def CB(a: string = '')
if &ft ==# 'qf'
return
endif
var b = a ==# 'BufReadPost'
if b && ! filereadable(expand('%'))
return
endif
var c = []
add(c, ['Title', $'"{bufname()}"'])
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
add(c, ['MoreMsg', $'{&ff} {empty(&fenc) ? &enc : &fenc} {&ft}'])
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
no <C-g> <Plug>(ahc)<ScriptCmd>call <SID>CB()<CR>
def CC(a: string = '')
if ! empty(a)
if winnr() ==# winnr(a)
return
endif
exe 'wincmd' a
endif
if mode() ==# 't'
quit!
else
confirm quit
endif
enddef
nn q <Nop>
nn Q q
nn qh <ScriptCmd>CC('h')<CR>
nn qj <ScriptCmd>CC('j')<CR>
nn qk <ScriptCmd>CC('k')<CR>
nn ql <ScriptCmd>CC('l')<CR>
nn qq <ScriptCmd>CC()<CR>
nn q: q:
nn q/ q/
nn q? q?
def CD(a: string)
const b = expand('%')
const c = expand(a)
if ! empty(b) && filereadable(b)
if filereadable(c)
echoh Error
ec $'file "{a}" already exists.'
echoh None
return
endif
rename(b, c)
endif
exe 'saveas!' c
edit
enddef
com! -nargs=1 -complete=file MoveFile call <SID>CD(<f-args>)
cnoreabbrev mv MoveFile
cno <expr> <SID>(exec_line) $'{getline('.')->substitute('^[ \t"#:]\+', '', '')}<CR>'
nm g: <Plug>(ahc):<C-u><SID>(exec_line)
nm g9 <Plug>(ahc):<C-u>vim9cmd <SID>(exec_line)
vn g: "vy<Plug>(ahc):<C-u><C-r>=@v<CR><CR>
vn g9 "vy<Plug>(ahc):<C-u>vim9cmd <C-r>=@v<CR><CR>
nn <expr> <Space>gh $'<Cmd>hi {synID(line('.'), col('.'), 1)->synIDattr('name')->substitute('^$', 'Normal', '')}<CR>'
au vimrc FileType vim nnoremap ge <Cmd>update<CR><Cmd>source %<CR>
if has('clipboard')
au vimrc FocusGained * @" = @+
au vimrc FocusLost * @+ = @"
endif
nn <F11> <Cmd>set number!<CR>
nn <F12> <Cmd>set wrap!<CR>
cno <expr> <SID>(rpl) $'s///g \| noh{repeat('<Left>', 9)}'
nm gs :<C-u>%<SID>(rpl)
nm gS :<C-u>%<SID>(rpl)<ScriptCmd>feedkeys(expand('<cword>')->escape('^$.*?/\[]'), 'ni')<CR><Right>
vm gs :<SID>(rpl)
nn Y y$
nn <Space>p $p
nn <Space>P ^P
nn <Space><Space>p o<Esc>P
nn <Space><Space>P O<Esc>p
nm <CR> <Space>
nm TE :<C-u>tabe<Space>
nn TN <Cmd>tabnew<CR>
nn TD <Cmd>tabe ./<CR>
nn TT <Cmd>silent! tabnext #<CR>
ono <expr> } $"\<Esc>m`0{v:count1}{v:operator}\}"
ono <expr> { $"\<Esc>m`V{v:count1}\{{v:operator}"
vn <expr> h mode() ==# 'V' ? '<Esc>h' : 'h'
vn <expr> l mode() ==# 'V' ? '<Esc>l' : 'l'
vn J j
vn K k
ino ｋｊ <Esc>`^
ino 「 「」<Left>
ino 「」 「」<Left>
ino （ ()<Left>
ino （） ()<Left>
vn <expr> p $'"_s<C-R>{v:register}<ESC>'
vn P p
nn <Space>h ^
nn <Space>l $
nn <Space>d "_d
nn <Space>n <Cmd>nohlsearch<CR>
au vimrc CursorHold * feedkeys(' n') # nohはauで動かない(:help noh)
nn <Space>w <C-w>w
nn <Space>o <C-w>w
nn <silent> <F10> <ESC>1<C-w>s:1<CR><C-w>w
vn <F10> <ESC>1<C-w>s<C-w>w
nn ' "
nn m '
nn M m
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
ino jjx <ScriptCmd>CA()<CR>
ino <M-x> <ScriptCmd>CA()<CR>
cno qq <C-f>
def CE()
for a in get(w:, 'my_syntax', [])
matchdelete(a)
endfor
w:my_syntax = []
enddef
def CF(a: string, b: string)
w:my_syntax->add(matchadd(a, b))
enddef
au vimrc Syntax * CE()
au vimrc Syntax javascript,vim CF('SpellRare', '\s[=!]=\s')
au vimrc Syntax vim CF('SpellRare', '\<normal!\@!')
nn <Space>a A
nn <expr> <Space>m $'<Cmd>{getpos("'<")[1]},{getpos("'>")[1]}move {getpos('.')[1]}<CR>'
if strftime('%d') ==# '01'
def CG()
notification#show("✨ Today, Let's enjoy the default key mapping ! ✨")
imapclear
mapclear
enddef
au vimrc VimEnter * CG()
endif
def CH()
g:rainbow_conf = {
guifgs: ['#9999ee', '#99ccee', '#99ee99', '#eeee99', '#ee99cc', '#cc99ee'],
ctermfgs: ['105', '117', '120', '228', '212', '177']
}
g:rcsv_colorpairs = [
['105', '#9999ee'], ['117', '#99ccee'], ['120', '#99ee99'],
['228', '#eeee99'], ['212', '#ee99cc'], ['177', '#cc99ee']
]
enddef
au vimrc ColorSchemePre * CH()
def CI()
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
au vimrc VimEnter,WinEnter * CI()
def CJ()
if &list && !exists('w:hi_tail')
w:hi_tail = matchadd('SpellBad', '\s\+$')
elseif !&list && exists('w:hi_tail')
matchdelete(w:hi_tail)
unlet w:hi_tail
endif
enddef
au OptionSet list silent! CJ()
au vimrc BufNew,BufReadPost * silent! CJ()
set t_Co=256
syntax on
set bg=dark
sil! colorscheme girly
if '~/.vimrc_local'->expand()->filereadable()
so ~/.vimrc_local
endif
def DA()
var a = get(v:oldfiles, 0, '')->expand()
if a->filereadable()
exe 'edit' a
endif
enddef
au vimrc VimEnter * if !C()|DA()|endif
