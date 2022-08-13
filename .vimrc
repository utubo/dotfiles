vim9script noclear
set enc=utf-8
scripte utf-8
#----------------------------------------------------------
# 基本設定 {{{
set fencs=ucs-bom,utf-8,iso-2022-jp,cp932,euc-jp
set noet
set ts=3 # 意外とありな気がしてきた…
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
noh # TODO: viminfoのhオプションを見直すのが正攻法
aug vimrc
# 新しい自由
au!
aug End
#}}}-------------------------------------------------------
#----------------------------------------------------------
# ユーティリティ {{{
cons rtproot=has('win32') ? '~/vimfiles' : '~/.vim'
cons has_deno=executable('deno')
# こんな感じ
# MultiCmd nmap,vmap xxx yyy<if-nmap>NNN<if-vmap>VVV<>zzz
# ↓
# nmap xxx yyyNNNzzz|vm xxx yyyVVVzzz
def MultiCmd(b: string)
cons [c,d]=b->split('^\S*\zs')
for e in c->split(',')
cons a=d
->substitute($'<if-{cmd}>','<>','g')
->substitute('<if-.\{-1,}\(<>\|$\)','','g')
->substitute('<>','','g')
exe e a
endfo
enddef
com! -nargs=* MultiCmd MultiCmd(<q-args>)
# その他
com! -nargs=1 -complete=var Enable <args> = 1
com! -nargs=1 -complete=var Disable <args> = 0
def RemoveEmptyLine(a: number)
sil! exe ':' a 's/\s\+$//'
sil! exe ':' a 's/^\s*\n//'
enddef
def BufIsSmth(): bool
retu &modified || ! empty(bufname())
enddef
def IndentStr(a: any): string
retu matchstr(getline(a),'^\s*')
enddef
# 指定幅以上なら'>'で省略する
def TruncToDisplayWidth(a: string,b: number): string
retu strdisplaywidth(a) <=b ? a : $'{str->matchstr(printf('.*\%%<%dv', width + 1))}>'
enddef
#}}}-------------------------------------------------------
#----------------------------------------------------------
# プラグイン {{{
# jetpack {{{
cons jetpackfile=expand( $'{rtproot}/pack/jetpack/opt/vim-jetpack/plugin/jetpack.vim')
cons has_jetpack=filereadable(jetpackfile)
if ! has_jetpack
cons jetpackurl='https://raw.githubusercontent.com/tani/vim-jetpack/master/plugin/jetpack.vim'
system(printf('curl -fsSLo %s --create-dirs %s',jetpackfile,jetpackurl))
endif
packadd vim-jetpack
jetpack#begin()
Jetpack 'tani/vim-jetpack',{ 'opt': 1 }
Jetpack 'airblade/vim-gitgutter'
Jetpack 'alvan/vim-closetag'
Jetpack 'ctrlpvim/ctrlp.vim'
Jetpack 'cohama/lexima.vim' # 括弧補完
Jetpack 'delphinus/vim-auto-cursorline'
Jetpack 'dense-analysis/ale'
Jetpack 'easymotion/vim-easymotion'
Jetpack 'hrsh7th/vim-vsnip'
Jetpack 'hrsh7th/vim-vsnip-integ'
Jetpack 'itchyny/lightline.vim'
Jetpack 'kana/vim-textobj-user'
Jetpack 'LeafCage/vimhelpgenerator'
Jetpack 'luochen1990/rainbow' # 虹色括弧
Jetpack 'machakann/vim-sandwich'
Jetpack 'mattn/ctrlp-matchfuzzy'
Jetpack 'mattn/vim-notification'
Jetpack 'matze/vim-move' # 行移動
Jetpack 'mechatroner/rainbow_csv'
Jetpack 'michaeljsmith/vim-indent-object'
Jetpack 'osyo-manga/vim-textobj-multiblock'
Jetpack 'othree/html5.vim'
Jetpack 'othree/yajs.vim'
Jetpack 'prabirshrestha/asyncomplete-buffer.vim'
Jetpack 'prabirshrestha/asyncomplete.vim'
Jetpack 'rafamadriz/friendly-snippets'
Jetpack 'thinca/vim-portal'
Jetpack 'tpope/vim-fugitive' # Gdiffとか
Jetpack 'tyru/caw.vim' # コメント化
Jetpack 'yami-beta/asyncomplete-omni.vim'
Jetpack 'yegappan/mru'
Jetpack 'vim-jp/vital.vim'
Jetpack 'utubo/jumpcuorsor.vim' # vimに対応させたやつ(様子見)vim-jetpackだとインストール出来ないかも？
Jetpack 'utubo/vim-auto-hide-cmdline'
Jetpack 'utubo/vim-colorscheme-girly'
Jetpack 'utubo/vim-minviml'
Jetpack 'utubo/vim-portal-aim'
Jetpack 'utubo/vim-registers-lite'
Jetpack 'utubo/vim-reformatdate'
Jetpack 'utubo/vim-tabtoslash'
# あまり使ってないけど作ったので…
Jetpack 'utubo/vim-shrink'
Jetpack 'utubo/vim-tablist'
Jetpack 'utubo/vim-tabpopupmenu'
Jetpack 'utubo/vim-textobj-twochars'
if has_deno
Jetpack 'vim-denops/denops.vim'
Jetpack 'vim-skk/skkeleton'
endif
jetpack#end()
if ! has_jetpack
jetpack#sync()
endif
#}}}
# easymotion {{{
Enable g:EasyMotion_smartcase
Enable g:EasyMotion_use_migemo
Enable g:EasyMotion_enter_jump_first
Disable g:EasyMotion_do_mapping
g:EasyMotion_keys='asdghklqwertyuiopzxcvbnmfjASDGHKLQWERTYUIOPZXCVBNMFJ;'
map s <Plug>(ahc)<Plug>(easymotion-s)
#}}}
# sandwich {{{
g:sandwich#recipes=deepcopy(g:sandwich#default_recipes)
g:sandwich#recipes+=[
{ buns: ["\r",'' ],input: ["\r"],command: ["normal! a\r"] },
{ buns: ['','' ],input: ['q'] },
{ buns: ['「','」'],input: ['k'] },
{ buns: ['{ ',' }'],input: ['{'] },
{ buns: ['${','}' ],input: ['${'] },
{ buns: ['%{','}' ],input: ['%{'] },
{ buns: ['CommentString(0)','CommentString(1)'],expr: 1,input: ['c'] },
]
def g:CommentString(a: number): string
retu &commentstring->split('%s')->get(a,'')
enddef
Enable g:sandwich_no_default_key_mappings
Enable g:operator_sandwich_no_default_key_mappings
MultiCmd nnoremap,vnoremap Sd <Plug>(operator-sandwich-delete)<if-nmap>ab
MultiCmd nnoremap,vnoremap Sr <Plug>(operator-sandwich-replace)<if-nmap>ab
MultiCmd nnoremap,vnoremap Sa <Plug>(operator-sandwich-add)<if-nmap>iw
MultiCmd nnoremap,vnoremap S <Plug>(operator-sandwich-add)<if-nmap>iw
nm S^ v^S
nm S$ vg_S
nm <expr> SS (matchstr(getline('.'), '[''"]', col('.')) ==# '"') ? 'Sr''' : 'Sr"'
# 改行で挟んだあとタブでインデントされると具合が悪くなるので…
def FixSandwichPos()
var c=g:operator#sandwich#object.cursor
if g:fix_sandwich_pos[1] !=# c.inner_head[1]
c.inner_head[2]=getline(c.inner_head[1])->match('\S')+1
c.inner_tail[2]=getline(c.inner_tail[1])->match('$')+1
endif
enddef
au vimrc User OperatorSandwichAddPre g:fix_sandwich_pos = getpos('.')
au vimrc User OperatorSandwichAddPost FixSandwichPos()
# 内側に連続で挟むやつ
var big_mac_crown=[]
def BigMac(a: bool=true)
cons c=g:operator#sandwich#object.cursor.inner_head[1 : 2]
if a || big_mac_crown !=# c
big_mac_crown=c
au vimrc User OperatorSandwichAddPost ++once BigMac(false)
if a
feedkeys('Sa')
else
setpos("'<",g:operator#sandwich#object.cursor.inner_head)
setpos("'>",g:operator#sandwich#object.cursor.inner_tail)
feedkeys('gvSa')
endif
endif
enddef
nm Sm viwSm
vm Sm <Cmd>call <SID>BigMac()<CR>
# 囲みを削除したら行末空白と空行も削除
def RemoveAirBuns()
cons c=g:operator#sandwich#object.cursor
RemoveEmptyLine(c.tail[1])
RemoveEmptyLine(c.head[1])
enddef
au vimrc User OperatorSandwichDeletePost RemoveAirBuns()
#}}}
# MRU {{{
# デフォルト設定(括弧内にフルパス)だとパスに括弧が含まれているファイルが開けないので、パスに使用されない">"を区切りにする
g:MRU_Filename_Format={
formatter: 'fnamemodify(v:val, ":t") . " > " . v:val',
parser: '> \zs.*',
syntax: '^.\{-}\ze >'
}
# 数字キーで開く
def MRUwithNumKey(a: bool)
b:use_tab=a
setl number
redraw
if &cmdheight !=# 0
echoh Question
ec printf('[1]..[9] => open with a %s.',a ? 'tab' : 'window')
echoh None
endif
cons c=a ? 't' : '<CR>'
for i in range(1,9)
exe printf('nmap <buffer> <silent> %d :<C-u>%d<CR>%s',i,i,c)
endfo
enddef
def MyMRU()
Enable b:auto_cursorline_disabled
setl cursorline
nn <buffer> w <Cmd>call <SID>MRUwithNumKey(!b:use_tab)<CR>
nn <buffer> R <Cmd>MruRefresh<CR><Cmd>normal! u
nn <buffer> <Esc> <Cmd>q!<CR>
MRUwithNumKey(BufIsSmth())
enddef
au vimrc FileType mru MyMRU()
au vimrc ColorScheme * hi link MruFileName Directory
nn <F2> <Cmd>MRUToggle<CR>
g:MRU_Exclude_Files=has('win32') ? $'{$TEMP}\\.*' : '^/tmp/.*\|^/var/tmp/.*'
#}}}
# 補完 {{{
def RegisterAsyncompSource(a: string,b: list<string>,c: list<string>)
exe printf("asyncomplete#register_source(asyncomplete#sources#%s#get_source_options({ name: '%s', whitelist: %s, blacklist: %s, completor: asyncomplete#sources#%s#completor }))",a,a,b,c,a)
enddef
RegisterAsyncompSource('omni',['*'],['c','cpp','html'])
RegisterAsyncompSource('buffer',['*'],['go'])
MultiCmd imap,smap <expr> JJ vsnip#expandable() ? '<Plug>(vsnip-expand)' : 'JJ'
MultiCmd imap,smap <expr> <C-l> vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
MultiCmd imap,smap <expr> <Tab> vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : pumvisible() ? '<C-n>' : '<Tab>'
MultiCmd imap,smap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : pumvisible() ? '<C-p>' : '<S-Tab>'
#imap <expr> <CR> pumvisible() ? '<C-y>' : '<CR>'
Enable g:lexima_accept_pum_with_enter
#}}}
# ALE {{{
Enable g:ale_set_quickfix
Enable g:ale_fix_on_save
Disable g:ale_lint_on_insert_leave
Disable g:ale_set_loclist
g:ale_sign_error='🐞'
g:ale_sign_warning='🐝'
g:ale_fixers={ typescript: ['deno'] }
g:ale_lint_delay=&ut
nn <silent> [a <Plug>(ale_previous_wrap)
nn <silent> ]a <Plug>(ale_next_wrap)
# cmdheight=0だとALEのホバーメッセージがちらつくのでg:ll_aleに代入してlightlineで表示する
Disable g:ale_echo_cursor
g:ll_are=''
def ALEEchoCursorCmdHeight0()
var a=ale#util#FindItemAtCursor(bufnr())[1]
if !empty(a)
g:ll_ale=a.type==# 'E' ? '🐞' : '🐝'
g:ll_ale..=' '
g:ll_ale..=get(a,'detail',a.text)->split('\n')[0]
->substitute('^\[[^]]*\] ','','')
else
g:ll_ale=''
endif
enddef
au vimrc CursorMoved * ALEEchoCursorCmdHeight0()
#}}}
# lightline {{{
# ヤンクしたやつを表示するやつ
g:ll_reg=''
def LLYankPost()
var a=v:event.regcontents
->join('\n')
->substitute('\t','›','g')
->TruncToDisplayWidth(20)
g:ll_reg=$'📋:{reg}'
enddef
au vimrc TextYankPost * LLYankPost()
# 毎時vim起動後45分から15分間休憩しようね
g:ll_tea_break='0:00'
g:ll_tea_break_opentime=get(g:,'ll_tea_break_opentime',localtime())
def g:VimrcTimer60s(a: any)
cons b=(localtime()-g:ll_tea_break_opentime)/60
cons c=b % 60
cons d=c >=45 ? '☕🍴🍰' : ''
g:ll_tea_break=printf('%s%d:%02d',d,b/60,c)
lightline#update()
if (c==# 45)
notification#show("       ☕🍴🍰\nHave a break time !")
endif
enddef
timer_stop(get(g:,'vimrc_timer_60s',0))
g:vimrc_timer_60s=timer_start(60000,'VimrcTimer60s',{ repeat:-1 })
# &ff
if has('win32')
def g:LLFF(): string
retu &ff !=# 'dos' ? &ff : ''
enddef
else
def g:LLFF(): string
retu &ff==# 'dos' ? &ff : ''
enddef
endif
# &fenc
def g:LLNotUtf8(): string
retu &fenc==# 'utf-8' ? '' : &fenc
enddef
# lightline設定
g:lightline={
colorscheme: 'wombat',
active: {
left: [['mode','paste'],['fugitive','filename'],['ale']],
right: [['teabreak'],['ff','notutf8','li'],['reg']]
},
component: { teabreak: '%{g:ll_tea_break}',reg: '%{g:ll_reg}',ale: '%=%{g:ll_ale}',li: '%2c,%l/%L' },
component_function: { ff: 'LLFF',notutf8: 'LLNotUtf8' },
}
# tablineはデフォルト
au vimrc VimEnter * set tabline=
#}}}
# skk {{{
if has_deno
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
#}}}
# textobj-multiblock {{{
MultiCmd omap,xmap ab <Plug>(textobj-multiblock-a)
MultiCmd omap,xmap ib <Plug>(textobj-multiblock-i)
g:textobj_multiblock_blocks=[ [ "(",")" ],[ "[","]" ],[ "{","}" ],[ '<','>' ],[ '"','"',1 ],[ "'","'",1 ],[ ">","<",1 ],[ "「","」",1 ],
]
#}}}
# Portal {{{
nn <Leader>a <Cmd>PortalAim<CR>
nn <Leader>b <Cmd>PortalAim blue<CR>
nn <Leader>o <Cmd>PortalAim orange<CR>
nn <Leader>r <Cmd>PortalReset<CR>
#}}}
# ヘルプ作成 {{{
g:vimhelpgenerator_version=''
g:vimhelpgenerator_author='Author  : utubo'
g:vimhelpgenerator_defaultlanguage='en'
#}}}
# cmdline statusline 切り替え {{{
Enable g:auto_hide_cmdline_switch_statusline
# statusline非表示→cmdline表示の順にしないとちらつくので応急処置…
# 本筋はCmdlineEnterPreを作るかupdate_screen(VALID)をCmdlineEnter発行の後にするしかない？
# ソース
# https://github.com/vim/vim/blob/master/src/ex_getln.c
# static char_u*getcmdline_int()
# 前者
# `trigger_cmd_autocmd(firstc==-1 || firstc==NUL ? '-' : firstc,EVENT_CMDLINEENTERPRE)`
# を`if (cmdheight0)`の手前で実行する？
# `firstc==-1`のくだりは後の行から移動してきてもいいかもしれない
# ドキュメント修正も必要
# でもautocmdの中で`cmdheight`を変更されたらどうするの？
# 後者
# 理由があって今のタイミングでupdate_screenしているのだから移動できるわけがない…
MultiCmd nnoremap,vnoremap : <Plug>(ahc-switch):
MultiCmd nnoremap,vnoremap/<Plug>(ahc-switch)<Cmd>noh<CR>/
MultiCmd nnoremap,vnoremap ? <Plug>(ahc-switch)<Cmd>noh<CR>?
MultiCmd nmap,vmap ; :
nn <Space>; ;
nn <Space>: :
# 自作プラグイン(vim-registerslite)と被ってしまった…
# inoremap <C-r>=<C-o><Plug>(ahc-switch)<C-r>=
#}}}
# その他 {{{
Enable g:rainbow_active
g:auto_cursorline_wait_ms=&ut
g:ctrlp_match_func={'match': 'ctrlp_matchfuzzy#matcher'}
g:ctrlp_cmd='CtrlPMixed'
nn [c <Plug>(ahc)<Plug>(GitGutterPrevHunk)
nn ]c <Plug>(ahc)<Plug>(GitGutterNextHunk)
nm <Space>ga :<C-u>Git add %
nm <Space>gc :<C-u>Git commit -m ''<Left>
nm <Space>gp :<C-u>Git push
nn <Space>gv <Cmd>Gvdiffsplit<CR>
nn <Space>gd <Cmd>Gdiffsplit<CR>
nn <Space>gl <Cmd>Git pull<CR>
nn <Space>t <Cmd>call tabpopupmenu#popup()<CR>
nn <Space>T <Cmd>call tablist#Show()<CR>
MultiCmd nnoremap,vnoremap <Space>c <Plug>(caw:hatpos:toggle)
MultiCmd nnoremap,tnoremap <silent> <C-w><C-s> <Plug>(shrink-height)<C-w>w
MultiCmd nnoremap,tnoremap <silent> <C-w><C-h> <Plug>(shrink-width)<C-w>w
# EasyMotionとどっちを使うか様子見中
no <Space>s <Plug>(jumpcursor-jump)
#}}}
# 開発用 {{{
cons localplugins=expand($'{rtproot}/pack/local/opt/*')
if localplugins !=# ''
&runtimepath=$'{substitute(localplugins, '\n', ',', 'g')},{&runtimepath}'
endif
#}}}
filetype plugin indent on
#}}}-------------------------------------------------------
#----------------------------------------------------------
# コピペ寄せ集め色々 {{{
au vimrc InsertLeave * set nopaste
au vimrc BufReadPost *.log* normal! G
vn * "vy/\V<Cmd>substitute(escape(@v,'\/'),"\n",'\\n','g')<CR><CR>
ino kj <Esc>`^
ino kk <Esc>`^
ino <CR> <CR><C-g>u
# https://github.com/astrorobot110/myvimrc/blob/master/vimrc
set mps+=（:）,「:」,『:』,【:】,［:］,＜:＞
# https://github.com/Omochice/dotfiles
nn <expr> i !empty(getline('.')) ? 'i' : '"_cc'
nn <expr> a !empty(getline('.')) ? 'a' : '"_cc'
nn <expr> A !empty(getline('.')) ? 'A' : '"_cc'
#}}}-------------------------------------------------------
#----------------------------------------------------------
# タブ幅やタブ展開を自動設定 {{{
def SetupTabstop()
cons a=100
cons b=getpos('.')
cursor(1,1)
if !!search('^\t','nc',a)
setl noet
setl ts=3 # 意外とありな気がしてきた…
elseif !!search('^  \S','nc',a)
setl et
setl ts=2
elseif !!search('^    \S','nc',a)
setl et
setl ts=4
endif
setpos('.',b)
enddef
au vimrc BufReadPost * SetupTabstop()
#}}}-------------------------------------------------------
#----------------------------------------------------------
# vimgrep {{{
def VimGrep(a: string,...b: list<string>)
var c=join(b,' ')
# パスを省略した場合は、同じ拡張子のファイルから探す
if empty(c)
c=expand('%:e')==# '' ? '*' : ($'*.{expand('%:e')}')
endif
# 適宜タブで開く(ただし明示的に「%」を指定したらカレントで開く)
cons d=BufIsSmth() && c !=# '%'
if d
tabnew
endif
# lvimgrepしてなんやかんやして終わり
exe printf('silent! lvimgrep %s %s',a,c)
if ! empty(getloclist(0))
lwindow
else
echoh ErrorMsg
echom $'Not found.: {keyword}'
echoh None
if d
tabn-
tabc+
endif
endif
enddef
com! -nargs=+ VimGrep VimGrep(<f-args>)
nm <Space>/ :<C-u>VimGrep<Space>
def SetupQF()
nn <buffer> <silent> ; <CR>:silent! normal! zv<CR><C-W>w
nn <buffer> <silent> w <C-W><CR>:silent! normal! zv<CR><C-W>w
nn <buffer> <silent> t <C-W><CR>:silent! normal! zv<CR><C-W>T
nn <buffer> <nowait> q <Cmd>lexpr ''<CR>:q<CR>
nn <buffer> f <C-f>
nn <buffer> b <C-b>
# 様子見中(使わなそうなら削除する)
exe printf('nnoremap <buffer> T <C-W><CR><C-W>T%dgt',tabpagenr())
enddef
au vimrc FileType qf SetupQF()
au vimrc WinEnter * if winnr('$') ==# 1 && &buftype ==# 'quickfix'|q|endif
#}}}-------------------------------------------------------
#----------------------------------------------------------
# diff {{{
set spr
set fcs+=diff:\ # 削除行は空白文字で埋める
# diffモードを自動でoff https://hail2u.net/blog/software/vim-turn-off-diff-mode-automatically.html
au vimrc WinEnter * if (winnr('$') ==# 1) && !!getbufvar(winbufnr(0), '&diff')|diffoff|endif
#}}}-------------------------------------------------------
#----------------------------------------------------------
# 日付関係 {{{
g:reformatdate_extend_names=[{
a: ['日','月','火','水','木','金','土'],
A: ['日曜日','月曜日','火曜日','水曜日','木曜日','金曜日','土曜日'],
}]
ino <expr> <F5> strftime('%Y/%m/%d')
cno <expr> <F5> strftime('%Y%m%d')
nn <F5> <Cmd>call reformatdate#reformat(localtime())<CR>
nn <C-a> <Cmd>call reformatdate#inc(v:count)<CR>
nn <C-x> <Cmd>call reformatdate#dec(v:count)<CR>
nn <Space><F5> /\d\{4\}\/\d\d\/\d\d<CR>
#}}}-------------------------------------------------------
#----------------------------------------------------------
# スマホ用 {{{
#-キーが小さいので押しにくいものはSpaceへマッピング
#-スマホでのコーディングは基本的にバグ取り
nn <Space>zz <Cmd>q!<CR>
# スタックトレースからyankしてソースの該当箇所を探すのを補助
nn <Space>e G?\cErr\\|Exception<CR>
nn <Space>y yiw
nn <expr> <Space>f $'{(getreg('"') =~ '^\d\+$' ? ':' : '/')}{getreg('"')}<CR>'
# スマホだと:と/とファンクションキーが遠いので…
nm <Space>. :
nm <Space>, /
for i in range(1,10)
exe printf('nmap <Space>%d <F%d>',i % 10,i)
endfo
nm <Space><Space>1 <F11>
nm <Space><Space>2 <F12>
#}}}-------------------------------------------------------
#----------------------------------------------------------
# カーソルを行頭に沿わせて移動 {{{
def PutHat(): string
cons x=getline('.')->match('\S')+1
if x !=# 0 || !exists('w:my_hat')
w:my_hat=col('.')==# x ? '^' : ''
endif
retu w:my_hat
enddef
nn <expr> j $'j{<SID>PutHat()}'
nn <expr> k $'k{<SID>PutHat()}'
#}}}-------------------------------------------------------
#----------------------------------------------------------
# 折り畳み {{{
# こんなかんじでインデントに合わせて表示📁 {{{
def g:MyFoldText(): string
cons a=getline(v:foldstart)
cons b=repeat(' ',indent(v:foldstart))
cons c=&fdm==# 'indent' ? '' : a->substitute(matchstr(&foldmarker,'^[^,]*'),'','')->trim()
retu $'{indent}{text} 📁'
enddef
set fdt=g:MyFoldText()
set fcs+=fold:\ # 折り畳み時の「-」は半角空白
au vimrc ColorScheme * hi! link Folded Delimiter
#}}}
# ホールドマーカーの前にスペース、後ろに改行を入れる {{{
def Zf()
cons a=min([line('.'),line('v')])
cons b=max([line('.'),line('v')])
exe ':' a 's/\v(\S)?$/\1 /'
append(b,IndentStr(a))
cursor([a,1])
cursor([b+1,1])
normal! zf
enddef
vn zf <Cmd>call <SID>Zf()<CR>
#}}}
# ホールドマーカーを削除したら行末をトリムする {{{
def Zd()
if foldclosed(line('.'))==#-1
normal! zc
endif
cons a=foldclosed(line('.'))
cons b=foldclosedend(line('.'))
if a==#-1
retu
endif
cons c=getpos('.')
normal! zd
RemoveEmptyLine(b)
RemoveEmptyLine(a)
setpos('.',c)
enddef
nn zd <Cmd>call <SID>Zd()<CR>
#}}}
# その他折りたたみ関係 {{{
set fdm=marker
au vimrc FileType markdown,yaml setlocal foldlevelstart=99|setl fdm=indent
au vimrc BufReadPost * :silent! normal! zO
nn <expr> h (col('.') ==# 1 && 0 < foldlevel('.') ? 'zc' : 'h')
nn Z<Tab> <Cmd>set foldmethod=indent<CR>
nn Z{ <Cmd>set foldmethod=marker<CR>
nn Zy <Cmd>set foldmethod=syntax<CR>
#}}}
#}}}-------------------------------------------------------
#----------------------------------------------------------
# ビジュアルモードあれこれ {{{
def KeepingCurPos(a: string)
cons b=getcurpos()
exe a
setpos('.',b)
enddef
vn u <Cmd>call <SID>KeepingCurPos('undo')<CR>
vn <C-R> <Cmd>call <SID>KeepingCurPos('redo')<CR>
vn <Tab> <Cmd>normal! >gv<CR>
vn <S-Tab> <Cmd>normal! <gv<CR>
#}}}
#----------------------------------------------------------
# コマンドモードあれこれ {{{
cno <C-h> <Space><BS><Left>
cno <C-l> <Space><BS><Right>
cno <expr> <C-r><C-r> trim(@")
cno <expr> <C-r><C-e> escape(@", '~^$.*?/\[]')
cnoreabbrev cs colorscheme
# 「jj」で<CR>、「kk」はキャンセル
# ただし保存は片手で「;jj」でもOK(「;wjj」じゃなくていい)
cno kk <C-c>
cno <expr> jj (empty(getcmdline()) && getcmdtype() ==# ':' ? 'update<CR>' : '<CR>')
ino ;jj <Esc>`^<Cmd>update<CR>
#}}}-------------------------------------------------------
#----------------------------------------------------------
# terminalとか {{{
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
#}}}-------------------------------------------------------
#----------------------------------------------------------
# markdownのチェックボックス {{{
def ToggleCheckBox()
cons a=getline('.')
var b=substitute(a,'^\(\s*\)- \[ \]','\1- [x]','') # check on
if a==# b
b=substitute(a,'^\(\s*\)- \[x\]','\1- [ ]','') # check off
endif
if a==# b
b=substitute(a,'^\(\s*\)\(- \)*','\1- [ ] ','') # a new check box
endif
setline('.',b)
var c=getpos('.')
c[2]+=len(b)-len(a)
setpos('.',c)
enddef
no <Space>x <Cmd>call <SID>ToggleCheckBox()<CR>
#}}}-------------------------------------------------------
#----------------------------------------------------------
# バッファの情報を色付きで表示 {{{
def ShowBufInfo(a: string='')
if &ft==# 'qf'
retu
endif
var b=a==# 'BufReadPost'
if b && ! filereadable(expand('%'))
# プラグインとかが一時的なbufnameを付与して開いた場合は無視する
retu
endif
var c=[]
add(c,['Title',$'"{bufname()}"'])
add(c,['Normal',' '])
if &modified
add(c,['Delimiter','[+]'])
add(c,['Normal',' '])
endif
if !b
add(c,['Tag','[New]'])
add(c,['Normal',' '])
endif
if &readonly
add(c,['WarningMsg','[RO]'])
add(c,['Normal',' '])
endif
cons w=wordcount()
if b || w.bytes !=# 0
add(c,['Constant',printf('%dL, %dB',w.bytes==# 0 ? 0 : line('$'),w.bytes)])
add(c,['Normal',' '])
endif
add(c,['MoreMsg',printf('%s %s %s',&ff,(empty(&fenc) ? &enc : &fenc),&ft)])
var e=0
cons f=&columns-2
for i in reverse(range(0,len(c)-1))
var s=c[i][1]
var d=strdisplaywidth(s)
e+=d
if f < e
cons l=f-e+d
wh !empty(s) && l < strdisplaywidth(s)
s=s[1 :]
endw
c[i][1]=s
c=c[i : ]
insert(c,['NonText','<'],0)
break
endif
endfo
redraw
ec ''
for m in c
exe 'echohl' m[0]
echon m[1]
endfo
echoh Normal
enddef
no <C-g> <Plug>(ahc)<Cmd>call <SID>ShowBufInfo()<CR>
# cmdheight=0にしたら無用になった
# au vimrc BufNewFile*ShowBufInfo('BufNewFile')
# au vimrc BufReadPost*ShowBufInfo('BufReadPost')
#}}}-------------------------------------------------------
#----------------------------------------------------------
# 閉じる {{{
def Quit(a: string='')
if ! empty(a)
if winnr()==# winnr(a)
retu
endif
exe 'wincmd' a
endif
if mode()==# 't'
quit!
else
confirm quit
endif
enddef
nn q <Nop>
nn Q q
nn qh <Cmd>call <SID>Quit('h')<CR>
nn qj <Cmd>call <SID>Quit('j')<CR>
nn qk <Cmd>call <SID>Quit('k')<CR>
nn ql <Cmd>call <SID>Quit('l')<CR>
nn qq <Cmd>call <SID>Quit()<CR>
nn q: q:
nn q/ q/
nn q? q?
#}}}-------------------------------------------------------
#----------------------------------------------------------
# ファイルを移動して保存 {{{
def MoveFile(a: string)
cons b=expand('%')
cons c=expand(a)
if ! empty(b) && filereadable(b)
if filereadable(c)
echoh Error
ec $'file "{newname}" already exists.'
echoh None
retu
endif
rename(b,c)
endif
exe 'saveas!' c
# 開き直してMRUに登録
edit
enddef
com! -nargs=1 -complete=file MoveFile call <SID>MoveFile(<f-args>)
cnoreabbrev mv MoveFile
#}}}
#----------------------------------------------------------
# vimrc作成用 {{{
# カーソル行を実行するやつ
cno <expr> <SID>(exec_line) $'{getline('.')->substitute('^[ \t"#:]\+', '', '')}<CR>'
nm g: <Plug>(ahc):<C-u><SID>(exec_line)
nm g9 <Plug>(ahc):<C-u>vim9cmd <SID>(exec_line)
vn g: "vy<Plug>(ahc):<C-u><C-r>=@v<CR><CR>
vn g9 "vy<Plug>(ahc):<C-u>vim9cmd <C-r>=@v<CR><CR>
# カーソル位置のハイライトを確認するやつ
nn <expr> <Space>gh $'<Cmd>hi {synID(line('.'), col('.'), 1)->synIDattr('name')->substitute('^$', 'Normal', '')}<CR>'
#}}}
#----------------------------------------------------------
# その他細々したの {{{
if has('clipboard')
au vimrc FocusGained * @" = @+
au vimrc FocusLost * @+ = @"
endif
nn <F11> <Cmd>set number!<CR>
nn <F12> <Cmd>set wrap!<CR>
cno <expr> <SID>(rpl) $'s///g \| noh{repeat('<Left>', 9)}'
nm gs :<C-u>%<SID>(rpl)
nm gS :<C-u>%<SID>(rpl)<Cmd>call feedkeys(expand('<cword>')->escape('^$.*?/\[]'), 'ni')<CR><Right>
vm gs :<SID>(rpl)
nn Y y$
nn <Space>p $p
nn <Space>P ^P
nn <Space><Space>p o<Esc>P
nn <Space><Space>P O<Esc>p
# 分割キーボードで右手親指が<CR>になったので
nm <CR> <Space>
# `T`多少潰しても大丈夫だろう…
nm TE :<C-u>tabe<Space>
nn TN <Cmd>tabnew<CR>
nn TD <Cmd>tabe ./<CR>
nn TT <Cmd>silent! tabnext #<CR>
ono <expr> } $'<Esc>m`0{v:count1}{v:operator}' .. '}'
ono <expr> { $'<Esc>m`V{v:count1}' .. '{' .. v:operator
vn <expr> h mode() ==# 'V' ? '<Esc>h' : 'h'
vn <expr> l mode() ==# 'V' ? '<Esc>l' : 'l'
vn J j
vn K k
ino ｋｊ <Esc>`^
ino 「 「」<Left>
ino 「」 「」<Left>
ino （ ()<Left>
ino （） ()<Left>
au vimrc FileType vim if getline(1) ==# 'vim9script'|&commentstring='#%s'|endif
#}}}-------------------------------------------------------
#----------------------------------------------------------
# 様子見中 {{{
# 使わなそうなら削除する
vn <expr> p $'"_s<C-R>{v:register}<ESC>'
vn P p
nn <Space>h ^
nn <Space>l $
nn <Space>d "_d
nn <Space>n <Cmd>nohlsearch<CR>
au vimrc CursorHold * feedkeys(' n') # nohはauで動かない(:help noh)
# どっちも<C-w>w。左手オンリーと右手オンリーのマッピング
nn <Space>w <C-w>w
nn <Space>o <C-w>w
# CSVとかのヘッダを固定表示する。ファンクションキーじゃなくてコマンド定義すればいいかな…
nn <silent> <F10> <ESC>1<C-w>s:1<CR><C-w>w
vn <F10> <ESC>1<C-w>s<C-w>w
# US→「"」押しにくい、JIS→「'」押しにくい
# デフォルトのMはあまり使わないかなぁ…
nn ' "
nn m '
nn M m
# うーん…
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
ino jjx <Cmd>call <SID>ToggleCheckBox()<CR>
# これはちょっと押しにくい(自分のキーボードだと)
ino <M-x> <Cmd>call <SID>ToggleCheckBox()<CR>
# 英単語は`q`のあとは必ず`u`だから`q`をプレフィックスにする手もありか？
# そもそも`q`が押しにくいか…
cno qq <C-f>
# syntax固有の追加強調
def ClearMySyntax()
for a in get(w:,'my_syntax',[])
matchdelete(a)
endfo
w:my_syntax=[]
enddef
def AddMySyntax(a: string,b: string)
w:my_syntax->add(matchadd(a,b))
enddef
au vimrc Syntax * ClearMySyntax()
# 「==#」とかの存在を忘れないように
au vimrc Syntax javascript,vim AddMySyntax('SpellRare', '\s[=!]=\s')
# 基本的にnormalは再マッピングさせないように「!」を付ける
au vimrc Syntax vim AddMySyntax('SpellRare', '\<normal!\@!')
#noremap <F1> <Cmd>smile<CR>
#}}}-------------------------------------------------------
#----------------------------------------------------------
# † あともう1回「これ使ってないな…」と思ったときに消す {{{
nn <Space>a A
# 最後の選択範囲を現在行の下に移動する
nn <expr> <Space>m $'<Cmd>{getpos("'<")[1]},{getpos("'>")[1]}move {getpos('.')[1]}<CR>'
#}}}-------------------------------------------------------
#----------------------------------------------------------
# デフォルトマッピングデー {{{
if strftime('%d')==# '01'
def DMD()
notification#show("✨ Today, Let's enjoy the default key mapping ! ✨")
imapclear
mapclear
enddef
au vimrc VimEnter * DMD()
endif
#}}}-------------------------------------------------------
#----------------------------------------------------------
# 色 {{{
def DefaultColors()
g:rainbow_conf={
guifgs: ['#9999ee','#99ccee','#99ee99','#eeee99','#ee99cc','#cc99ee'],
ctermfgs: ['105','117','120','228','212','177']
}
g:rcsv_colorpairs=[
['105','#9999ee'],['117','#99ccee'],['120','#99ee99'],
['228','#eeee99'],['212','#ee99cc'],['177','#cc99ee']
]
enddef
au vimrc ColorSchemePre * DefaultColors()
def MyMatches()
if exists('w:my_matches') && !empty(getmatches())
retu
endif
w:my_matches=1
matchadd('String','「[^」]*」')
matchadd('Label','^\s*■.*$')
matchadd('Delimiter','WARN\|注意\|注:\|[★※][^\s()（）]*')
matchadd('Todo','TODO')
matchadd('Error','ERROR')
matchadd('Delimiter','- \[ \]')
# 全角空白、半角幅の円記号、文末空白
matchadd('SpellBad','　\|¥\|\s\+$')
# 稀によくtypoする単語(気づいたら追加する)
matchadd('SpellBad','stlye')
enddef
au vimrc VimEnter,WinEnter * MyMatches()
set t_Co=256
syntax on
set bg=dark
sil! colorscheme girly
#}}}-------------------------------------------------------
#----------------------------------------------------------
# メモ {{{
# <F1> <S-F1>でフォルダを開く(win32)
# <F2> MRU
# <F3>
# <F4>
# <F5> 日付関係
# <F6>
# <F7>
# <F8>
# <F9>
# <F10> ヘッダ行を表示(あんまり使わない)
# <F11> 行番号表示切替
# <F12> 折り返し表示切替
#}}}-------------------------------------------------------
if filereadable(expand('~/.vimrc_local'))
so ~/.vimrc_local
endif
