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
const lk = has('win32') ? '~/vimfiles' : '~/.vim'
const ll = executable('deno')
def A(b: string)
const [c, d] = b->split('^\S*\zs')
for e in c->split(',')
const a = d
->substitute($'<if-{e}>', '<endif>', 'g')
->substitute('<if-[^>]\+>.\{-1,}\(<endif>\|$\)', '', 'g')
->substitute('<endif>', '', 'g')
exe e a
endfor
enddef
com! -nargs=* CmdEach A(<q-args>)
def B(a: string)
const [b, c] = a->split('^\S*\zs')
for i in b->split(',')
exe c->substitute('{}', i, 'g')
endfor
enddef
com! -nargs=* Each B(<q-args>)
com! -nargs=1 -complete=var Enable <args> = 1
com! -nargs=1 -complete=var Disable <args> = 0
def C(): bool
return &modified || ! empty(bufname())
enddef
def g:IndentStr(a: any): string
return matchstr(getline(a), '^\s*')
enddef
def D(a: string)
const b = getline('.')->len()
var c = getcurpos()
exe a
c[2] += getline('.')->len() - b
setpos('.', c)
enddef
def E(a: string, b: number): string
if b <= 0
return ''
endif
return strdisplaywidth(a) <= b ? a : $'{a->matchstr($'.*\%<{b + 1}v')}>'
enddef
def! g:VFirstLast(): list<number>
return [line('.'), line('v')]->sort('n')
enddef
def! g:VRange(): list<number>
const a = g:VFirstLast()
return range(a[0], a[1])
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
Jetpack 'cohama/lexima.vim'
Jetpack 'delphinus/vim-auto-cursorline'
Jetpack 'easymotion/vim-easymotion'
Jetpack 'girishji/vimcomplete'
Jetpack 'girishji/autosuggest.vim'
Jetpack 'hrsh7th/vim-vsnip'
Jetpack 'hrsh7th/vim-vsnip-integ'
Jetpack 'itchyny/calendar.vim'
Jetpack 'kana/vim-textobj-user'
Jetpack 'kana/vim-smartword'
Jetpack 'KentoOgata/vim-vimscript-gd'
Jetpack 'LeafCage/vimhelpgenerator'
Jetpack 'luochen1990/rainbow'
Jetpack 'machakann/vim-sandwich'
Jetpack 'mattn/vim-notification'
Jetpack 'matze/vim-move'
Jetpack 'michaeljsmith/vim-indent-object'
Jetpack 'MTDL9/vim-log-highlighting'
Jetpack 'obcat/vim-hitspop'
Jetpack 'obcat/vim-sclow'
Jetpack 'osyo-manga/vim-textobj-multiblock'
Jetpack 'skanehira/gh.vim'
Jetpack 'thinca/vim-portal'
Jetpack 'thinca/vim-themis'
Jetpack 'tpope/vim-fugitive'
Jetpack 'tyru/capture.vim'
Jetpack 'tyru/caw.vim'
Jetpack 'yegappan/lsp'
Jetpack 'yegappan/mru'
Jetpack 'yuki-yano/dedent-yank.vim'
Jetpack 'vim-jp/vital.vim'
Jetpack 'lambdalisue/fern.vim'
Jetpack 'lambdalisue/fern-git-status.vim'
Jetpack 'lambdalisue/fern-renderer-nerdfont.vim'
Jetpack 'lambdalisue/fern-hijack.vim'
Jetpack 'lambdalisue/nerdfont.vim'
Jetpack 'ctrlpvim/ctrlp.vim'
Jetpack 'mattn/ctrlp-matchfuzzy'
Jetpack 'sheerun/vim-polyglot'
Jetpack 'tani/vim-typo'
Jetpack 'utubo/vim-altkey-in-term'
Jetpack 'utubo/vim-colorscheme-girly'
Jetpack 'utubo/vim-colorscheme-softgreen'
Jetpack 'utubo/vim-hlpairs'
Jetpack 'utubo/vim-minviml'
Jetpack 'utubo/vim-registers-lite'
Jetpack 'utubo/vim-reformatdate'
Jetpack 'utubo/vim-skipslash'
Jetpack 'utubo/vim-yomigana'
Jetpack 'utubo/vim-vim9skk'
Jetpack 'utubo/vim-zenmode'
Jetpack 'utubo/jumpcursor.vim'
Jetpack 'utubo/vim-ddgv'
Jetpack 'utubo/vim-portal-aim'
Jetpack 'utubo/vim-shrink'
Jetpack 'utubo/vim-tablist'
Jetpack 'utubo/vim-tabpopupmenu'
Jetpack 'utubo/vim-textobj-twochars'
if ll
Jetpack 'vim-denops/denops.vim'
endif
jetpack#end()
if ! ln
jetpack#sync()
endif
g:zenmode = {}
au vimrc User Vim9skkModeChanged zenmode#Invalidate()
Enable g:EasyMotion_smartcase
Enable g:EasyMotion_use_migemo
Enable g:EasyMotion_enter_jump_first
Disable g:EasyMotion_verbose
Disable g:EasyMotion_do_mapping
g:EasyMotion_keys = 'asdghklqwertyuiopzxcvbnmfjASDGHKLQWERTYUIOPZXCVBNMFJ;'
g:EasyMotion_prompt = 'EasyMotion: '
no s <Plug>(easymotion-s)
Enable g:fern#default_hidden
g:fern#renderer = "nerdfont"
au vimrc FileType fern {
Enable b:auto_cursorline_disabled
setl cursorline
nn <buffer> <F1> <Cmd>:q!<CR>
nn <buffer> p <Plug>(fern-action-leave)
}
nn <expr> <F1> $"\<Cmd>Fern . -reveal=% -opener={!bufname() && !&mod ? 'edit' : 'split'}\<CR>"
def F(a: string)
const b = getcwd()
try
chdir(expand('%:p:h'))
echoh MoreMsg
ec 'git add --dry-run ' .. a
const c = system('git add --dry-run ' .. a)
if !!v:shell_error
echoh ErrorMsg
ec c
return
endif
if !c
ec 'none.'
return
endif
for d in split(c, '\n')
exe 'echoh' (d =~# '^remove' ? 'DiffDelete' : 'DiffAdd')
ec d
endfor
echoh Question
if input('execute ? (y/n) > ', 'y') ==# 'y'
system('git add ' .. a)
endif
finally
echoh Normal
chdir(b)
endtry
enddef
com! -nargs=* GitAdd F(<q-args>)
def! g:ConventionalCommits(a: any, l: string, p: number): list<string>
return ['✨feat:', '🐞fix:', '📝docs:', '🔨refactor:', '🎨style:', '⏪revert:', '✅test:', '🔧chore:', '🎉release:']
enddef
com! -nargs=1 -complete=customlist,g:ConventionalCommits GitCommit Git commit -m <q-args>
def G(a: string)
ec system($"git tag '{a}'")
ec system($"git push origin '{a}'")
enddef
com! -nargs=1 GitTagPush G(<q-args>)
nn <Space>ga <Cmd>GitAdd -A<CR>
nn <Space>gA :<C-u>Git add %
nn <Space>gc :<C-u>GitCommit<Space><Tab>
nn <Space>gp :<C-u>Git push
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
Enable g:lexima_no_default_rules
lexima#set_default_rules()
ino <expr> <CR> pumvisible() ? "\<C-Y>" : (lexima#expand('<CR>', 'i') .. "\<ScriptCmd>doau User InputCR\<CR>")
def g:SetupLexima(a: number)
lexima#add_rule({ char: '(', at: '\\\%#', input_after: '\)', mode: 'ic' })
lexima#add_rule({ char: '{', at: '\\\%#', input_after: '\}', mode: 'ic' })
lexima#add_rule({ char: ')', at: '\%#\\)', leave: 2, mode: 'ic' })
lexima#add_rule({ char: '}', at: '\%#\\}', leave: 2, mode: 'ic' })
lexima#add_rule({ char: '\', at: '\%#\\[)}]', leave: 1, mode: 'ic' })
au vimrc ModeChanged *:c* ++once {
for b in ['()', '{}', '""', "''", '``']
lexima#add_rule({ char: b[0], input_after: b[1], mode: 'c' })
lexima#add_rule({ char: b[1], at: '\%#' .. b[1], leave: 1, mode: 'c' })
endfor
lexima#add_rule({ char: "'", at: '[a-zA-Z]\%#''\@!', mode: 'c' })
}
enddef
timer_start(1000, g:SetupLexima)
var lspOptions = {
diagSignErrorText: '🐞',
diagSignHintText: '💡',
diagSignInfoText: '💠',
diagSignWarningText: '🐝',
showDiagWithVirtualText: true,
diagVirtualTextAlign: 'after',
}
const lp = has('win32') ? '.cmd' : ''
var lspServers = [{
name: 'typescriptlang',
filetype: ['javascript', 'typescript'],
path: $'typescript-language-server{lp}',
args: ['--stdio'],
}, {
name: 'vimlang',
filetype: ['vim'],
path: $'vim-language-server{lp}',
args: ['--stdio'],
}, {
name: 'htmllang',
filetype: ['html'],
path: $'html-languageserver{lp}',
args: ['--stdio'],
}, {
name: 'jsonlang',
filetype: ['json'],
path: $'vscode-json-languageserver{lp}',
args: ['--stdio'],
}]
au vimrc VimEnter * call LspOptionsSet(lspOptions)
au vimrc VimEnter * call LspAddServer(lspServers)
nn [l <Cmd>LspDiagPrev<CR>
nn ]l <Cmd>LspDiagNext<CR>
nn <F2> <Cmd>MRUToggle<CR>
g:MRU_Exclude_Files = has('win32') ? $'{$TEMP}\\.*' : '^/tmp/.*\|^/var/tmp/.*'
nn <Leader>a <Cmd>PortalAim<CR>
nn <Leader>b <Cmd>PortalAim blue<CR>
nn <Leader>o <Cmd>PortalAim orange<CR>
nn <Leader>r <Cmd>PortalReset<CR>
Enable g:sandwich_no_default_key_mappings
Enable g:operator_sandwich_no_default_key_mappings
CmdEach nmap,xmap S <ScriptCmd>vimrc#sandwich#ApplySettings('S')<CR>
g:vim9skk = {
keymap: {
toggle: ['<C-j>', ';j'],
midasi: [':', 'Q'],
}
}
g:vim9skk_mode = ''
nn ;j i<Plug>(vim9skk-enable)
au vimrc User Vim9skkEnter AutoSuggestDisable
au vimrc User Vim9skkLeave AutoSuggestEnable
au vimrc User Vim9skkEnter feedkeys('Q')
au vimrc User Vim9skkInitPre vimrc#vim9skk#ApplySettings()
CmdEach onoremap,xnoremap ab <Plug>(textobj-multiblock-a)
CmdEach onoremap,xnoremap ib <Plug>(textobj-multiblock-i)
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
def H(): string
const c = matchstr(getline('.'), '.', col('.') - 1)
if !c || stridx(')]}>"''`」', c) ==# -1
return "\<Tab>"
else
return "\<C-o>a"
endif
enddef
CmdEach imap,smap <expr> <Tab> vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : pumvisible() ? '<C-n>' : H()
CmdEach imap,smap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : pumvisible() ? '<C-p>' : '<S-Tab>'
Enable g:rainbow_active
Enable g:ctrlp_use_caching
Disable g:ctrlp_clear_cache_on_exit
g:ctrlp_match_func = {'match': 'ctrlp_matchfuzzy#matcher'}
g:ctrlp_cmd = 'CtrlPMixed'
g:auto_cursorline_wait_ms = &ut
Each w,b,e,ge nnoremap {} <Plug>(smartword-{})
nn [c <Plug>(GitGutterPrevHunk)
nn ]c <Plug>(GitGutterNextHunk)
CmdEach nnoremap,xnoremap <Space>c <Plug>(caw:hatpos:toggle)
g:skipslash_autocomplete = 1
g:loaded_matchparen = 1
g:loaded_matchit = 1
nn % <ScriptCmd>hlpairs#Jump()<CR>
nn ]% <ScriptCmd>hlpairs#Jump('f')<CR>
nn [% <ScriptCmd>hlpairs#Jump('b')<CR>
ono a% <ScriptCmd>hlpairs#TextObj(true)<CR>
ono i% <ScriptCmd>hlpairs#TextObj(false)<CR>
nn <Leader>% <ScriptCmd>hlpairs#HighlightOuter()<CR>
nn <Space>% <ScriptCmd>hlpairs#ReturnCursor()<CR>
nn <Space>t <ScriptCmd>tabpopupmenu#popup()<CR>
nn <Space>T <ScriptCmd>tablist#Show()<CR>
CmdEach nnoremap,tnoremap <silent> <C-w><C-s> <Plug>(shrink-height)<C-w>w
CmdEach nnoremap,tnoremap <silent> <C-w><C-h> <Plug>(shrink-width)<C-w>w
no <Space>s <Plug>(jumpcursor-jump)
g:vimhelpgenerator_version = ''
g:vimhelpgenerator_author = 'Author  : utubo'
g:vimhelpgenerator_defaultlanguage = 'en'
g:vimhelpgenerator_uri = 'https://github.com/utubo/'
filetype plugin indent on
au vimrc InsertLeave * set nopaste
au vimrc BufReadPost *.log* normal! G
xn * "vy/\V<C-r>=substitute(escape(@v,'\/'),"\n",'\\n','g')<CR><CR>
set mps+=（:）,「:」,『:』,【:】,［:］,＜:＞
Each i,a,A nnoremap <expr> {} !empty(getline('.')) ? '{}' : '"_cc'
Each +,-,>,< CmdEach nmap,tmap <C-w>{} <C-w>{}<SID>ws
Each +,-,>,< CmdEach nnoremap,tnoremap <script> <SID>ws{} <C-w>{}<SID>ws
CmdEach nmap,tmap <SID>ws <Nop>
def I()
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
au vimrc BufReadPost * I()
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
nn gn <Cmd>bnext<CR>
nn gp <Cmd>bprevious<CR>
var lq = []
def J()
lq = []
for a in execute('ls')->split("\n")
const m = a->matchlist('^ *\([0-9]\+\)\([^"]*\)"\(.*\)" \+line [0-9]\+')
if !m->empty()
const c = m[2]->stridx('%') !=# -1
var b = { nr: m[1], name: m[3]->pathshorten(), current: c }
lq += [b]
b.width = strdisplaywidth($'{b.nr}{b.name} ')
endif
endfor
BA()
g:zenmode.preventEcho = lq->len() > 1
enddef
def BA()
if lq->len() <= 1
return
endif
redraw
var s = 0
var e = 0
var w = 0
var a = false
var c = false
var d = false
for b in lq
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
w = 0
if c
echoh StatusLineNC
echon '< '
w += 2
endif
for b in lq[s : e]
w += b.width
if b.current
echoh StatusLineTermNC
echon b.nr
else
echoh StatusLineNC
echon b.nr
endif
echoh StatusLine
echon $'{b.name} '
endfor
if a
echoh StatusLineNC
echon '>'
w += 1
endif
const f = &columns - 1 - w
if 0 < f
echon repeat(' ', &columns - 1 - w)
endif
echoh Normal
enddef
au vimrc BufAdd,BufEnter * J()
au vimrc BufDelete,BufWipeout * au vimrc SafeState * ++once J()
au vimrc CursorMoved * BA()
g:tabline_mod_sign = "\uf040"
g:tabline_git_sign = '🐙'
g:tabline_dir_sign = '📂'
g:tabline_term_sign = "\uf489"
g:tabline_labelsep = '|'
g:tabline_maxlen = 20
def BB(a: list<number>, c: bool = false): string
var d = ''
var e = ''
for b in a
const f = getbufvar(b, '&buftype')
if f ==# ''
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
endif
if c
continue
endif
if f ==# 'terminal'
return g:tabline_term_sign
endif
const h = getbufvar(b, '&filetype')
if h ==# 'netrw' || h ==# 'fern'
return g:tabline_dir_sign
endif
endfor
return d .. e
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
f += [(BB(d[i : ], true) .. '>')]
break
endif
var h = bufname(b)
if !h
h = '[No Name]'
elseif getbufvar(b, '&buftype') ==# 'terminal'
h = term_getline(b, '.')->trim()
endif
h = h->pathshorten()
if g:tabline_maxlen < len(h)
h = '<' .. h->matchstr(repeat('.', g:tabline_maxlen - 1) .. '$')
endif
if f->index(h) ==# -1
f += [BB([b]) .. h]
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
ino ;<CR> ;<CR>
ino ;<Esc> ;<Esc>
ino ;<Space> ;<Space>
ino ;; <Esc>`^
cno ;; <C-c>
ino ;e <C-o>e<C-o>a
ino ;k 「」<C-g>U<Left>
ino ;l <C-g>R<Right>
ino ;u <C-o>u
nn ;r <C-r>
nn ;v V
CmdEach nnoremap,inoremap ;<Tab> <ScriptCmd>D('normal! >>')<CR>
CmdEach nnoremap,inoremap ;<S-Tab> <ScriptCmd>D('normal! <<')<CR>
CmdEach nnoremap,xnoremap ;; <Esc>
CmdEach nnoremap,inoremap ;n <Cmd>update<CR><Esc>
nn <Space>; ;
map! <script> <SID>bs_ <Nop>
map! <script> ;h <SID>bs_h
no! <script> <SID>bs_h <BS><SID>bs_
xn u <ScriptCmd>undo\|normal! gv<CR>
xn <C-R> <ScriptCmd>redo\|normal! gv<CR>
xn <Tab> <ScriptCmd>D('normal! >gv')<CR>
xn <S-Tab> <ScriptCmd>D('normal! <gv')<CR>
const vmode = ['v', 'V', "\<C-v>", "\<ESC>"]
xn <script> <expr> v vmode[vmode->index(mode()) + 1]
CmdEach nnoremap,xnoremap / <Cmd>noh<CR>/
CmdEach nnoremap,xnoremap ? <Cmd>noh<CR>?
CmdEach nnoremap,xnoremap ;c :
CmdEach nnoremap,xnoremap ;s <Cmd>noh<CR>/
CmdEach nnoremap,xnoremap + :
CmdEach nnoremap,xnoremap , :
CmdEach nnoremap,xnoremap <Space><Space>, ,
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
def BC(a: string = '')
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
def BD()
popup_create($' {line(".")}:{col(".")} ', {
pos: 'botleft',
line: 'cursor-1',
col: 'cursor+1',
moved: 'any',
padding: [1, 1, 1, 1],
})
enddef
nn <script> <C-g> <ScriptCmd>BC()<CR><scriptCmd>BD()<CR>
au vimrc BufNewFile,BufReadPost,BufWritePost * BC('BufNewFile')
def BE(a: string)
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
Each h,j,k,l nnoremap q{} <ScriptCmd>BE('{}')<CR>
nn q <Nop>
nn Q q
nn qq <Cmd>confirm q<CR>
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
nn <Space><Tab>u <Cmd>call vimrc#recentlytabs#ReopenRecentlyTab()<CR>
nn <Space><Tab>l <Cmd>call vimrc#recentlytabs#ShowMostRecentlyClosedTabs()<CR>
nn <Space>n <Cmd>nohlsearch<CR>
au vimrc CursorHold * feedkeys(' n') # nohはauで動かない(:help noh)
nn <Tab> <Cmd>call search('\(^\\|\t\\|, *\)\S\?', 'e')<CR>
nn <S-Tab> <Cmd>call search('\(^\\|\t\\|, *\)\S\?', 'be')<CR>
au vimrc FileType html,xml,svg {
nn <buffer> <silent> <Tab> <Cmd>call search('>')<CR><Cmd>call search('\S')<CR>
nn <buffer> <silent> <S-Tab> <Cmd>call search('>', 'b')<CR><Cmd>call search('>', 'b')<CR><Cmd>call search('\S')<CR>
}
nn <silent> <F10> <ESC>1<C-w>s:1<CR><C-w>w
xn <F10> <ESC>1<C-w>s<C-w>w
nn <F9> my
nn <S-F9> 'y
def BF()
for a in get(w:, 'my_syntax', [])
matchdelete(a)
endfor
w:my_syntax = []
enddef
def BG(a: string, b: string)
w:my_syntax->add(matchadd(a, b))
enddef
au vimrc Syntax * BF()
au vimrc Syntax javascript {
BG('SpellRare', '\s[=!]=\s')
}
au vimrc Syntax vim {
BG('SpellRare', '\s[=!]=\s')
BG('SpellBad', '\s[=!]==\s')
BG('SpellBad', '\s\~[=!][=#]\?\s')
BG('SpellRare', '\<normal!\@!')
}
def BH()
const a = ('📋 ' .. @"[0 : winwidth(0)])
->substitute('\t', '›', 'g')
->substitute('\n', '↵', 'g')
const b = a->E(winwidth(0) - 10)
const c = popup_create(b, {
line: 'cursor+1',
col: 'cursor+1',
pos: 'topleft',
padding: [0, 1, 0, 1],
fixed: true,
moved: 'any',
time: 2000,
})
win_execute(c, 'syntax match PmenuExtra /[›↵]\|.\@<=>$/')
enddef
au vimrc TextYankPost * BH()
def BI()
normal! "vy
var a = @v->substitute('\n', '', 'g')
popup_create($'{strlen(a)}chars', {
pos: 'botleft',
line: 'cursor-1',
col: 'cursor+1',
moved: 'any',
padding: [1, 1, 1, 1],
})
enddef
xn <C-g> <ScriptCmd>BI()<CR>
def BJ(): string
cno ;; <C-c>
cno h <Left>
cno l <Right>
cno b <S-Left>
cno w <S-Right>
cno $ <End><Left>
cno ^ <Home>
cno x <Delete>
cno <script> <expr> i CA('i')
cno <script> <expr> a CA('a')
cm A $a
return ""
enddef
def CA(c: string = 'i'): string
Each h,l,b,w,^,$,x,i,a,A silent! cunmap {}
cno <script> <expr> ;n BJ()
return c ==# 'i' ? '' : "\<Right>"
enddef
au vimrc ModeChanged *:c CA()
com! -nargs=1 Brep vimrc#myutil#Brep(<q-args>, <q-mods>)
Each f,b nmap <C-{}> <C-{}><SID>(hold-ctrl)
Each f,b nnoremap <script> <SID>(hold-ctrl){} <C-{}><SID>(hold-ctrl)
nm <SID>(hold-ctrl) <Nop>
CmdEach onoremap A <Plug>(textobj-twochars-a)
CmdEach onoremap I <Plug>(textobj-twochars-i)
nn <Space>w <C-w>w
nn <Space>o <C-w>w
nn <Space><Space>p o<Esc>P
nn <Space><Space>P O<Esc>p
nn <Space>d "_d
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
nn <expr> ZB $"<Cmd>set background={&bg ==# 'dark' ? 'light' : 'dark'}<CR>"
au vimrc ColorSchemePre * {
g:rcsv_colorpairs = [
['105', '#9999ee'], ['117', '#99ccee'], ['120', '#99ee99'],
['228', '#eeee99'], ['212', '#ee99cc'], ['177', '#cc99ee']
]
}
def CB(a: number, b: string): string
const v = synIDattr(a, b)->matchstr(has('gui') ? '.*[^0-9].*' : '^[0-9]\+$')
return !v ? 'NONE' : v
enddef
def CC(a: string): any
const b = hlID(a)->synIDtrans()
return { fg: CB(b, 'fg'), bg: CB(b, 'bg') }
enddef
def CD()
hi! link CmdHeight0Horiz MoreMsg
const x = has('gui') ? 'gui' : 'cterm'
const a = CC('LineNr').bg
exe $'hi LspDiagSignErrorText   {x}bg={a} {x}fg={CC("ErrorMsg").fg}'
exe $'hi LspDiagSignHintText    {x}bg={a} {x}fg={CC("Question").fg}'
exe $'hi LspDiagSignInfoText    {x}bg={a} {x}fg={CC("Pmenu").fg}'
exe $'hi LspDiagSignWarningText {x}bg={a} {x}fg={CC("WarningMsg").fg}'
enddef
au vimrc VimEnter,ColorScheme * CD()
def CE()
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
au vimrc VimEnter,WinEnter * CE()
def CF()
if &list && !exists('w:hi_tail')
w:hi_tail = matchadd('SpellBad', '\s\+$')
elseif !&list && exists('w:hi_tail')
matchdelete(w:hi_tail)
unlet w:hi_tail
endif
enddef
au vimrc OptionSet list silent! CF()
au vimrc BufNew,BufReadPost * silent! CF()
sil! syntax enable
set t_Co=256
set bg=dark
sil! colorscheme girly
if '~/.vimrc_local'->expand()->filereadable()
so ~/.vimrc_local
endif
def CG()
var a = get(v:oldfiles, 0, '')->expand()
if a->filereadable()
exe 'edit' a
endif
enddef
au vimrc VimEnter * ++nested if !C()|CG()|endif
