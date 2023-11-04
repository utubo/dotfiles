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
const lm = executable('deno')
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
return strdisplaywidth(a) <= b ? a : $'{a->matchstr($'.*\%<{b + 1}v')}>'
enddef
def! g:VFirstLast(): list<number>
return [line('.'), line('v')]->sort('n')
enddef
def! g:VRange(): list<number>
const a = g:VFirstLast()
return range(a[0], a[1])
enddef
const ln = expand( $'{lk}/pack/jetpack/opt/vim-jetpack/plugin/jetpack.vim')
const lo = filereadable(ln)
if ! lo
const lp = 'https://raw.githubusercontent.com/tani/vim-jetpack/master/plugin/jetpack.vim'
system($'curl -fsSLo {ln} --create-dirs {lp}')
endif
packadd vim-jetpack
jetpack#begin()
Jetpack 'tani/vim-jetpack', { 'opt': 1 }
Jetpack 'airblade/vim-gitgutter'
Jetpack 'cohama/lexima.vim'
Jetpack 'delphinus/vim-auto-cursorline'
Jetpack 'easymotion/vim-easymotion'
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
Jetpack 'othree/html5.vim'
Jetpack 'othree/yajs.vim'
Jetpack 'prabirshrestha/asyncomplete-buffer.vim'
Jetpack 'prabirshrestha/asyncomplete.vim'
Jetpack 'skanehira/gh.vim'
Jetpack 'thinca/vim-portal'
Jetpack 'thinca/vim-themis'
Jetpack 'tpope/vim-fugitive'
Jetpack 'tyru/capture.vim'
Jetpack 'tyru/caw.vim'
Jetpack 'yami-beta/asyncomplete-omni.vim'
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
Jetpack 'utubo/vim-colorscheme-girly'
Jetpack 'utubo/vim-colorscheme-softgreen'
Jetpack 'utubo/vim-hlpairs'
Jetpack 'utubo/vim-minviml'
Jetpack 'utubo/vim-cmdheight0'
Jetpack 'utubo/vim-registers-lite'
Jetpack 'utubo/vim-reformatdate'
Jetpack 'utubo/vim-tabtoslash'
Jetpack 'utubo/vim-yomigana'
Jetpack 'utubo/jumpcursor.vim'
Jetpack 'utubo/vim-ddgv'
Jetpack 'utubo/vim-portal-aim'
Jetpack 'utubo/vim-shrink'
Jetpack 'utubo/vim-tablist'
Jetpack 'utubo/vim-tabpopupmenu'
Jetpack 'utubo/vim-textobj-twochars'
if lm
Jetpack 'vim-denops/denops.vim'
Jetpack 'vim-skk/skkeleton'
endif
jetpack#end()
if ! lo
jetpack#sync()
endif
au vimrc WinNew,FileType * b:stl_icon = nerdfont#find()
b:stl_bufinfo = ''
def F()
var a = []
if &fenc !=# 'utf-8' && !!&fenc
a += [&fenc->toupper()]
endif
if &ff !=# '' && (has('win32') && (&ff !=# 'dos') || !has('win32') && (&ff !=# 'unix'))
a += [&ff ==# 'dos' ? 'CRLF' : &ff ==# 'unix' ? 'LF' : 'CR']
endif
if !a
b:stl_bufinfo = ''
else
b:stl_bufinfo = '%#Cmdheight0Warn#' .. a->join(',') .. '%#CmdHeight0#'
endif
enddef
au vimrc BufNew,BufRead,OptionSet * F()
w:ruler_mdcb = ''
au vimrc VimEnter,WinNew * w:ruler_mdcb = ''
au vimrc Colorscheme * {
hi! link ChkCountIcon CmdHeight0Warn
hi! link ChkCountIconOk CmdHeight0Info
}
g:stl_reg = ''
def G()
var a = v:event.regcontents
->join('↵')
->substitute('\t', '›', 'g')
->E(20)
->substitute('%', '%%', 'g')
g:stl_reg = $'%#Cmdheight0Info#📋%#CmdHeight0#{a}'
enddef
au vimrc TextYankPost * G()
g:stl_worktime = '%#Cmdheight0Info#🕛'
g:stl_worktime_open_at = get(g:, 'ruler_worktime_open_at', localtime())
def! g:VimrcTimer60s(a: any)
const b = (localtime() - g:stl_worktime_open_at) / 60
const c = b % 60
g:stl_worktime = '🕛🕐🕑🕒🕓🕔🕕🕖🕗🍰🍰🍰'[c / 5]
if c ==# 45
notification#show("       ☕🍴🍰\nHave a break time !")
endif
if g:stl_worktime ==# '🍰'
g:stl_worktime = '%#Cmdheight0Warn#' .. g:stl_worktime
else
g:stl_worktime = '%#Cmdheight0Info#' .. g:stl_worktime
endif
enddef
timer_stop(get(g:, 'vimrc_timer_60s', 0))
g:vimrc_timer_60s = timer_start(60000, 'VimrcTimer60s', { repeat: -1 })
g:cmdheight0 = {}
g:cmdheight0.delay = -1
g:cmdheight0.tail = "\ue0c6"
g:cmdheight0.sub = ' '
g:cmdheight0.horiznr = '─'
g:cmdheight0.statusline = ' ' ..
'%{b:stl_icon}%t ' ..
'%#CmdHeight0Error#%m%*' ..
'%|%=%|' ..
'%{%w:ruler_mdcb|%}' ..
'%{%g:stl_reg|%}' ..
'%3l:%-2c:%L%|' ..
'%{%b:stl_bufinfo|%}%*' ..
'%{%g:stl_worktime%}%*' ..
' '
g:cmdheight0.laststatus = 0
nn ZZ <ScriptCmd>cmdheight0#ToggleZen()<CR>
au vimrc WinEnter * {
if winnr('$') ==# 1 && tabpagenr('$') ==# 1 && &buftype ==# 'terminal'
cmdheight0#ToggleZen(0)
endif
}
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
nn <F1> <Cmd>Fern . -reveal=% -opener=split<CR>
def H(a: string)
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
com! -nargs=* GitAdd H(<q-args>)
def! g:ConventionalCommits(a: any, l: string, p: number): list<string>
return ['✨feat:', '🐞fix:', '📝docs:', '🔨refactor:', '🎨style:', '⏪revert:', '✅test:', '🔧chore', '🎉release:']
enddef
com! -nargs=1 -complete=customlist,g:ConventionalCommits GitCommit Git commit -m <q-args>
def I(a: string)
ec system($"git tag '{a}'")
ec system($"git push origin '{a}'")
enddef
com! -nargs=1 GitTagPush I(<q-args>)
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
Enable g:lexima_accept_pum_with_enter
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
const lq = has('win32') ? '.cmd' : ''
var lspServers = [{
name: 'typescriptlang',
filetype: ['javascript', 'typescript'],
path: $'typescript-language-server{lq}',
args: ['--stdio'],
}, {
name: 'vimlang',
filetype: ['vim'],
path: $'vim-language-server{lq}',
args: ['--stdio'],
}, {
name: 'htmllang',
filetype: ['html'],
path: $'html-languageserver{lq}',
args: ['--stdio'],
}, {
name: 'jsonlang',
filetype: ['json'],
path: $'vscode-json-languageserver{lq}',
args: ['--stdio'],
}]
au vimrc VimEnter * call LspOptionsSet(lspOptions)
au vimrc VimEnter * call LspAddServer(lspServers)
nn <F2> <Cmd>MRUToggle<CR>
g:MRU_Exclude_Files = has('win32') ? $'{$TEMP}\\.*' : '^/tmp/.*\|^/var/tmp/.*'
nn <Leader>a <Cmd>PortalAim<CR>
nn <Leader>b <Cmd>PortalAim blue<CR>
nn <Leader>o <Cmd>PortalAim orange<CR>
nn <Leader>r <Cmd>PortalReset<CR>
g:sandwich#recipes = deepcopy(g:sandwich#default_recipes)
g:sandwich#recipes += [
{ buns: ["\r", '' ], input: ["\r"], command: ["normal! a\r"] },
{ buns: ['', '' ], input: ['q'] },
{ buns: ['「', '」'], input: ['k'] },
{ buns: ['【', '】'], input: ['K'] },
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
CmdEach nmap,xmap Sd <Plug>(operator-sandwich-delete)<if-nmap>ab
CmdEach nmap,xmap Sr <Plug>(operator-sandwich-replace)<if-nmap>ab
CmdEach nnoremap,xnoremap S <Plug>(operator-sandwich-add)<if-nnoremap>iw
nm <expr> Srr (matchstr(getline('.'), '[''"]', col('.')) ==# '"') ? "Sr'" : 'Sr"'
nm S$ vg_S
au vimrc User OperatorSandwichAddPre g:fix_sandwich_pos = getpos('.')
au vimrc User OperatorSandwichAddPost myutil#FixSandwichPos()
au vimrc User OperatorSandwichDeletePost myutil#RemoveAirBuns()
xn Sm <ScriptCmd>myutil#BigMac()<CR>
nm Sm viwSm
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
CmdEach inoremap,snoremap <expr> JJ vsnip#expandable() ? '<Plug>(vsnip-expand)' : 'JJ'
CmdEach inoremap,snoremap <expr> <C-l> vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
def J(a: string, b: list<string>, c: list<string>)
exe printf("asyncomplete#register_source(asyncomplete#sources#%s#get_source_options({ name: '%s', whitelist: %s, blacklist: %s, completor: asyncomplete#sources#%s#completor }))", a, a, b, c, a)
enddef
J('omni', ['*'], ['c', 'cpp', 'html'])
J('buffer', ['*'], ['go'])
Enable g:rainbow_active
Enable g:ctrlp_use_caching
Disable g:ctrlp_clear_cache_on_exit
g:ctrlp_match_func = {'match': 'ctrlp_matchfuzzy#matcher'}
g:ctrlp_cmd = 'CtrlPMixed'
g:auto_cursorline_wait_ms = &ut
g:loaded_matchparen = 1
au vimrc VimEnter * nnoremap % <ScriptCmd>call hlpairs#Jump()<CR>
nn <Leader>% <ScriptCmd>call hlpairs#HighlightOuter()<CR>
Each w,b,e,ge nnoremap {} <Plug>(smartword-{})
nn [c <Plug>(GitGutterPrevHunk)
nn ]c <Plug>(GitGutterNextHunk)
nn <Space>t <ScriptCmd>tabpopupmenu#popup()<CR>
nn <Space>T <ScriptCmd>tablist#Show()<CR>
CmdEach nnoremap,xnoremap <Space>c <Plug>(caw:hatpos:toggle)
CmdEach nnoremap,tnoremap <silent> <C-w><C-s> <Plug>(shrink-height)<C-w>w
CmdEach nnoremap,tnoremap <silent> <C-w><C-h> <Plug>(shrink-width)<C-w>w
no <Space>s <Plug>(jumpcursor-jump)
const lr = expand($'{lk}/pack/local/opt/*')
if lr !=# ''
&runtimepath = $'{substitute(lr, '\n', ',', 'g')},{&runtimepath}'
endif
g:vimhelpgenerator_version = ''
g:vimhelpgenerator_author = 'Author  : utubo'
g:vimhelpgenerator_defaultlanguage = 'en'
g:vimhelpgenerator_uri = 'https://github.com/utubo/'
filetype plugin indent on
au vimrc InsertLeave * set nopaste
au vimrc BufReadPost *.log* normal! G
xn * "vy/\V<C-r>=substitute(escape(@v,'\/'),"\n",'\\n','g')<CR><CR>
ino jk <Esc>`^
ino <CR> <CR><C-g>u
set mps+=（:）,「:」,『:』,【:】,［:］,＜:＞
Each i,a,A nnoremap <expr> {} !empty(getline('.')) ? '{}' : '"_cc'
Each +,-,>,< CmdEach nmap,tmap <C-w>{} <C-w>{}<SID>ws
Each +,-,>,< CmdEach nnoremap,tnoremap <script> <SID>ws{} <C-w>{}<SID>ws
CmdEach nmap,tmap <SID>ws <Nop>
def BA()
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
au vimrc BufReadPost * BA()
com! -nargs=+ -complete=dir VimGrep myutil#VimGrep(<f-args>)
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
def! g:MyFoldText(): string
const a = getline(v:foldstart)
const b = repeat(' ', indent(v:foldstart))
const c = &fdm ==# 'indent' ? '' : a->substitute(matchstr(&foldmarker, '^[^,]*'), '', '')->trim()
return $'{b}{c} 📁'
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
xn zf <ScriptCmd>myutil#Zf()<CR>
nn zd <ScriptCmd>myutil#Zd()<CR>
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
xn u <ScriptCmd>undo\|normal! gv<CR>
xn <C-R> <ScriptCmd>redo\|normal! gv<CR>
xn <Tab> <ScriptCmd>D('normal! >gv')<CR>
xn <S-Tab> <ScriptCmd>D('normal! <gv')<CR>
CmdEach nnoremap,xnoremap / <Cmd>noh<CR>/
CmdEach nnoremap,xnoremap ? <Cmd>noh<CR>?
CmdEach nmap,xmap ; :
nn <Space>; ;
nn <Space>: :
cno <C-h> <Left>
cno <C-l> <Right>
cno <C-n> <Down>
cno <C-p> <Up>
cno <expr> <C-r><C-r> trim(@")->substitute('\n', ' \| ', 'g')
cno <expr> <C-r><C-e> escape(@", '~^$.*?/\[]')->substitute('\n', '\\n', 'g')
cnoreabbrev cs colorscheme
cno <expr> jj (empty(getcmdline()) && getcmdtype() ==# ':' ? 'update<CR>' : '<CR>')
ino ;jj <Esc>`^<Cmd>update<CR>
def BC(c: string): string
if getcmdtype() !=# ':'
return c
endif
const a = getcmdline()
if getcmdpos() !=# a->len() + 1 || a =~# '\s'
return c
endif
const e = a[-1]
if e ==# 's'
return $"{c}{c}{c}g\<Left>\<Left>\<Left>"
endif
if e ==# 'g' && c ==# '!'
return "!//\<Left>"
endif
if e ==# 'g' || e ==# 'v'
return $"{c}{c}\<Left>"
endif
return c
enddef
Each /,#,! cnoremap <script> <expr> {} BC('{}')
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
def g:Tapi_drop(a: number, b: list<string>)
const c = b[0]
var d = 1
var e = 'split'
if b[1] ==# '-t'
e = 'tabe'
d += 1
endif
var f = b[d]
if !isabsolutepath(f)
f = fnamemodify(c, ':p') .. f
endif
if bufwinnr(bufnr(f)) !=# -1
e = 'drop'
endif
exe e fnameescape(f)
enddef
def BD(a: string = '')
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
def BE()
popup_create($' {line(".")}:{col(".")} ', {
pos: 'botleft',
line: 'cursor-1',
col: 'cursor+1',
moved: 'any',
padding: [1, 1, 1, 1],
})
enddef
nn <script> <C-g> <ScriptCmd>BD()<CR><scriptCmd>BE()<CR>
au vimrc BufNewFile,BufReadPost,BufWritePost * BD('BufNewFile')
def BF(a: string)
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
Each h,j,k,l nnoremap q{} <ScriptCmd>BF('{}')<CR>
nn q <Nop>
nn Q q
nn qq <Cmd>confirm q<CR>
nn qa <Cmd>confirm qa<CR>
nn qn <Cmd>confirm tabclose +<CR>
nn qp <Cmd>confirm tabclose -<CR>
nn q# <Cmd>confirm tabclose #<CR>
nn qo <Cmd>confirm tabonly<CR>
nn q: q:
nn q/ q/
nn q? q?
com! -nargs=1 -complete=file MoveFile myutil#MoveFile(<f-args>)
cnoreabbrev mv MoveFile
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
nn <F11> <ScriptCmd>myutil#ToggleNumber()<CR>
nn <F12> <Cmd>set wrap!<CR>
nn gs :<C-u>%s///g<Left><Left><Left>
nn gS :<C-u>%s/<C-r>=escape(expand('<cword>'), '^$.*?/\[]')<CR>//g<Left><Left>
xn gs :s///g<Left><Left><Left>
xn gS "vy:<C-u>%s/<C-r>=substitute(escape(@v,'^$.*?/\[]'),"\n",'\\n','g')<CR>//g<Left><Left>
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
ino ｋｊ <Esc>`^
ino 「 「」<C-g>U<Left>
ino 「」 「」<C-g>U<Left>
ino （ ()<C-g>U<Left>
ino （） ()<C-g>U<Left>
nn <Space>a A
xn <expr> p $'"_s<C-R>{v:register}<ESC>'
xn P p
nn <Space>h ^
nn <Space>l $
nn <Space>n <Cmd>nohlsearch<CR>
au vimrc CursorHold * feedkeys(' n') # nohはauで動かない(:help noh)
nn <silent> g; g;zO
nn <CR> j0
nn <Tab> <Cmd>call search('\(^\\|\t\\|, *\)\S\?', 'e')<CR>
nn <S-Tab> <Cmd>call search('\(^\\|\t\\|, *\)\S\?', 'be')<CR>
au vimrc FileType html,xml,svg {
nn <buffer> <silent> <Tab> <Cmd>call search('>')<CR><Cmd>call search('\S')<CR>
nn <buffer> <silent> <S-Tab> <Cmd>call search('>', 'b')<CR><Cmd>call search('>', 'b')<CR><Cmd>call search('\S')<CR>
}
nn <silent> <F10> <ESC>1<C-w>s:1<CR><C-w>w
xn <F10> <ESC>1<C-w>s<C-w>w
nn ' "
nn m '
nn M m
nn <F9> my
nn <S-F9> 'y
ino jj <C-o>
ino jje <C-o>e<C-o>a
ino jj; <C-o>$;<CR>
ino jj<Space> <C-o>$<CR>
ino jjk 「」<C-g>U<Left>
ino jj<Tab> <ScriptCmd>D('normal! >>')<CR>
ino jj<S-Tab> <ScriptCmd>D('normal! <<')<CR>
ino <M-x> <ScriptCmd>ToggleCheckBox()<CR>
cno qj <Down>
cno qk <Up>
def BG()
for a in get(w:, 'my_syntax', [])
matchdelete(a)
endfor
w:my_syntax = []
enddef
def BH(a: string, b: string)
w:my_syntax->add(matchadd(a, b))
enddef
au vimrc Syntax * BG()
au vimrc Syntax javascript,vim BH('SpellRare', '\s[=!]=\s')
au vimrc Syntax vim BH('SpellRare', '\<normal!\@!')
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
const c = matchstr(getline('.'), '.', col('.') - 1)
if !c || stridx(')]}"''`」', c) ==# -1
return 'll'
endif
const a = matchstr(getline('.'), '.', col('.') - 2)
if stridx('ae', a) !=# -1
return 'll'
endif
return "\<C-o>a"
enddef
ino <expr> ll BJ()
com! -nargs=1 Brep myutil#Brep(<q-args>, <q-mods>)
def CA(): string
cno jk <C-c>
cno h <Left>
cno l <Right>
cno b <S-Left>
cno w <S-Right>
cno $ <End><Left>
cno ^ <Home>
cno x <Delete>
cno <script> <expr> i CB('i')
cno <script> <expr> a CB('a')
cm A $a
return ""
enddef
def CB(c: string = 'i'): string
Each h,l,b,w,^,$,x,i,a,A silent! cunmap {}
cno <script> <expr> jk CA()
return c ==# 'i' ? '' : "\<Right>"
enddef
au vimrc ModeChanged *:c CB()
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
nn <Space>y yiw
nm S^ v^S
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
def CC(a: number, b: string): string
const v = synIDattr(a, b)
if has('gui')
return v =~# '^[0-9]*$' ? 'NONE' : v
else
return v !~# '^[0-9]\+$' ? 'NONE' : v
endif
enddef
def CD(a: string): any
const b = hlID(a)->synIDtrans()
return { fg: CC(b, 'fg'), bg: CC(b, 'bg') }
enddef
def CE()
hi! link CmdHeight0Horiz TabLineFill
hi! link CmdHeight0Horiz MoreMsg
const x = has('gui') ? 'gui' : 'cterm'
const a = CD('LineNr').bg
exe $'hi LspDiagSignErrorText   {x}bg={a} {x}fg={CD("ErrorMsg").fg}'
exe $'hi LspDiagSignHintText    {x}bg={a} {x}fg={CD("Question").fg}'
exe $'hi LspDiagSignInfoText    {x}bg={a} {x}fg={CD("Pmenu").fg}'
exe $'hi LspDiagSignWarningText {x}bg={a} {x}fg={CD("WarningMsg").fg}'
enddef
au vimrc VimEnter,ColorScheme * CE()
def CF()
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
au vimrc VimEnter,WinEnter * CF()
def CG()
if &list && !exists('w:hi_tail')
w:hi_tail = matchadd('SpellBad', '\s\+$')
elseif !&list && exists('w:hi_tail')
matchdelete(w:hi_tail)
unlet w:hi_tail
endif
enddef
au vimrc OptionSet list silent! CG()
au vimrc BufNew,BufReadPost * silent! CG()
sil! syntax enable
set t_Co=256
set bg=dark
sil! colorscheme girly
if '~/.vimrc_local'->expand()->filereadable()
so ~/.vimrc_local
endif
def CH()
var a = get(v:oldfiles, 0, '')->expand()
if a->filereadable()
exe 'edit' a
endif
enddef
au vimrc VimEnter * ++nested if !C()|CH()|endif
