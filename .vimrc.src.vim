vim9script
set encoding=utf-8
scriptencoding utf-8

# ----------------------------------------------------------
# 基本設定 {{{
set fileencodings=ucs-bom,utf-8,iso-2022-jp,cp932,euc-jp
set noexpandtab
set tabstop=3 # 意外とありな気がしてきた…
set shiftwidth=0
set softtabstop=0
set autoindent
set smartindent
set breakindent
set backspace=indent,start,eol
set nf=alpha,hex
set virtualedit=block
set list
set listchars=tab:\|\ ,trail:-,extends:>,precedes:<,nbsp:%
set fillchars=
set cmdheight=0
set laststatus=2
set noruler
set noshowcmd
set noshowmode
set display=lastline
set ambiwidth=double
set belloff=all
set ttimeoutlen=50
set wildmenu
set autochdir
set backupskip=/var/tmp/*
set undodir=~/.vim/undo
set undofile
set updatetime=2000
set incsearch
set hlsearch
nohlsearch

augroup vimrc
	# 新しい自由
	au!
augroup End
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# ユーティリティ {{{
const rtproot = has('win32') ? '~/vimfiles' : '~/.vim'
const has_deno = executable('deno')

# こんな感じ
# MultiCmd nmap,vmap xxx yyy<if-nmap>NNN<if-vmap>VVV<>zzz
# ↓
# nmap xxx yyyNNNzzz | vmap xxx yyyVVVzzz
def MultiCmd(qargs: string)
	const q = qargs->substitute('^\S*', '', '')
	for cmd in qargs->matchstr('^\S*')->split(',')
		const a = q
			->substitute('<if-' .. cmd .. '>', '<>', 'g')
			->substitute('<if-.\{-1,}\(<if-\|<>\|$\)', '', 'g')
			->substitute('<>', '', 'g')
		execute cmd .. a
	endfor
enddef
command! -nargs=* MultiCmd MultiCmd(<q-args>)

# その他
command! -nargs=1 -complete=var Enable  <args> = 1
command! -nargs=1 -complete=var Disable <args> = 0

def RemoveEmptyLine(line: number)
	execute 'silent! ' .. line .. 's/\s\+$//'
	execute 'silent! ' .. line .. 's/^\s*\n//'
enddef

def BufIsSmth(): bool
	return &modified || ! empty(bufname())
enddef

def IndentStr(expr: any): string
	return matchstr(getline(expr), '^\s*')
enddef
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# プラグイン {{{

# jetpack {{{

const jetpackfile = expand(rtproot .. '/pack/jetpack/opt/vim-jetpack/plugin/jetpack.vim')
const has_jetpack = filereadable(jetpackfile)
if ! has_jetpack
  const jetpackurl = 'https://raw.githubusercontent.com/tani/vim-jetpack/master/plugin/jetpack.vim'
  system(printf('curl -fsSLo %s --create-dirs %s', jetpackfile, jetpackurl))
endif

packadd vim-jetpack
jetpack#begin()
Jetpack 'tani/vim-jetpack', { 'opt': 1 }
Jetpack 'airblade/vim-gitgutter'
Jetpack 'alvan/vim-closetag'
Jetpack 'ctrlpvim/ctrlp.vim'
Jetpack 'cohama/lexima.vim'      # 括弧補完
Jetpack 'delphinus/vim-auto-cursorline'
Jetpack 'dense-analysis/ale'
Jetpack 'easymotion/vim-easymotion'
Jetpack 'hrsh7th/vim-vsnip'
Jetpack 'hrsh7th/vim-vsnip-integ'
Jetpack 'itchyny/lightline.vim'
Jetpack 'kana/vim-textobj-user'
Jetpack 'LeafCage/vimhelpgenerator'
Jetpack 'luochen1990/rainbow'    # 虹色括弧
Jetpack 'machakann/vim-sandwich'
Jetpack 'mattn/ctrlp-matchfuzzy'
Jetpack 'mattn/vim-notification'
Jetpack 'matze/vim-move'         # 行移動
Jetpack 'mechatroner/rainbow_csv'
Jetpack 'michaeljsmith/vim-indent-object'
Jetpack 'osyo-manga/vim-textobj-multiblock'
Jetpack 'othree/html5.vim'
Jetpack 'othree/yajs.vim'
Jetpack 'prabirshrestha/asyncomplete-buffer.vim'
Jetpack 'prabirshrestha/asyncomplete.vim'
Jetpack 'rafamadriz/friendly-snippets'
Jetpack 'thinca/vim-portal'
Jetpack 'tpope/vim-fugitive'      # Gdiffとか
Jetpack 'tyru/caw.vim'            # コメント化
Jetpack 'yami-beta/asyncomplete-omni.vim'
Jetpack 'yegappan/mru'
Jetpack 'utubo/jumpcuorsor.vim'   # vimに対応させたやつ(様子見)vim-jetpackだとインストール出来ないかも？
Jetpack 'utubo/vim-auto-hide-cmdline'
Jetpack 'utubo/vim-colorscheme-girly'
Jetpack 'utubo/vim-minviml'
Jetpack 'utubo/vim-portal-aim'
Jetpack 'utubo/vim-registers-lite'
Jetpack 'utubo/vim-reformatdate'
Jetpack 'utubo/vim-tabtoslash'
Jetpack 'utubo/vim-textobj-twochars'
# あまり使ってないけど作ったので…
Jetpack 'utubo/vim-shrink'
Jetpack 'utubo/vim-tablist'
Jetpack 'utubo/vim-tabpopupmenu'
# denoがある環境用
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
Enable  g:EasyMotion_smartcase
Enable  g:EasyMotion_use_migemo
Enable  g:EasyMotion_enter_jump_first
Disable g:EasyMotion_do_mapping
g:EasyMotion_keys = 'asdghklqwertyuiopzxcvbnmfjASDGHKLQWERTYUIOPZXCVBNMFJ;'
map s <Plug>(ahc)<Plug>(easymotion-s)
au vimrc VimEnter,BufEnter * EMCommandLineNoreMap <Space><Space> <Esc>
#}}}

# sandwich {{{
g:sandwich#recipes = deepcopy(g:sandwich#default_recipes)
g:sandwich#recipes += [
	{ buns: ["\r", ''  ], input: ["\r"], command: ["normal! a\r"] },
	{ buns: ['',   ''  ], input: ['q'] },
	{ buns: ['「', '」'], input: ['k'] },
	{ buns: ['>',  '<' ], input: ['>'] },
	{ buns: ['{ ', ' }'], input: ['{'] },
	{ buns: ['${', '}' ], input: ['${'] },
	{ buns: ['%{', '}' ], input: ['%{'] },
	{ buns: ['CommentString(0)', 'CommentString(1)'], expr: 1, input: ['c'] },
]
def! g:CommentString(index: number): string
	return &commentstring->split('%s')->get(index, '')
enddef
Enable g:sandwich_no_default_key_mappings
Enable g:operator_sandwich_no_default_key_mappings
MultiCmd nmap,vmap Sd <Plug>(operator-sandwich-delete)<if-nmap>ab
MultiCmd nmap,vmap Sr <Plug>(operator-sandwich-replace)<if-nmap>ab
MultiCmd nmap,vmap Sa <Plug>(operator-sandwich-add)<if-nmap>iw
MultiCmd nmap,vmap S  <Plug>(operator-sandwich-add)<if-nmap>iw
nmap S^ v^S
nmap S$ vg_S
nmap <expr> SS (matchstr(getline('.'), '[''"]', getpos('.')[2]) ==# '"') ? 'Sr"''' : 'Sr''"'

# 改行で挟んだあとタブでインデントされると具合が悪くなるので…
def FixSandwichPos()
	var c = g:operator#sandwich#object.cursor
	if g:fix_sandwich_pos[1] != c.inner_head[1]
		c.inner_head[2] = getline(c.inner_head[1])->match('\S') + 1
		c.inner_tail[2] = getline(c.inner_tail[1])->match('$') + 1
	endif
enddef
au vimrc User OperatorSandwichAddPre g:fix_sandwich_pos = getpos('.')
au vimrc User OperatorSandwichAddPost FixSandwichPos()

# 内側に連続で挟むやつ
def RemarkPatty()
	setpos("'<", g:operator#sandwich#object.cursor.inner_head)
	setpos("'>", g:operator#sandwich#object.cursor.inner_tail)
enddef
nmap S. <Cmd>call <SID>RemarkPatty()<CR>gvSa

var big_mac_crown = []
def BigMac(is_nest: bool = false)
	const c = is_nest ? g:operator#sandwich#object.cursor.inner_head[1 : 2] : []
	if ! is_nest || big_mac_crown !=# c
		big_mac_crown = c
		au vimrc User OperatorSandwichAddPost ++once BigMac(true)
		feedkeys(is_nest ? 'S.' : 'gvSa')
	endif
enddef
nmap Sm viwSm
vmap Sm <Cmd>call <SID>BigMac()<CR>

# 行末空白と空行を削除
def RemoveAirBuns()
	const c = g:operator#sandwich#object.cursor
	RemoveEmptyLine(c.tail[1])
	RemoveEmptyLine(c.head[1])
enddef
au vimrc User OperatorSandwichDeletePost RemoveAirBuns()
#}}}

# MRU {{{
# デフォルト設定(括弧内にフルパス)だとパスに括弧が含まれているファイルが開けないので、パスに使用されない文字を区切りにする
g:MRU_Filename_Format = {
	formatter: 'fnamemodify(v:val, ":t") . " > " . v:val',
	parser: '> \zs.*',
	syntax: '^.\{-}\ze >'
}
# 数字キーで開く
def MRUwithNumKey(use_tab: bool)
	b:use_tab = use_tab
	setlocal number
	redraw
	if &cmdheight !=# 0
		echoh Question
		echo printf('[1]..[9] => open with a %s.', use_tab ? 'tab' : 'window')
		echoh None
	endif
	const key = use_tab ? 't' : '<CR>'
	for i in range(1, 9)
		execute printf('nmap <buffer> <silent> %d :<C-u>%d<CR>%s', i, i, key)
	endfor
enddef
def MyMRU()
	Enable b:auto_cursorline_disabled
	setlocal cursorline
	nnoremap <buffer> w <Cmd>call <SID>MRUwithNumKey(!b:use_tab)<CR>
	nnoremap <buffer> R <Cmd>MruRefresh<CR><Cmd>normal! u
	MRUwithNumKey(BufIsSmth())
enddef
au vimrc FileType mru MyMRU()
au vimrc ColorScheme * hi link MruFileName Directory
nnoremap <F2> <Cmd>MRUToggle<CR>
g:MRU_Exclude_Files = has('win32') ? $TEMP .. '\\.*' : '^/tmp/.*\|^/var/tmp/.*'
#}}}

# 補完 {{{
def RegisterAsyncompSource(name: string, white: list<string>, black: list<string>)
	execute printf("asyncomplete#register_source(asyncomplete#sources#%s#get_source_options({ name: '%s', whitelist: %s, blacklist: %s, completor: asyncomplete#sources#%s#completor }))", name, name, white, black, name)
enddef
RegisterAsyncompSource('omni', ['*'], ['c', 'cpp', 'html'])
RegisterAsyncompSource('buffer', ['*'], ['go'])
MultiCmd imap,smap <expr> JJ      vsnip#expandable() ? '<Plug>(vsnip-expand)' : 'JJ'
MultiCmd imap,smap <expr> <C-l>   vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
MultiCmd imap,smap <expr> <Tab>   vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)' : pumvisible() ? '<C-n>' : '<Tab>'
MultiCmd imap,smap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : pumvisible() ? '<C-p>' : '<S-Tab>'
#imap <expr> <CR> pumvisible() ? '<C-y>' : '<CR>'
Enable g:lexima_accept_pum_with_enter
# https://qiita.com/yami_beta/items/26995a5c382bd83ac38f
inoremap <C-l> <Cmd>lexima#insmode#leave(1, '<LT>C-G>U<LT>RIGHT>')<CR>
#}}}

# ALE {{{
Enable  g:ale_set_quickfix
Enable  g:ale_fix_on_save
Disable g:ale_lint_on_insert_leave
Disable g:ale_set_loclist
g:ale_sign_error = '🐞'
g:ale_sign_warning = '🐝'
g:ale_fixers = { typescript: ['deno'] }
g:ale_lint_delay = &updatetime
nmap <silent> [a <Plug>(ale_previous_wrap)
nmap <silent> ]a <Plug>(ale_next_wrap)
# cmdheight=0だとALEのホバーメッセージがちらつくのでg:ll_aleに代入してlightlineで表示する
Disable g:ale_echo_cursor
g:ll_are = ''
def ALEEchoCursorCmdHeight0()
	var loc = ale#util#FindItemAtCursor(bufnr())[1]
	if !empty(loc)
		g:ll_ale = loc.type ==# 'E' ? '🐞' : '🐝'
		g:ll_ale ..= ' '
		g:ll_ale ..= get(loc, 'detail', loc.text)->split('\n')[0]
			->substitute('^\[[^]]*\] ', '', '')
	else
		g:ll_ale = ''
	endif
enddef
au vimrc CursorMoved * ALEEchoCursorCmdHeight0()
#}}}

# lightline {{{
# ヤンクしたやつを表示するやつ
g:ll_reg = ''
def LLYankPost()
	var reg = substitute(v:event.regcontents[0], '\t', ' ', 'g')
	if len(v:event.regcontents) !=# 1 || len(reg) > 10
		reg = substitute(reg, '^\(.\{0,8\}\).*', '\1>', '')
	endif
	g:ll_reg = '📋:' .. reg
enddef
au vimrc TextYankPost * LLYankPost()

# 毎時45分から15分間休憩しようね
g:ll_tea_break = '0:00'
g:ll_tea_break_opentime = localtime()
def! g:VimrcTimer60s(timer: any)
	const tick = (localtime() - g:ll_tea_break_opentime) / 60
	const mm = tick % 60
	const tea = mm >= 45 ? '☕🍴🍰' : ''
	g:ll_tea_break = tea .. printf('%d:%02d', tick / 60, mm)
	lightline#update()
	if (mm == 45)
		notification#show("       ☕🍴🍰\nHave a break time !")
	endif
enddef
timer_stop(get(g:, 'vimrc_timer_60s', 0))
g:vimrc_timer_60s = timer_start(60000, 'VimrcTimer60s', { repeat: -1 })

# &ff
if has('win32')
	def! g:LLFF(): string
		return &ff !=# 'dos' ? &ff : ''
	enddef
else
	def! g:LLFF(): string
		return &ff ==# 'dos' ? &ff : ''
	enddef
endif

# &fenc
def! g:LLNotUtf8(): string
	return &fenc ==# 'utf-8' ? '' : &fenc
enddef

# lightline設定
g:lightline = {
	colorscheme: 'wombat',
	active: {
		left:  [['mode', 'paste'], ['fugitive', 'filename'], ['ale']],
		right: [['teabreak'], ['ff', 'notutf8', 'li'], ['reg']]
	},
	component: { teabreak: '%{g:ll_tea_break}', reg: '%{g:ll_reg}', ale: '%=%{g:ll_ale}', li: '%2c,%l/%L' },
	component_function: { ff: 'LLFF', notutf8: 'LLNotUtf8' },
}

# tablineはデフォルト
au vimrc VimEnter * set tabline=
#}}}

# skk {{{
if has_deno
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
#}}}

# textobj-multiblock  {{{
omap ab <Plug>(textobj-multiblock-a)
omap ib <Plug>(textobj-multiblock-i)
xmap ab <Plug>(textobj-multiblock-a)
xmap ib <Plug>(textobj-multiblock-i)
g:textobj_multiblock_blocks = [
	\ [ "(", ")" ],
	\ [ "[", "]" ],
	\ [ "{", "}" ],
	\ [ '<', '>' ],
	\ [ '"', '"', 1 ],
	\ [ "'", "'", 1 ],
	\ [ ">", "<", 1 ],
	\ [ "「", "」", 1 ],
]
#}}}

# Portal {{{
nnoremap <Leader>a <Cmd>PortalAim<CR>
nnoremap <Leader>b <Cmd>PortalAim blue<CR>
nnoremap <Leader>o <Cmd>PortalAim orange<CR>
nnoremap <Leader>r <Cmd>PortalReset<CR>
# }}}

# ヘルプ作成 {{{
g:vimhelpgenerator_version = ''
g:vimhelpgenerator_author = 'Author  : utubo'
g:vimhelpgenerator_defaultlanguage = 'en'
# }}}

# その他 {{{
Enable  g:rainbow_active
g:auto_cursorline_wait_ms = &updatetime
g:auto_hide_cmdline_switch_statusline = 1
g:ctrlp_match_func = {'match': 'ctrlp_matchfuzzy#matcher'}
g:ctrlp_cmd = 'CtrlPMixed'
nmap [c <Plug>(ahc)<Plug>(GitGutterPrevHunk)
nmap ]c <Plug>(ahc)<Plug>(GitGutterNextHunk)
nnoremap <Space>gv <Cmd>Gvdiffsplit<CR>
nnoremap <Space>gd <Cmd>Gdiffsplit<CR>
nmap     <Space>ga <Plug>(ahc-nowait):<C-u>Git add %
nnoremap <Space>gc :<C-u>Git commit -m ''<Left>
nnoremap <Space>gp :<C-u>Git push
nnoremap <Space>gl <Cmd>Git pull<CR>
nnoremap <Space>t <Cmd>call tabpopupmenu#popup()<CR>
nnoremap <Space>T <Cmd>call tablist#Show()<CR>
MultiCmd nmap,vmap <Space>c <Plug>(caw:hatpos:toggle)
MultiCmd nmap,tmap <silent> <C-w><C-s> <Plug>(shrink-height)<C-w>w
MultiCmd nmap,tmap <silent> <C-w><C-h> <Plug>(shrink-width)<C-w>w
# EasyMotionとどっちを使うか様子見中
nmap <Space>s <Plug>(jumpcursor-jump)
#}}}

# 開発用 {{{
const localplugins = expand(rtproot .. '/pack/local/opt/*')
if localplugins !=# ''
	&runtimepath = substitute(localplugins, '\n', ',', 'g') .. ',' .. &runtimepath
endif
# }}}

filetype plugin indent on
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# コピペ寄せ集め色々 {{{
au vimrc InsertLeave * set nopaste
au vimrc BufReadPost *.log* normal! G
vnoremap * "vy/\V<Cmd>substitute(escape(@v,'\/'),"\n",'\\n','g')<CR><CR>
inoremap kj <Esc>`^
inoremap kk <Esc>`^
inoremap <CR> <CR><C-g>u
# https://github.com/astrorobot110/myvimrc/blob/master/vimrc
set matchpairs+=（:）,「:」,『:』,【:】,［:］,＜:＞
# https://github.com/Omochice/dotfiles
nnoremap <expr> i len(getline('.')) !=# 0 ? 'i' : '"_cc'
nnoremap <expr> a len(getline('.')) !=# 0 ? 'a' : '"_cc'
nnoremap <expr> A len(getline('.')) !=# 0 ? 'A' : '"_cc'
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# タブ幅やタブ展開を自動設定 {{{
def SetupTabstop()
	const limit = 100
	const org = getpos('.')
	cursor(1, 1)
	if !!search('^\t', 'nc', limit)
		setlocal noexpandtab
		setlocal tabstop=3 # 意外とありな気がしてきた…
	elseif !!search('^  \S', 'nc', limit)
		setlocal expandtab
		setlocal tabstop=2
	elseif !!search('^    \S', 'nc', limit)
		setlocal expandtab
		setlocal tabstop=4
	endif
	setpos('.', org)
enddef
au vimrc BufReadPost * SetupTabstop()
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# vimgrep {{{
def VimGrep(keyword: string, ...targets: list<string>)
	var path = join(targets, ' ')
	# パスを省略した場合は、同じ拡張子のファイルから探す
	if empty(path)
		path = expand('%:e') ==# '' ? '*' : ('*.' .. expand('%:e'))
	endif
	# 適宜タブで開く(ただし明示的に「%」を指定したらカレントで開く)
	const use_tab = BufIsSmth() && path !=# '%'
	if use_tab
		tabnew
	endif
	# lvimgrepしてなんやかんやして終わり
	execute printf('silent! lvimgrep %s %s', keyword, path)
	if ! empty(getloclist(0))
		lwindow
	else
		echoh ErrorMsg
		echomsg 'Not found.: ' .. keyword
		echoh None
		if use_tab
			tabnext -
			tabclose +
		endif
	endif
enddef
command! -nargs=+ VimGrep VimGrep(<f-args>)
nnoremap <Space>/ :<C-u>VimGrep<Space>

def SetupQF()
	nnoremap <buffer> <silent> ; <CR>:silent! normal! zv<CR><C-W>w
	nnoremap <buffer> <silent> w <C-W><CR>:silent! normal! zv<CR><C-W>w
	nnoremap <buffer> <silent> t <C-W><CR>:silent! normal! zv<CR><C-W>T
	nnoremap <buffer> <nowait> q <Cmd>lexpr ''<CR>:q<CR>
	nnoremap <buffer> f <C-f>
	nnoremap <buffer> b <C-b>
	# 様子見中(使わなそうなら削除する)
	execute printf('nnoremap <buffer> T <C-W><CR><C-W>T%dgt', tabpagenr())
enddef
au vimrc FileType qf SetupQF()
au vimrc WinEnter * if winnr('$') == 1 && &buftype ==# 'quickfix' | q | endif
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# diff {{{
set splitright
set fillchars+=diff:\ # 削除行は空白文字で埋める
# diffモードを自動でoff https://hail2u.net/blog/software/vim-turn-off-diff-mode-automatically.html
au vimrc WinEnter * if (winnr('$') == 1) && !!getbufvar(winbufnr(0), '&diff') | diffoff | endif
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# 日付関係 {{{
g:reformatdate_extend_names = [{
	a: ['日', '月', '火', '水', '木', '金', '土'],
	A: ['日曜日', '月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日'],
}]
inoremap <expr> <F5> strftime('%Y/%m/%d')
cnoremap <expr> <F5> strftime('%Y%m%d')
nnoremap <F5> <Cmd>call reformatdate#reformat(localtime())<CR>
nnoremap <C-a> <Cmd>call reformatdate#inc(v:count)<CR>
nnoremap <C-x> <Cmd>call reformatdate#dec(v:count)<CR>
nnoremap <Space><F5> /\d\{4\}\/\d\d\/\d\d<CR>
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# スマホ用 {{{
# - キーが小さいので押しにくいものはSpaceへマッピング
# - スマホでのコーディングは基本的にバグ取り
nnoremap <Space>zz <Cmd>q!<CR>
# スタックトレースからyankしてソースの該当箇所を探すのを補助
nnoremap <Space>e G?\cErr\\|Exception<CR>
nnoremap <Space>y yiw
nnoremap <expr> <Space>f (getreg('"') =~ '^\d\+$' ? ':' : '/') .. getreg('"') .. '<CR>'
# スマホだと:とファンクションキーが遠いので…
nmap <Space>, :
for i in range(1, 10)
	execute printf('nmap <Space>%d <F%d>', i % 10, i)
endfor
nmap <Space><Space>1 <F11>
nmap <Space><Space>2 <F12>
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# カーソルを行頭に合わせて移動 {{{
def PutHat(): string
	const x = getline('.')->match('\S') + 1
	if x != 0 || !exists('w:my_hat')
		w:my_hat = col('.') == x ? '^' : ''
	endif
	return w:my_hat
enddef
nnoremap <expr> j 'j' .. <SID>PutHat()
nnoremap <expr> k 'k' .. <SID>PutHat()
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# 折り畳み {{{
# こんなかんじでインデントに合わせて表示📁 {{{
def! g:MyFoldText(): string
	const src = getline(v:foldstart)
	const indent = repeat(' ', indent(v:foldstart))
	const text = &foldmethod ==# 'indent' ? '' : src->substitute(matchstr(&foldmarker, '^[^,]*'), '', '')->trim()
	return indent .. text .. '📁'
enddef
set foldtext=g:MyFoldText()
set fillchars+=fold:\ # 折り畳み時の「-」は半角空白
au vimrc ColorScheme * hi! link Folded Delimiter
#}}}
# ホールドマーカーの前にスペース、後ろに改行を入れる {{{
def Zf()
	if line("'<") != line('.')
		return
	endif
	const firstline = line("'<")
	const lastline = line("'>")
	execute ':' firstline 's/\v(\S)?$/\1 /'
	execute ':' lastline 'normal! o<Esc>i' .. IndentStr(firstline)
	cursor([firstline, 1])
	normal! V
	cursor([lastline + 1, 1])
	normal! zf
enddef
vnoremap zf :call <SID>Zf()<CR>
#}}}
# ホールドマーカーを削除したら行末をトリムする {{{
def Zd()
	if foldclosed(line('.')) == -1
		normal! zc
	endif
	const head = foldclosed(line('.'))
	const tail = foldclosedend(line('.'))
	if head == -1
		return
	endif
	const org = getpos('.')
	normal! zd
	RemoveEmptyLine(tail)
	RemoveEmptyLine(head)
	setpos('.', org)
enddef
nnoremap zd <Cmd>Zd()<CR>
#}}}
# その他折りたたみ関係 {{{
set foldmethod=marker
au vimrc FileType markdown,yaml setlocal foldlevelstart=99 | setlocal foldmethod=indent
au vimrc BufReadPost * :silent! normal! zO
nnoremap <expr> h (col('.') == 1 && 0 < foldlevel('.') ? 'zc' : 'h')
nnoremap Z<Tab> <Cmd>set foldmethod=indent<CR>
nnoremap Z{ <Cmd>set foldmethod=marker<CR>
nnoremap Zy <Cmd>set foldmethod=syntax<CR>
#}}}
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# ビジュアルモードあれこれ {{{
def KeepingCurPos(expr: string)
	const cur = getcurpos()
	execute expr
	setpos('.', cur)
enddef
vnoremap u <Cmd>call <SID>KeepingCurPos('undo')<CR>
vnoremap <C-R> <Cmd>call <SID>KeepingCurPos('redo')<CR>
vnoremap <Tab> <Cmd>normal! >gv<CR>
vnoremap <S-Tab> <Cmd>normal! <gv<CR>
#}}}

# ----------------------------------------------------------
# コマンドモードあれこれ {{{
cnoremap <C-h> <Space><BS><Left>
cnoremap <C-l> <Space><BS><Right>
cnoremap <expr> <C-r><C-r> trim(@")
cnoremap <expr> <C-r><C-e> escape(@", '~^$.*?/\[]')
nnoremap q; :q
cnoreabbrev cs colorscheme

# 「jj」で<CR>、「kk」はキャンセル
# ただし保存は片手で「;jj」でもOK(「;wjj」じゃなくていい)
cnoremap kk <C-c>
# auto-hide-cmdlineのためにcnoremapではなくcmapを使う
cmap <expr> jj (empty(getcmdline()) && getcmdtype() == ':' ? 'update<CR>' : '<CR>')
inoremap ;jj <Esc>`^:update<CR>

#}}} -------------------------------------------------------

# ----------------------------------------------------------
# terminalとか {{{
if has('win32')
	command! Powershell :bo terminal ++close pwsh
	nnoremap SH <Cmd>Powershell<CR>
	nnoremap <S-F1> <Cmd>silent !start explorer %:p:h<CR>
else
	nnoremap SH <Cmd>bo terminal<CR>
endif
tnoremap <C-w>; <C-w>:
tnoremap <C-w><C-w> <C-w>w
tnoremap <C-w><C-q> exit<CR>
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# markdownのチェックボックス {{{
def ToggleCheckBox()
	const a = getline('.')
	var b = substitute(a, '^\(\s*\)- \[ \]', '\1- [x]', '') # check on
	if a ==# b
		b = substitute(a, '^\(\s*\)- \[x\]', '\1- [ ]', '') # check off
	endif
	if a ==# b
		b = substitute(a, '^\(\s*\)\(- \)*', '\1- [ ] ', '') # a new check box
	endif
	setline('.', b)
	var c = getpos('.')
	c[2] += len(b) - len(a)
	setpos('.', c)
enddef
noremap <Space>x <Cmd>call <SID>ToggleCheckBox()<CR>
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# バッファの情報を色付きで表示 {{{
def ShowBufInfo(event: string = '')
	if &ft ==# 'qf'
		return
	endif

	if &cmdheight ==# 0 && ! empty(event)
		return
	endif

	var isReadPost = event ==# 'BufReadPost'
	if isReadPost && ! filereadable(expand('%'))
		# プラグインとかが一時的なbufnameを付与して開いた場合は無視する
		return
	endif

	var msg = []
	add(msg, ['Title', '"' .. bufname() .. '"'])
	add(msg, ['Normal', ' '])
	if &modified
		add(msg, ['Delimiter', '[+]'])
		add(msg, ['Normal', ' '])
	endif
	if !isReadPost
		add(msg, ['Tag', '[New]'])
		add(msg, ['Normal', ' '])
	endif
	if &readonly
		add(msg, ['WarningMsg', '[RO]'])
		add(msg, ['Normal', ' '])
	endif
	const w = wordcount()
	if isReadPost || w.bytes !=# 0
		add(msg, ['Constant', printf('%dL, %dB', w.bytes ==# 0 ? 0 : line('$'), w.bytes)])
		add(msg, ['Normal', ' '])
	endif
	add(msg, ['MoreMsg', printf('%s %s %s', &ff, (empty(&fenc) ? &encoding : &fenc), &ft)])
	var msglen = 0
	const maxlen = &columns - 2
	for i in reverse(range(0, len(msg) - 1))
		var s = msg[i][1]
		var d = strdisplaywidth(s)
		msglen += d
		if maxlen < msglen
			const l = maxlen - msglen + d
			while !empty(s) && l < strdisplaywidth(s)
				s = s[1 :]
			endwhile
			msg[i][1] = s
			msg = msg[i : ]
			insert(msg, ['NonText', '<'], 0)
			break
		endif
	endfor
	redraw
	echo ''
	for m in msg
		execute 'echohl' m[0]
		echon m[1]
	endfor
	echohl Normal
	#redraw
enddef
noremap <C-g> <Cmd>call <SID>ShowBufInfo()<CR>
au vimrc BufNewFile * ShowBufInfo('BufNewFile')
au vimrc BufReadPost * ShowBufInfo('BufReadPost')
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# 閉じる {{{
def Quit(expr: string = '')
	if ! empty(expr)
		if winnr() == winnr(expr)
			return
		endif
		execute 'wincmd ' .. expr
	endif
	if mode() ==# 't'
		quit!
	else
		confirm quit
	endif
enddef
nnoremap qh <Cmd>call <SID>Quit('h')<CR>
nnoremap qj <Cmd>call <SID>Quit('j')<CR>
nnoremap qk <Cmd>call <SID>Quit('k')<CR>
nnoremap ql <Cmd>call <SID>Quit('l')<CR>
nnoremap qq <Cmd>call <SID>Quit()<CR>
nnoremap q: q:
nnoremap q/ q/
nnoremap q? q?
nnoremap q <Nop>
nnoremap Q q
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# ファイルを移動して保存 {{{
def MoveFile(newname: string)
	const oldpath = expand('%')
	const newpath = expand(newname)
	if ! empty(oldpath) && filereadable(oldpath)
		if filereadable(newpath)
			echoh Error
			echo 'file "' .. newname .. '" already exists.'
			echoh None
			return
		endif
		rename(oldpath, newpath)
	endif
	execute 'saveas! ' .. newpath
	# 開き直してMRUに登録
	edit
enddef
command! -nargs=1 -complete=file MoveFile call <SID>MoveFile(<f-args>)
cnoreabbrev mv MoveFile
#}}}

# ----------------------------------------------------------
# vimrc作成用  {{{
cnoremap <expr> <SID>(exec_line) substitute(getline('.'), '^[ \t"#:]\+', '', '') .. '<CR>'
nmap g: <Plug>(ahc):<C-u><SID>(exec_line)
nmap g9 <Plug>(ahc):<C-u>vim9cmd <SID>(exec_line)
vmap g: "vy:<C-u><C-r>=@v<CR><CR>
vmap g9 "vy:<C-u>vim9cmd <C-r>=@v<CR><CR>
# カーソル位置のハイライトを確認するやつ
nnoremap <expr> <Space>gh '<Cmd>hi ' .. substitute(synIDattr(synID(line('.'), col('.'), 1), 'name'), '^$', 'Normal', '') .. '<CR>'
# }}}

# ----------------------------------------------------------
# その他細々したの {{{
if has('clipboard')
	au vimrc FocusGained * @" = @+
	au vimrc FocusLost   * @+ = @"
endif
nnoremap <F11> <Cmd>set number! \| let &cursorline=&number<CR>
nnoremap <F12> <Cmd>set wrap!<CR>
cnoremap <expr> <SID>(left16) repeat('<Left>', 16)
nmap gs :<C-u>%s///g \| nohlsearch<SID>(left16)
vmap gs :s///g \| nohlsearch<SID>(left16)
nmap gS :<C-u>%s/<C-r>=escape(expand("<cword>"), "^$.*?/\[]")<CR>//g \| nohlsearch<SID>(left16)<Right>
nnoremap Y y$
nnoremap <Space>p $p
nnoremap <Space>P ^P
nnoremap <Space><Space>p o<Esc>P
nnoremap <Space><Space>P O<Esc>p
nnoremap TE :<C-u>tabe<Space>
nnoremap TN <Cmd>tabnew<CR>
nnoremap TD <Cmd>tabe ./<CR>
onoremap <expr> } '<Esc>m`0' .. v:count1 .. v:operator .. '}'
onoremap <expr> { '<Esc>m`V' .. v:count1 .. '{' .. v:operator
vnoremap <expr> h mode() ==# 'V' ? '<Esc>h' : 'h'
vnoremap <expr> l mode() ==# 'V' ? '<Esc>l' : 'l'
vnoremap J j
vnoremap K k
inoremap ｋｊ <Esc>`^
inoremap 「 「」<Left>
inoremap 「」 「」<Left>
inoremap （ ()<Left>
inoremap （） ()<Left>
au vimrc FileType vim if getline(1) ==# 'vim9script' | &commentstring = '#%s' | endif
# 分割キーボードで右手親指が<CR>になったので
nmap <CR> <Space>
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# 様子見中 {{{
# 使わなそうなら削除する
vnoremap <expr> p '"_s<C-R>' .. v:register .. '<ESC>'
vnoremap P p
nnoremap <Space>h ^
nnoremap <Space>l $
nnoremap <Space>d "_d
nnoremap <Space>; ;
MultiCmd nmap,vmap ; :
nnoremap / <Cmd>nohlsearch<CR>/
nnoremap ? <Cmd>nohlsearch<CR>?
nnoremap <Space>n <Cmd>nohlsearch<CR>
au vimrc CursorHold * feedkeys(" n") # nohはauで動かない(:help noh)

# どっちも<C-w>w。左手オンリーと右手オンリーのマッピング
nnoremap <Space>w <C-w>w
nnoremap <Space>o <C-w>w

# CSVとかのヘッダを固定表示する。ファンクションキーじゃなくてコマンド定義すればいいかな…
nnoremap <silent> <F10> <ESC>1<C-w>s:1<CR><C-w>w
vnoremap <F10> <ESC>1<C-w>s<C-w>w

# マーク使ってないし
nnoremap ' "
nnoremap <Space>' '

# うーん…
inoremap jj <C-o>
inoremap jjh <C-o>^
inoremap jjl <C-o>$
inoremap jje <C-o>e<C-o>a
inoremap jj; <C-o>$;
inoremap jj, <C-o>$,
inoremap jj{ <C-o>$ {
inoremap jj} <C-o>$ }
inoremap jj<CR> <C-o>$<CR>
inoremap jjk 「」<Left>
inoremap jjx <Cmd>call <SID>ToggleCheckBox()<CR>
# これはちょっと押しにくい(自分のキーボードだと)
inoremap <M-x> <Cmd>call <SID>ToggleCheckBox()<CR>
# 英単語は`q`のあとは必ず`u`だから`q`をプレフィックスにする手もありか？
# そもそも`q`が押しにくいか…
imap ql <C-l>

# syntax固有の追加強調
def ClearMySyntax()
	for id in get(w:, 'my_syntax', [])
		matchdelete(id)
	endfor
	w:my_syntax = []
enddef
def AddMySyntax(group: string, pattern: string)
	w:my_syntax->add(matchadd(group, pattern))
enddef
au vimrc Syntax * ClearMySyntax()
au vimrc Syntax javascript,vim AddMySyntax('SpellRare', '\s[=!]=\s') # 「==#」とかの存在を忘れないように
au vimrc Syntax vim AddMySyntax('SpellRare', '\<normal!\@!') # 基本的には再マッピングさせないように「!」を付ける

# 直前のタブ移動する(割り当てるキーが思いつかない…)
nnoremap g<Leader> <Cmd>tabnext #<CR>

#nnoremap <F1> :<C-u>smile<CR>
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# † あともう1回「これ使ってないな…」と思ったときに消す {{{

nnoremap <Space>a A

# 最後の選択範囲を現在行の下に移動する
nnoremap <expr> <Space>m '<Cmd>' .. getpos("'<")[1] .. ',' .. getpos("'>")[1] .. 'move ' .. getpos('.')[1] .. '<CR>'

#}}} -------------------------------------------------------

# ----------------------------------------------------------
# デフォルトマッピングデー {{{
if strftime('%d') ==# '01'
	def DMD()
		notification#show("✨ Today, Let's enjoy the default key mapping ! ✨")
		imapclear
		mapclear
	enddef
	au vimrc VimEnter * DMD()
endif
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# 色 {{{
def DefaultColors()
	g:rainbow_conf = {
		guifgs: ['#9999ee', '#99ccee', '#99ee99', '#eeee99', '#ee99cc', '#cc99ee'],
		ctermfgs: ['105', '117', '120', '228', '212', '177']
	}
	g:rcsv_colorpairs = [
		['105', '#9999ee'], ['117', '#99ccee'], ['120', '#99ee99'],
		['228', '#eeee99'], ['212', '#ee99cc'], ['177', '#cc99ee']
	]
enddef
au vimrc ColorSchemePre * DefaultColors()
def MyMatches()
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
	# 稀によくtypoする単語(気づいたら追加する)
	matchadd('SpellBad', 'stlye')
enddef
au vimrc VimEnter,WinEnter * MyMatches()
set t_Co=256
syntax on
set background=dark
silent! colorscheme girly
#}}} -------------------------------------------------------

# ----------------------------------------------------------
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
#}}} -------------------------------------------------------

if filereadable(expand('~/.vimrc_local'))
	source ~/.vimrc_local
endif

