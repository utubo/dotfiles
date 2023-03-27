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
const lm = executable('deno')
def A(b: string)
const [c, d] = b->split('^\S*\zs')
for e in c->split(',')
const a = d
->substitute($'<if-{e}>', '<if-*>', 'g')
->substitute('<if-[^*>]\+>.\{-1,}\(<if-\*>\|$\)', '', 'g')
->substitute('<if-\*>', '', 'g')
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
const ln = 300
var lo = 0
var lp = 0
def CursorMovedDelayExec(a: any)
lo = 0
if lp !=# 0
lp = 0
doautocmd User CursorMovedDelay
endif
enddef
def G()
if lo !=# 0
lp += 1
return
endif
lp = 0
doautocmd User CursorMovedDelay
lo = timer_start(ln, CursorMovedDelayExec)
enddef
au vimrc CursorMoved * G()
def H(): list<number>
return mode() ==? 'V' ? [line('.'), line('v')]->sort('n') : [line('.'), line('.')]
enddef
def I(): list<number>
const a = H()
return range(a[0], a[1])
enddef
def J(): list<string>
var [a, b] = getpos('v')[1 : 2]
var [c, d] = getpos('.')[1 : 2]
if c < a
[b, d] = [d, b]
[a, c] = [c, a]
endif
var f = getline(a, c)
if mode() ==# 'V'
elseif mode() ==# 'v' && a !=# c
f[-1] = f[-1][0 : d - 1]
f[0] = f[0][b - 1 : ]
else
var [s, e] = [b - 1, d - 1]->sort('n')
ec $'{s},{e}'
for i in range(0, c - a)
f[i] = f[i][s : e]
endfor
endif
return f
enddef
const lq = expand( $'{lk}/pack/jetpack/opt/vim-jetpack/plugin/jetpack.vim')
const lr = filereadable(lq)
if ! lr
const ls = 'https://raw.githubusercontent.com/tani/vim-jetpack/master/plugin/jetpack.vim'
system($'curl -fsSLo {lq} --create-dirs {ls}')
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
Jetpack 'itchyny/calendar.vim'
Jetpack 'kana/vim-textobj-user'
Jetpack 'LeafCage/vimhelpgenerator'
Jetpack 'luochen1990/rainbow'
Jetpack 'machakann/vim-sandwich'
Jetpack 'mattn/ctrlp-matchfuzzy'
Jetpack 'mattn/vim-notification'
Jetpack 'matze/vim-move'
Jetpack 'mechatroner/rainbow_csv'
Jetpack 'michaeljsmith/vim-indent-object'
Jetpack 'MTDL9/vim-log-highlighting'
Jetpack 'obcat/vim-hitspop'
Jetpack 'obcat/vim-sclow'
Jetpack 'osyo-manga/vim-textobj-multiblock'
Jetpack 'othree/html5.vim'
Jetpack 'othree/yajs.vim'
Jetpack 'prabirshrestha/asyncomplete-buffer.vim'
Jetpack 'prabirshrestha/asyncomplete.vim'
Jetpack 'rafamadriz/friendly-snippets'
Jetpack 'thinca/vim-portal'
Jetpack 'tpope/vim-fugitive'
Jetpack 'tyru/capture.vim'
Jetpack 'tyru/caw.vim'
Jetpack 'yami-beta/asyncomplete-omni.vim'
Jetpack 'yegappan/mru'
Jetpack 'vim-jp/vital.vim'
Jetpack 'lambdalisue/fern.vim'
Jetpack 'lambdalisue/fern-git-status.vim'
Jetpack 'lambdalisue/fern-renderer-nerdfont.vim'
Jetpack 'lambdalisue/fern-hijack.vim'
Jetpack 'lambdalisue/nerdfont.vim'
Jetpack 'utubo/jumpcursor.vim'
Jetpack 'utubo/vim-colorscheme-girly'
Jetpack 'utubo/vim-hlpairs'
Jetpack 'utubo/vim-minviml'
Jetpack 'utubo/vim-cmdheight0'
Jetpack 'utubo/vim-portal-aim'
Jetpack 'utubo/vim-registers-lite'
Jetpack 'utubo/vim-reformatdate'
Jetpack 'utubo/vim-tabtoslash'
Jetpack 'utubo/vim-shrink'
Jetpack 'utubo/vim-tablist'
Jetpack 'utubo/vim-tabpopupmenu'
Jetpack 'utubo/vim-textobj-twochars'
if lm
Jetpack 'vim-denops/denops.vim'
Jetpack 'vim-skk/skkeleton'
endif
jetpack#end()
if ! lr
jetpack#sync()
endif
Enable g:EasyMotion_smartcase
Enable g:EasyMotion_use_migemo
Enable g:EasyMotion_enter_jump_first
Disable g:EasyMotion_verbose
Disable g:EasyMotion_do_mapping
g:EasyMotion_keys = 'asdghklqwertyuiopzxcvbnmfjASDGHKLQWERTYUIOPZXCVBNMFJ;'
g:EasyMotion_prompt = 'EasyMotion: '
no s <Plug>(easymotion-s)
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
MultiCmd nmap,xmap Sd <Plug>(operator-sandwich-delete)<if-nmap>ab
MultiCmd nmap,xmap Sr <Plug>(operator-sandwich-replace)<if-nmap>ab
MultiCmd nnoremap,xnoremap S <Plug>(operator-sandwich-add)<if-nnoremap>iw
nm <expr> Srr (matchstr(getline('.'), '[''"]', col('.')) ==# '"') ? "Sr'" : 'Sr"'
def BA()
var c = g:operator#sandwich#object.cursor
if g:fix_sandwich_pos[1] !=# c.inner_head[1]
c.inner_head[2] = getline(c.inner_head[1])->match('\S') + 1
c.inner_tail[2] = getline(c.inner_tail[1])->match('$') + 1
endif
enddef
au vimrc User OperatorSandwichAddPre g:fix_sandwich_pos = getpos('.')
au vimrc User OperatorSandwichAddPost BA()
var lt = []
def BB(a: bool = true)
const c = a ? [] : g:operator#sandwich#object.cursor.inner_head[1 : 2]
if a || lt !=# c
lt = c
au vimrc User OperatorSandwichAddPost ++once BB(false)
if a
feedkeys('S')
else
setpos("'<", g:operator#sandwich#object.cursor.inner_head)
setpos("'>", g:operator#sandwich#object.cursor.inner_tail)
feedkeys('gvS')
endif
endif
enddef
nm Sm viwSm
vn Sm <ScriptCmd>BB()<CR>
def BC()
const c = g:operator#sandwich#object.cursor
B(c.tail[1])
B(c.head[1])
enddef
au vimrc User OperatorSandwichDeletePost BC()
g:MRU_Filename_Format = {
formatter: 'fnamemodify(v:val, ":t") . " > " . v:val',
parser: '> \zs.*',
syntax: '^.\{-}\ze >'
}
def BD(a: bool)
b:use_tab = a
setl number
redraw
echoh Question
ec $'[1]..[9] => open with a {a ? 'tab' : 'window'}.'
echoh None
const c = a ? 't' : '<CR>'
for i in range(1, 9)
exe $'nmap <buffer> <silent> {i} :<C-u>{i}<CR>{c}'
endfor
enddef
def BE()
Enable b:auto_cursorline_disabled
setl cursorline
nn <buffer> w <ScriptCmd>BD(!b:use_tab)<CR>
nn <buffer> R <Cmd>MruRefresh<CR><Cmd>MRU<CR>
nn <buffer> <Esc> <Cmd>q!<CR>
BD(C())
enddef
au vimrc FileType mru BE()
au vimrc ColorScheme * hi link MruFileName Directory
nn <F2> <Cmd>MRUToggle<CR>
g:MRU_Exclude_Files = has('win32') ? $'{$TEMP}\\.*' : '^/tmp/.*\|^/var/tmp/.*'
def BF(a: string, b: list<string>, c: list<string>)
exe printf("asyncomplete#register_source(asyncomplete#sources#%s#get_source_options({ name: '%s', whitelist: %s, blacklist: %s, completor: asyncomplete#sources#%s#completor }))", a, a, b, c, a)
enddef
BF('omni', ['*'], ['c', 'cpp', 'html'])
BF('buffer', ['*'], ['go'])
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
g:ale_linters = { javascript: ['eslint'] }
g:ale_fixers = { typescript: ['deno'] }
g:ale_lint_delay = &ut
nn <silent> [a <Plug>(ale_previous_wrap)
nn <silent> ]a <Plug>(ale_next_wrap)
g:ale_echo_cursor = 0
g:ruler_reg = ''
def BG()
var a = v:event.regcontents
->join('↵')
->substitute('\t', '›', 'g')
->E(20)
g:ruler_reg = $'📋{a}'
enddef
au vimrc TextYankPost * BG()
g:ruler_worktime = '🕛'
g:ruler_worktime_open_at = get(g:, 'ruler_worktime_open_at', localtime())
def! g:VimrcTimer60s(a: any)
const b = (localtime() - g:ruler_worktime_open_at) / 60
const c = b % 60
g:ruler_worktime = '🕛🕐🕑🕒🕓🕔🕕🕖🕗🍰🍰🍰'[c / 5]
if (c ==# 45)
notification#show("       ☕🍴🍰\nHave a break time !")
endif
enddef
timer_stop(get(g:, 'vimrc_timer_60s', 0))
g:vimrc_timer_60s = timer_start(60000, 'VimrcTimer60s', { repeat: -1 })
w:ruler_mdcb = ''
def BH(): string
var [a, b] = H()
if mode() ==? 'V'
elseif &ft !=# 'markdown'
return ''
else
const c = indent(a)
for l in range(a + 1, line('$'))
if indent(l) <= c
break
endif
b = l
endfor
endif
const d = 99 - 1
var e = ''
if a + d < b
e = '+'
b = a + d
endif
if a > b
return ''
endif
var f = 0
var g = 0
for l in range(a, b)
const h = getline(l)
if h->match('^\s*- \[x\]') !=# -1
f += 1
elseif h->match('^\s*- \[ \]') !=# -1
g += 1
endif
endfor
if f ==# 0 && g ==# 0
return ''
else
return $'✅{f}/{f + g}{e}'
endif
enddef
def BI()
if mode()[0] !=# 'n'
return
endif
const a = BH()
if a !=# get(w:, 'ruler_mdcb', '')
w:ruler_mdcb = a
sil! cmdheight0#Invalidate()
endif
enddef
au vimrc VimEnter,WinNew * w:ruler_mdcb = ''
au vimrc User CursorMovedDelay BI()
if has('win32')
def CA(): string
return &ff !=# 'dos' ? $' {&ff}' : ''
enddef
else
def CA(): string
return &ff ==# 'dos' ? $' {&ff}' : ''
enddef
endif
b:icon = ''
au vimrc WinNew,FileType * b:icon = nerdfont#find()
def! g:RulerBufInfo(): string
if winwidth(winnr()) < 60
return ''
else
var a = &fenc ==# 'utf-8' ? '' : &fenc
a ..= CA()
return a
endif
enddef
g:cmdheight0 = {}
g:cmdheight0.delay = -1
g:cmdheight0.tail = "\ue0c6"
g:cmdheight0.sep = "\ue0c6"
g:cmdheight0.sub = ["\ue0b9", "\ue0bb"]
g:cmdheight0.horiz = '-'
g:cmdheight0.format = ' %{b:icon}%t %m%r%|%=%|%{w:ruler_mdcb|}%{ruler_reg|}%3l:%-2c:%L%|%{RulerBufInfo()|}%{ruler_worktime} '
g:cmdheight0.laststatus = 0
nn ZZ <ScriptCmd>cmdheight0#ToggleZen()<CR>
if lm
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
Enable g:fern#default_hidden
g:fern#renderer = "nerdfont"
def CB()
Enable b:auto_cursorline_disabled
setl cursorline
nn <buffer> <F1> <Cmd>:q!<CR>
nn <buffer> p <Plug>(fern-action-leave)
enddef
au vimrc FileType fern CB()
nn <F1> <Cmd>Fern . -reveal=% -opener=split<CR>
nn <Leader>a <Cmd>PortalAim<CR>
nn <Leader>b <Cmd>PortalAim blue<CR>
nn <Leader>o <Cmd>PortalAim orange<CR>
nn <Leader>r <Cmd>PortalReset<CR>
g:vimhelpgenerator_version = ''
g:vimhelpgenerator_author = 'Author  : utubo'
g:vimhelpgenerator_defaultlanguage = 'en'
g:calendar_first_day = 'sunday'
def CC()
nn <buffer> k <Plug>(calendar_up)
nn <buffer> j <Plug>(calendar_down)
nn <buffer> h <Plug>(calendar_prev)
nn <buffer> l <Plug>(calendar_next)
nn <buffer> gh <Plug>(calendar_left)
nn <buffer> gl <Plug>(calendar_right)
nm <buffer> <CR> >
nm <buffer> <BS> <
enddef
au vimrc FileType calendar CC()
MultiCmd nnoremap,xnoremap / <Cmd>noh<CR>/
MultiCmd nnoremap,xnoremap ? <Cmd>noh<CR>?
MultiCmd nmap,vmap ; :
nn <Space>; ;
nn <Space>: :
Enable g:rainbow_active
g:loaded_matchparen = 1
g:auto_cursorline_wait_ms = &ut
g:ctrlp_match_func = {'match': 'ctrlp_matchfuzzy#matcher'}
g:ctrlp_cmd = 'CtrlPMixed'
g:hlairs = { delay: 250 }
au vimrc VimEnter * silent! NoMatchParen
nn % <ScriptCmd>call hlpairs#Jump()<CR>
nn [c <Plug>(GitGutterPrevHunk)
nn ]c <Plug>(GitGutterNextHunk)
nm <Space>ga :<C-u>Git add %
nm <Space>gc :<C-u>Git commit -m ''<Left>
nm <Space>gp :<C-u>Git push
nn <Space>gv <Cmd>Gvdiffsplit<CR>
nn <Space>gd <Cmd>Gdiffsplit<CR>
nn <Space>gl <Cmd>Git pull<CR>
nn <Space>t <ScriptCmd>tabpopupmenu#popup()<CR>
nn <Space>T <ScriptCmd>tablist#Show()<CR>
MultiCmd nnoremap,xnoremap <Space>c <Plug>(caw:hatpos:toggle)
MultiCmd nnoremap,tnoremap <silent> <C-w><C-s> <Plug>(shrink-height)<C-w>w
MultiCmd nnoremap,tnoremap <silent> <C-w><C-h> <Plug>(shrink-width)<C-w>w
no <Space>s <Plug>(jumpcursor-jump)
const mk = expand($'{lk}/pack/local/opt/*')
if mk !=# ''
&runtimepath = $'{substitute(mk, '\n', ',', 'g')},{&runtimepath}'
endif
def CD()
if expand('%:p') !~# '/colors/'
return
endif
nn <buffer> <expr> ZX $"<Cmd>update<CR><Cmd>colorscheme {expand('%:r')}<CR>"
nn <buffer> <expr> ZB $"<Cmd>set background={&bg ==# 'dark' ? 'light' : 'dark'}<CR>"
enddef
au vimrc FileType vim CD()
filetype plugin indent on
au vimrc InsertLeave * set nopaste
au vimrc BufReadPost *.log* normal! G
xn * "vy/\V<C-r>=substitute(escape(@v,'\/'),"\n",'\\n','g')<CR><CR>
ino jk <Esc>`^
ino <CR> <CR><C-g>u
set mps+=（:）,「:」,『:』,【:】,［:］,＜:＞
nn <expr> i !empty(getline('.')) ? 'i' : '"_cc'
nn <expr> a !empty(getline('.')) ? 'a' : '"_cc'
nn <expr> A !empty(getline('.')) ? 'A' : '"_cc'
def CE()
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
au vimrc BufReadPost * CE()
def CF(a: string, ...b: list<string>)
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
com! -nargs=+ VimGrep CF(<f-args>)
nm <Space>/ :<C-u>VimGrep<Space>
def CG()
nn <buffer> <silent> ; <CR>:silent! normal! zv<CR><C-W>w
nn <buffer> <silent> w <C-W><CR>:silent! normal! zv<CR><C-W>w
nn <buffer> <silent> t <C-W><CR>:silent! normal! zv<CR><C-W>T
nn <buffer> <nowait> q <Cmd>lexpr ''<CR>:q<CR>
nn <buffer> f <C-f>
nn <buffer> b <C-b>
exe $'nnoremap <buffer> T <C-W><CR><C-W>T{tabpagenr()}gt'
enddef
au vimrc FileType qf CG()
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
nm g<Space> g;
for i in range(1, 10)
exe $'nmap <Space>{i % 10} <F{i}>'
endfor
nm <Space><Space>1 <F11>
nm <Space><Space>2 <F12>
def! g:MyFoldText(): string
const a = getline(v:foldstart)
const b = repeat(' ', indent(v:foldstart))
const c = &fdm ==# 'indent' ? '' : a->substitute(matchstr(&foldmarker, '^[^,]*'), '', '')->trim()
return $'{b}{c} 📁'
enddef
set fdt=g:MyFoldText()
set fcs+=fold:\ 
au vimrc ColorScheme * hi! link Folded Delimiter
au vimrc ColorScheme * hi! link ALEVirtualTextWarning ALEWarningSign
au vimrc ColorScheme * hi! link ALEVirtualTextError ALEErrorSign
def CH()
var [a, b] = H()
exe ':' a 's/\v(\S)?$/\1 /'
append(b, D(a))
cursor([a, 1])
cursor([b + 1, 1])
normal! zf
enddef
xn zf <ScriptCmd>CH()<CR>
def CI()
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
nn zd <ScriptCmd>CI()<CR>
set fdm=marker
au vimrc FileType markdown,yaml setlocal foldlevelstart=99 foldmethod=indent
au vimrc BufReadPost * :silent! normal! zO
nn <expr> h (col('.') ==# 1 && 0 < foldlevel('.') ? 'zc' : 'h')
nn Z<Tab> <Cmd>set foldmethod=indent<CR>
nn Z{ <Cmd>set foldmethod=marker<CR>
nn Zy <Cmd>set foldmethod=syntax<CR>
g:tabline_mod_sign = '✏'
g:tabline_git_sign = '🐙'
g:tabline_dir_sign = '📂'
g:tabline_maxlen = 20
g:tabline_labelsep = has('gui') ? ', ' : '|'
def CJ(a: list<number>, c: string = ''): string
var d = ''
var e = ''
var f = ''
for b in a
const h = getbufvar(b, '&filetype')
if !f && (h ==# 'netrw' || h ==# 'fern')
f = g:tabline_dir_sign
endif
if !d && getbufvar(b, '&modified')
d = g:tabline_mod_sign
endif
if !e
var g = false
sil! g = len(getbufvar(b, 'gitgutter', {'hunks': []}).hunks) !=# 0
if g
e = g:tabline_git_sign
endif
endif
endfor
return d .. e .. f .. c
enddef
def! g:MyTablabel(a: number = 0): string
var c = ''
var d = tabpagebuflist(a)
const e = tabpagewinnr(a) - 1
d = remove(d, e, e) + d
var f = []
var i = -1
for b in d
i += 1
if len(f) ==# 2
f += [CJ(d[i : ], '..')]
break
endif
var h = bufname(b)
h = !h ? '[No Name]' : h->pathshorten()[- g:tabline_maxlen : ]
if f->index(h) ==# -1
f += [CJ([b], h)]
endif
endfor
c ..= f->join(g:tabline_labelsep)
return c
enddef
def! g:MyTabline(): string
var a = '%#TabLineFill#'
a ..= repeat(' ', getwininfo(win_getid(1))[0].textoff)
const b = tabpagenr()
for c in range(1, tabpagenr('$'))
a ..= c ==# b ? '%#TabLineSel#' : '%#TabLine#'
a ..= ' '
a ..= g:MyTablabel(c)
a ..= ' '
endfor
a ..= '%#TabLineFill#%T'
return a
enddef
set tabline=%!g:MyTabline()
set guitablabel=%{g:MyTablabel()}
def DA(a: string)
const b = getcurpos()
exe a
setpos('.', b)
enddef
xn u <ScriptCmd>DA('undo')<CR>
xn <Space>u u
xn <C-R> <ScriptCmd>DA('redo')<CR>
xn <Tab> <Cmd>normal! >gv<CR>
xn <S-Tab> <Cmd>normal! <gv<CR>
cno <C-h> <Left>
cno <C-l> <Right>
cno <C-n> <Down>
cno <C-p> <Up>
cno <expr> <C-r><C-r> trim(@")->substitute('\n', ' \| ', 'g')
cno <expr> <C-r><C-e> escape(@", '~^$.*?/\[]')->substitute('\n', '\\n', 'g')
cnoreabbrev cs colorscheme
cno jk <C-c>
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
def DB()
for l in I()
const a = getline(l)
var b = substitute(a, '^\(\s*\)- \[ \]', '\1- [x]', '')
if a ==# b
b = substitute(a, '^\(\s*\)- \[x\]', '\1- [ ]', '')
endif
if a ==# b
b = substitute(a, '^\(\s*\)\(- \)*', '\1- [ ] ', '')
endif
setline(l, b)
if l ==# line('.')
var c = getpos('.')
c[2] += len(b) - len(a)
setpos('.', c)
endif
endfor
enddef
no <Space>x <ScriptCmd>DB()<CR>
nn <expr> o 'o' .. matchstr(getline('.'), '\(^\s*\)\@<=- \(\[[x* ]]\)\? \?')
nn <expr> O 'O' .. matchstr(getline('.'), '\(^\s*\)\@<=- \(\[[x* ]]\)\? \?')
def DC(a: string = '')
if &ft ==# 'qf'
return
endif
var b = a ==# 'BufReadPost'
if b && !filereadable(expand('%'))
return
endif
var c = []
add(c, ['Title', $'"{bufname()}"'])
add(c, ['Normal', ' '])
if &modified
add(c, ['Delimiter', '[+]'])
add(c, ['Normal', ' '])
endif
if !b && !filereadable(expand('%'))
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
add(c, ['MoreMsg', &ff])
add(c, ['Normal', ' '])
const e = empty(&fenc) ? &enc : &fenc
add(c, [e ==# 'utf-8' ? 'MoreMsg' : 'WarningMsg', e])
add(c, ['Normal', ' '])
add(c, ['MoreMsg', &ft])
var f = 0
const g = &columns - 2
for i in reverse(range(0, len(c) - 1))
var s = c[i][1]
var d = strdisplaywidth(s)
f += d
if g < f
const l = g - f + d
while !empty(s) && l < strdisplaywidth(s)
s = s[1 :]
endwhile
c[i][1] = s
c = c[i : ]
insert(c, ['SpecialKey', '<'], 0)
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
def DD()
popup_create($' {line(".")}:{col(".")} ', {
pos: 'botleft',
line: 'cursor-1',
col: 'cursor+1',
moved: 'any',
padding: [1, 1, 1, 1],
})
enddef
nn <C-g> <ScriptCmd>call <SID>DC()<CR><scriptCmd>call <SID>DD()<CR>
au vimrc BufNewFile,BufReadPost,BufWritePost * DC('BufNewFile')
def DE(a: string = '')
if !!a
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
nn qh <ScriptCmd>DE('h')<CR>
nn qj <ScriptCmd>DE('j')<CR>
nn qk <ScriptCmd>DE('k')<CR>
nn ql <ScriptCmd>DE('l')<CR>
nn qq <ScriptCmd>DE()<CR>
nn q<CR> <ScriptCmd>DE()<CR>
nn qn <Cmd>confirm tabclose +<CR>
nn qp <Cmd>confirm tabclose -<CR>
nn q# <Cmd>confirm tabclose #<CR>
nn qo <Cmd>confirm tabonly<CR>
nn q: q:
nn q/ q/
nn q? q?
def DF(a: string)
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
com! -nargs=1 -complete=file MoveFile DF(<f-args>)
cnoreabbrev mv MoveFile
cno <expr> <SID>(exec_line) $'{getline('.')->substitute('^[ \t"#:]\+', '', '')}<CR>'
nm g: :<C-u><SID>(exec_line)
nm g9 :<C-u>vim9cmd <SID>(exec_line)
xn g: "vy:<C-u><C-r>=@v<CR><CR>
xn g9 "vy:<C-u>vim9cmd <C-r>=@v<CR><CR>
nn <expr> <Space>gh $'<Cmd>hi {synID(line('.'), col('.'), 1)->synIDattr('name')->substitute('^$', 'Normal', '')}<CR>'
au vimrc FileType vim nnoremap g! <Cmd>update<CR><Cmd>source %<CR>
if has('clipboard')
au vimrc FocusGained * @" = @+
au vimrc FocusLost * @+ = @"
endif
def DG()
if &number
set nonumber
elseif &relativenumber
set number norelativenumber
else
set relativenumber
endif
enddef
nn <F11> <ScriptCmd>DG()<CR>
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
nn <expr> j (getline('.')->match('\S') + 1 ==# col('.')) ? '+' : 'j'
nn <expr> k (getline('.')->match('\S') + 1 ==# col('.')) ? '-' : 'k'
nm <CR> <Space>
nn TE :<C-u>tabe<Space>
nn TN <Cmd>tabnew<CR>
nn TD <Cmd>tabe ./<CR>
nn TT <Cmd>silent! tabnext #<CR>
ono <expr> } $"\<Esc>m`0{v:count1}{v:operator}\}"
ono <expr> { $"\<Esc>m`V{v:count1}\{{v:operator}"
xn <expr> h mode() ==# 'V' ? '<Esc>h' : 'h'
xn <expr> l mode() ==# 'V' ? '<Esc>l' : 'l'
xn J j
xn K k
ino ｋｊ <Esc>`^
ino 「 「」<Left>
ino 「」 「」<Left>
ino （ ()<Left>
ino （） ()<Left>
xn <expr> p $'"_s<C-R>{v:register}<ESC>'
xn P p
nn <silent> g; g;zo
nn <Space>h ^
nn <Space>l $
nn <Space>d "_d
nn <Space>n <Cmd>nohlsearch<CR>
au vimrc CursorHold * feedkeys(' n') # nohはauで動かない(:help noh)
nn <Space>w <C-w>w
nn <Space>o <C-w>w
nn <silent> <F10> <ESC>1<C-w>s:1<CR><C-w>w
xn <F10> <ESC>1<C-w>s<C-w>w
nn ' "
nn m '
nn M m
ino jj <C-o>
ino jje <C-o>e<C-o>a
ino jj; <C-o>$;<CR>
ino jj<Space> <C-o>$<CR>
ino jjk 「」<Left>
ino jjx <ScriptCmd>DB()<CR>
ino <M-x> <ScriptCmd>DB()<CR>
def DH()
for a in get(w:, 'my_syntax', [])
matchdelete(a)
endfor
w:my_syntax = []
enddef
def DI(a: string, b: string)
w:my_syntax->add(matchadd(a, b))
enddef
au vimrc Syntax * DH()
au vimrc Syntax javascript,vim DI('SpellRare', '\s[=!]=\s')
au vimrc Syntax vim DI('SpellRare', '\<normal!\@!')
def DJ()
var a = J()->join('')
popup_create($'{strlen(a)}chars', {
pos: 'botleft',
line: 'cursor-1',
col: 'cursor+1',
moved: 'any',
padding: [1, 1, 1, 1],
})
enddef
vn <C-g> <ScriptCmd>DJ()<CR>
def EA(): string
const c = matchstr(getline('.'), '.', col('.') - 1)
if !c || stridx(')]}"''`」', c) ==# -1
return 'll'
endif
const a = matchstr(getline('.'), '.', col('.') - 2)
if stridx('a', a) !=# -1
return 'll'
endif
return "\<C-o>a"
enddef
ino <expr> ll EA()
au vimrc FileType html,xml,svg nnoremap <buffer> <silent> <Tab> <Cmd>call search('>')<CR><Cmd>call search('\S')<CR>
au vimrc FileType html,xml,svg nnoremap <buffer> <silent> <S-Tab> <Cmd>call search('>', 'b')<CR><Cmd>call search('>', 'b')<CR><Cmd>call search('\S')<CR>
nn <Space>a A
nm S^ v^S
nm S$ vg_S
nn <expr> <Space>m $'<Cmd>{getpos("'<")[1]},{getpos("'>")[1]}move {getpos('.')[1]}<CR>'
if strftime('%d') ==# '01'
def EB()
notification#show("✨ Today, Let's enjoy the default key mapping ! ✨")
imapclear
mapclear
enddef
au vimrc VimEnter * EB()
endif
def EC()
g:rainbow_conf = {
guifgs: ['#9999ee', '#99ccee', '#99ee99', '#eeee99', '#ee99cc', '#cc99ee'],
ctermfgs: ['105', '117', '120', '228', '212', '177']
}
g:rcsv_colorpairs = [
['105', '#9999ee'], ['117', '#99ccee'], ['120', '#99ee99'],
['228', '#eeee99'], ['212', '#ee99cc'], ['177', '#cc99ee']
]
enddef
def ED()
hi! link CmdHeight0Horiz TabLineFill
hi! link ALEVirtualTextWarning ALEStyleWarningSign
hi! link ALEVirtualTextError ALEStyleErrorSign
hi! link CmdHeight0Horiz MoreMsg
enddef
au vimrc ColorSchemePre * EC()
au vimrc ColorScheme * ED()
def EE()
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
au vimrc VimEnter,WinEnter * EE()
def EF()
if &list && !exists('w:hi_tail')
w:hi_tail = matchadd('SpellBad', '\s\+$')
elseif !&list && exists('w:hi_tail')
matchdelete(w:hi_tail)
unlet w:hi_tail
endif
enddef
au vimrc OptionSet list silent! EF()
au vimrc BufNew,BufReadPost * silent! EF()
set t_Co=256
syntax on
set bg=dark
sil! colorscheme girly
if '~/.vimrc_local'->expand()->filereadable()
so ~/.vimrc_local
endif
def EG()
var a = get(v:oldfiles, 0, '')->expand()
if a->filereadable()
exe 'edit' a
endif
enddef
au vimrc VimEnter * ++nested if !C()|EG()|endif
