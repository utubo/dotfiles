vim9script noclear
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
set cmdheight=1
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
# MultiCmd nmap,vmap xxx yyy<if-nmap>NNN<if-vmap>VVV<if-*>zzz
# ↓
# nmap xxx yyyNNNzzz | vmap xxx yyyVVVzzz
def MultiCmd(qargs: string)
	const [cmds, args] = qargs->split('^\S*\zs')
	for cmd in cmds->split(',')
		const a = args
			->substitute($'<if-{cmd}>', '<if-*>', 'g')
			->substitute('<if-[^*>]\+>.\{-1,}\(<if-\*>\|$\)', '', 'g')
			->substitute('<if-\*>', '', 'g')
		execute cmd a
	endfor
enddef
command! -nargs=* MultiCmd MultiCmd(<q-args>)

# その他
command! -nargs=1 -complete=var Enable  <args> = 1
command! -nargs=1 -complete=var Disable <args> = 0

def RemoveEmptyLine(line: number)
	silent! execute ':' line 's/\s\+$//'
	silent! execute ':' line 's/^\s*\n//'
enddef

def BufIsSmth(): bool
	return &modified || ! empty(bufname())
enddef

def IndentStr(expr: any): string
	return matchstr(getline(expr), '^\s*')
enddef

# 指定幅以上なら'>'で省略する
def TruncToDisplayWidth(str: string, width: number): string
	return strdisplaywidth(str) <= width ? str : $'{str->matchstr($'.*\%<{width + 1}v')}>'
enddef

# MoveCursorは呼び出し回数が多いので、移動途中はユーザーイベントで300ミリ秒に1回だけ実行するようにする
const CM_DELAY_MSEC = 300
var cm_delay_timer = 0
var cm_delay_cueue = 0
def CursorMovedDelayExec(timer: any)
	cm_delay_timer = 0
	if cm_delay_cueue !=# 0
		cm_delay_cueue = 0
		doautocmd User CursorMovedDelay
	endif
enddef
def CursorMovedDelay()
	if cm_delay_timer !=# 0
		cm_delay_cueue += 1
		return
	endif
	# 最初の1回は即時実行する
	cm_delay_cueue = 0
	doautocmd User CursorMovedDelay
	cm_delay_timer = timer_start(CM_DELAY_MSEC, CursorMovedDelayExec)
enddef
au vimrc CursorMoved * CursorMovedDelay()

# <Cmd>でdefを実行したときのビジュアルモードの範囲(行)
def VFirstLast(): list<number>
	return mode() ==? 'V' ? sort([line('.'), line('v')]) : [line('.'), line('.')]
enddef
def VRange(): list<number>
	const a = VFirstLast()
	return range(a[0], a[1])
enddef

def GetVisualSelectionLines(): list<string>
	var v = getpos('v')[1 : 2]
	var c = getpos('.')[1 : 2]
	if c[0] < v[0]
		[v, c] = [c, v]
	endif
	var lines = getline(v[0], c[0])
	if mode() ==# 'V'
		# nop
	elseif mode() ==# 'v'
		lines[0] = lines[0][v[1] : ]
		lines[-1] = lines[-1][1 : c[1]]
	else
		var [s, e] = sort([c[1], v[1]])
		for i in range(0, len(lines) - 1)
			lines[i] = lines[i][s : e]
		endfor
	endif
	return lines
enddef

#}}} -------------------------------------------------------

# ----------------------------------------------------------
# プラグイン {{{

# jetpack {{{
const jetpackfile = expand( $'{rtproot}/pack/jetpack/opt/vim-jetpack/plugin/jetpack.vim')
const has_jetpack = filereadable(jetpackfile)
if ! has_jetpack
  const jetpackurl = 'https://raw.githubusercontent.com/tani/vim-jetpack/master/plugin/jetpack.vim'
  system($'curl -fsSLo {jetpackfile} --create-dirs {jetpackurl}')
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
Jetpack 'itchyny/calendar.vim'
Jetpack 'itchyny/vim-parenmatch'
Jetpack 'kana/vim-textobj-user'
Jetpack 'LeafCage/vimhelpgenerator'
Jetpack 'luochen1990/rainbow'    # 虹色括弧
Jetpack 'machakann/vim-sandwich'
Jetpack 'mattn/ctrlp-matchfuzzy'
Jetpack 'mattn/vim-notification'
Jetpack 'matze/vim-move'         # 行移動
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
Jetpack 'tpope/vim-fugitive'      # Gdiffとか
Jetpack 'tyru/caw.vim'            # コメント化
Jetpack 'yami-beta/asyncomplete-omni.vim'
Jetpack 'yegappan/mru'
Jetpack 'vim-jp/vital.vim'
Jetpack 'utubo/jumpcuorsor.vim'   # vimに対応させたやつ(様子見)vim-jetpackだとインストール出来ないかも？
Jetpack 'utubo/vim-colorscheme-girly'
Jetpack 'utubo/vim-minviml'
Jetpack 'utubo/vim-cmdheight0'
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
Enable  g:EasyMotion_smartcase
Enable  g:EasyMotion_use_migemo
Enable  g:EasyMotion_enter_jump_first
Disable g:EasyMotion_verbose
Disable g:EasyMotion_do_mapping
g:EasyMotion_keys = 'asdghklqwertyuiopzxcvbnmfjASDGHKLQWERTYUIOPZXCVBNMFJ;'
g:EasyMotion_prompt = 'EasyMotion: '
noremap s <Plug>(easymotion-s)
#}}}

# sandwich {{{
g:sandwich#recipes = deepcopy(g:sandwich#default_recipes)
g:sandwich#recipes += [
	{ buns: ["\r", ''  ], input: ["\r"], command: ["normal! a\r"] },
	{ buns: ['',   ''  ], input: ['q'] },
	{ buns: ['「', '」'], input: ['k'] },
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
MultiCmd nnoremap,xnoremap Sd <Plug>(operator-sandwich-delete)<if-nnoremap>ab
MultiCmd nnoremap,xnoremap Sr <Plug>(operator-sandwich-replace)<if-nnoremap>ab
MultiCmd nnoremap,xnoremap S  <Plug>(operator-sandwich-add)<if-nnoremap>iw
nmap <expr> SS (matchstr(getline('.'), '[''"]', col('.')) ==# '"') ? 'Sr''' : 'Sr"'

# 改行で挟んだあとタブでインデントされると具合が悪くなるので…
def FixSandwichPos()
	var c = g:operator#sandwich#object.cursor
	if g:fix_sandwich_pos[1] !=# c.inner_head[1]
		c.inner_head[2] = getline(c.inner_head[1])->match('\S') + 1
		c.inner_tail[2] = getline(c.inner_tail[1])->match('$') + 1
	endif
enddef
au vimrc User OperatorSandwichAddPre g:fix_sandwich_pos = getpos('.')
au vimrc User OperatorSandwichAddPost FixSandwichPos()

# 内側に連続で挟むやつ
var big_mac_crown = []
def BigMac(first: bool = true)
	const c = first ? [] : g:operator#sandwich#object.cursor.inner_head[1 : 2]
	if first || big_mac_crown !=# c
		big_mac_crown = c
		au vimrc User OperatorSandwichAddPost ++once BigMac(false)
		if first
			feedkeys('S')
		else
			setpos("'<", g:operator#sandwich#object.cursor.inner_head)
			setpos("'>", g:operator#sandwich#object.cursor.inner_tail)
			feedkeys('gvS')
		endif
	endif
enddef
nmap Sm viwSm
vnoremap Sm <ScriptCmd>BigMac()<CR>

# 囲みを削除したら行末空白と空行も削除
def RemoveAirBuns()
	const c = g:operator#sandwich#object.cursor
	RemoveEmptyLine(c.tail[1])
	RemoveEmptyLine(c.head[1])
enddef
au vimrc User OperatorSandwichDeletePost RemoveAirBuns()
#}}}

# MRU {{{
# デフォルト設定(括弧内にフルパス)だとパスに括弧が含まれているファイルが開けないので、パスに使用されない">"を区切りにする
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
	echoh Question
	echo $'[1]..[9] => open with a {use_tab ? 'tab' : 'window'}.'
	echoh None
	const key = use_tab ? 't' : '<CR>'
	for i in range(1, 9)
		execute $'nmap <buffer> <silent> {i} :<C-u>{i}<CR>{key}'
	endfor
enddef
def MyMRU()
	Enable b:auto_cursorline_disabled
	setlocal cursorline
	nnoremap <buffer> w <ScriptCmd>MRUwithNumKey(!b:use_tab)<CR>
	nnoremap <buffer> R <Cmd>MruRefresh<CR><Cmd>MRU<CR>
	nnoremap <buffer> <Esc> <Cmd>q!<CR>
	MRUwithNumKey(BufIsSmth())
enddef
au vimrc FileType mru MyMRU()
au vimrc ColorScheme * hi link MruFileName Directory
nnoremap <F2> <Cmd>MRUToggle<CR>
g:MRU_Exclude_Files = has('win32') ? $'{$TEMP}\\.*' : '^/tmp/.*\|^/var/tmp/.*'
#}}}

# 補完 {{{
def RegisterAsyncompSource(name: string, white: list<string>, black: list<string>)
	execute printf("asyncomplete#register_source(asyncomplete#sources#%s#get_source_options({ name: '%s', whitelist: %s, blacklist: %s, completor: asyncomplete#sources#%s#completor }))", name, name, white, black, name)
enddef
RegisterAsyncompSource('omni', ['*'], ['c', 'cpp', 'html'])
RegisterAsyncompSource('buffer', ['*'], ['go'])
MultiCmd inoremap,snoremap <expr> JJ      vsnip#expandable() ? '<Plug>(vsnip-expand)' : 'JJ'
MultiCmd inoremap,snoremap <expr> <C-l>   vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
MultiCmd inoremap,snoremap <expr> <Tab>   vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)' : pumvisible() ? '<C-n>' : '<Tab>'
MultiCmd inoremap,snoremap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : pumvisible() ? '<C-p>' : '<S-Tab>'
#inoremap <expr> <CR> pumvisible() ? '<C-y>' : '<CR>'
Enable g:lexima_accept_pum_with_enter
#}}}

# ALE {{{
Enable  g:ale_set_quickfix
Enable  g:ale_fix_on_save
Disable g:ale_lint_on_insert_leave
Disable g:ale_set_loclist
g:ale_sign_error = '🐞'
g:ale_sign_warning = '🐝'
g:ale_linters = { javascript: ['eslint'] }
g:ale_fixers = { typescript: ['deno'] }
g:ale_lint_delay = &updatetime
nnoremap <silent> [a <Plug>(ale_previous_wrap)
nnoremap <silent> ]a <Plug>(ale_next_wrap)

# cmdheight=0だとALEのホバーメッセージがちらつくのでg:ll_aleに代入してlightlineで表示する
g:ale_echo_cursor = 0
#}}}

# cmdheight0 {{{
# ヤンクしたやつを表示するやつ
g:ruler_reg = ''
def LLYankPost()
	var reg = v:event.regcontents
		->join('↵')
		->substitute('\t', '›', 'g')
		->TruncToDisplayWidth(20)
	g:ruler_reg = $'📋:{reg}'
enddef
au vimrc TextYankPost * LLYankPost()

# 毎時vim起動後45分から15分間休憩しようね
g:ruler_worktime = '🕛'
g:ruler_worktime_open_at = get(g:, 'ruler_worktime_open_at', localtime()) # .vimrcを再実行しても(1行目のnoclearで)持ち越し
def! g:VimrcTimer60s(timer: any)
	const hhmm = (localtime() - g:ruler_worktime_open_at) / 60
	const mm = hhmm % 60
	#:ruler_worktime = '🕛🕐🕑🕒🕓🕔🕕🕖🕗🕘🕙🕚'[mm / 5]
	g:ruler_worktime = '🕛🕐🕑🕒🕓🕔🕕🕖🕗🍰🍰🍰'[mm / 5]
	if (mm ==# 45)
		notification#show("       ☕🍴🍰\nHave a break time !")
	endif
enddef
timer_stop(get(g:, 'vimrc_timer_60s', 0))
g:vimrc_timer_60s = timer_start(60000, 'VimrcTimer60s', { repeat: -1 })

# markdownのチェックボックスの数をカウント
g:ruler_mdcb = ''
def CountCheckBoxs(): string
	var [firstline, lastline] = VFirstLast()
	if mode() ==? 'V'
		# OK
	elseif &ft !=# 'markdown'
		return ''
	else
		const indent = indent(firstline)
		for l in range(firstline + 1, line('$'))
			if indent(l) <= indent
				break
			endif
			lastline = l
		endfor
	endif
	# 念のためmax99行
	const MAX_LINES = 99 - 1
	var andmore = ''
	if firstline + MAX_LINES < lastline
		andmore = '+'
		lastline = firstline + MAX_LINES
	endif
	if firstline > lastline # TODO: なんで？
		return ''
	endif
	var chkd = 0
	var empty = 0
	for l in range(firstline, lastline)
		const line = getline(l)
		if line->match('^\s*- \[x\]') !=# -1
			chkd += 1
		elseif line->match('^\s*- \[ \]') !=# -1
			empty += 1
		endif
	endfor
	if chkd ==# 0 && empty ==# 0
		return ''
	else
		return  $'[x]:{chkd}/{chkd + empty}{andmore}'
	endif
enddef

def CountCheckBoxsDelay()
	if mode()[0] !=# 'n'
		return
	endif
	const count = CountCheckBoxs()
	if count !=# g:ruler_mdcb
		g:ruler_mdcb = count
		# silent! cmdheight0#Invalidate()
	endif
enddef

au vimrc User CursorMovedDelay CountCheckBoxsDelay()

# &ff
if has('win32')
	def RulerFF(): string
		return &ff !=# 'dos' ? $' {&ff}' : ''
	enddef
else
	def RulerFF(): string
		return &ff ==# 'dos' ? $' {&ff}' : ''
	enddef
endif

def! g:RulerBufInfo(): string
	if winwidth(winnr()) < 60
		return ''
	else
		var info = &fenc ==# 'utf-8' ? '' : &fenc
		info ..= RulerFF()
		return info
	endif
enddef

# cmdheight0設定
g:cmdheight0 = get(g:, 'cmdheight0', {})
g:cmdheight0.delay = -1
g:cmdheight0.tail = "\ue0c6"
g:cmdheight0.sep  = "\ue0c6"
g:cmdheight0.sub  = [" \ue0b5", "\ue0b7 "]
g:cmdheight0.horiz = "─"
g:cmdheight0.format = '%t %m%r%|%=%|%{ruler_reg|}%{ruler_mdcb|}%3l:%-2c:%L%|%{RulerBufInfo()|}%{ruler_worktime} '
g:cmdheight0.laststatus = 0
nnoremap ZZ <ScriptCmd>cmdheight0#ToggleZen()<CR>
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

# textobj-multiblock  {{{
MultiCmd onoremap,xnoremap ab <Plug>(textobj-multiblock-a)
MultiCmd onoremap,xnoremap ib <Plug>(textobj-multiblock-i)
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
#}}}

# ヘルプ作成 {{{
g:vimhelpgenerator_version = ''
g:vimhelpgenerator_author = 'Author  : utubo'
g:vimhelpgenerator_defaultlanguage = 'en'
#}}}

# カレンダー {{{
g:calendar_first_day = 'sunday'
def MyCalender()
	nnoremap <buffer> k <Plug>(calendar_up)
	nnoremap <buffer> j <Plug>(calendar_down)
	nnoremap <buffer> h <Plug>(calendar_prev)
	nnoremap <buffer> l <Plug>(calendar_next)
	nnoremap <buffer> gh <Plug>(calendar_left)
	nnoremap <buffer> gl <Plug>(calendar_right)
	nmap <buffer> <CR> >
	nmap <buffer> <BS> <
enddef
au vimrc FileType calendar MyCalender()
# }}}

# cmdline statusline 切り替え {{{
MultiCmd nnoremap,xnoremap / <Cmd>noh<CR>/
MultiCmd nnoremap,xnoremap ? <Cmd>noh<CR>?
MultiCmd nmap,vmap ; :
nnoremap <Space>; ;
nnoremap <Space>: :
# 自作プラグイン(vim-registerslite)と被ってしまった…
# inoremap <C-r>= <C-o><C-r>=
#}}}

# その他 {{{
Enable g:rainbow_active
g:loaded_matchparen = 1
g:auto_cursorline_wait_ms = &updatetime
g:ctrlp_match_func = {'match': 'ctrlp_matchfuzzy#matcher'}
g:ctrlp_cmd = 'CtrlPMixed'
nnoremap [c <Plug>(GitGutterPrevHunk)
nnoremap ]c <Plug>(GitGutterNextHunk)
nmap <Space>ga :<C-u>Git add %
nmap <Space>gc :<C-u>Git commit -m ''<Left>
nmap <Space>gp :<C-u>Git push
nnoremap <Space>gv <Cmd>Gvdiffsplit<CR>
nnoremap <Space>gd <Cmd>Gdiffsplit<CR>
nnoremap <Space>gl <Cmd>Git pull<CR>
nnoremap <Space>t <ScriptCmd>tabpopupmenu#popup()<CR>
nnoremap <Space>T <ScriptCmd>tablist#Show()<CR>
MultiCmd nnoremap,xnoremap <Space>c <Plug>(caw:hatpos:toggle)
MultiCmd nnoremap,tnoremap <silent> <C-w><C-s> <Plug>(shrink-height)<C-w>w
MultiCmd nnoremap,tnoremap <silent> <C-w><C-h> <Plug>(shrink-width)<C-w>w
# EasyMotionとどっちを使うか様子見中
noremap <Space>s <Plug>(jumpcursor-jump)
#}}}

# 開発用 {{{
const localplugins = expand($'{rtproot}/pack/local/opt/*')
if localplugins !=# ''
	&runtimepath = $'{substitute(localplugins, '\n', ',', 'g')},{&runtimepath}'
endif
def DevColorScheme()
	if expand('%:p') !~# '/colors/'
		return
	endif
	nnoremap <buffer> <expr> ZX $"<Cmd>update<CR><Cmd>colorscheme {expand('%:r')}<CR>"
	nnoremap <buffer> <expr> ZB $"<Cmd>set background={&background ==# 'dark' ? 'light' : 'dark'}<CR>"
enddef
au vimrc FileType vim DevColorScheme()
#}}}

filetype plugin indent on
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# コピペ寄せ集め色々 {{{
au vimrc InsertLeave * set nopaste
au vimrc BufReadPost *.log* normal! G
xnoremap * "vy/\V<C-r>=substitute(escape(@v,'\/'),"\n",'\\n','g')<CR><CR>
inoremap kj <Esc>`^
inoremap kk <Esc>`^
inoremap <CR> <CR><C-g>u
# https://github.com/astrorobot110/myvimrc/blob/master/vimrc
set matchpairs+=（:）,「:」,『:』,【:】,［:］,＜:＞
# https://github.com/Omochice/dotfiles
nnoremap <expr> i !empty(getline('.')) ? 'i' : '"_cc'
nnoremap <expr> a !empty(getline('.')) ? 'a' : '"_cc'
nnoremap <expr> A !empty(getline('.')) ? 'A' : '"_cc'
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
		path = expand('%:e') ==# '' ? '*' : ($'*.{expand('%:e')}')
	endif
	# 適宜タブで開く(ただし明示的に「%」を指定したらカレントで開く)
	const use_tab = BufIsSmth() && path !=# '%'
	if use_tab
		tabnew
	endif
	# lvimgrepしてなんやかんやして終わり
	execute $'silent! lvimgrep {keyword} {path}'
	if ! empty(getloclist(0))
		lwindow
	else
		echoh ErrorMsg
		echomsg $'Not found.: {keyword}'
		echoh None
		if use_tab
			tabnext -
			tabclose +
		endif
	endif
enddef
command! -nargs=+ VimGrep VimGrep(<f-args>)
nmap <Space>/ :<C-u>VimGrep<Space>

def SetupQF()
	nnoremap <buffer> <silent> ; <CR>:silent! normal! zv<CR><C-W>w
	nnoremap <buffer> <silent> w <C-W><CR>:silent! normal! zv<CR><C-W>w
	nnoremap <buffer> <silent> t <C-W><CR>:silent! normal! zv<CR><C-W>T
	nnoremap <buffer> <nowait> q <Cmd>lexpr ''<CR>:q<CR>
	nnoremap <buffer> f <C-f>
	nnoremap <buffer> b <C-b>
	# 様子見中(使わなそうなら削除する)
	execute $'nnoremap <buffer> T <C-W><CR><C-W>T{tabpagenr()}gt'
enddef
au vimrc FileType qf SetupQF()
au vimrc WinEnter * if winnr('$') ==# 1 && &buftype ==# 'quickfix' | q | endif
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# diff {{{
set splitright
set fillchars+=diff:\ # 削除行は空白文字で埋める
# diffモードを自動でoff https://hail2u.net/blog/software/vim-turn-off-diff-mode-automatically.html
au vimrc WinEnter * if (winnr('$') ==# 1) && !!getbufvar(winbufnr(0), '&diff') | diffoff | endif
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# 日付関係 {{{
g:reformatdate_extend_names = [{
	a: ['日', '月', '火', '水', '木', '金', '土'],
	A: ['日曜日', '月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日'],
}]
g:reformatdate_extend_formats = ['%m/%d(%a)']
reformatdate#init()
inoremap <expr> <F5> strftime('%Y/%m/%d')
cnoremap <expr> <F5> strftime('%Y%m%d')
nnoremap <F5> <ScriptCmd>reformatdate#reformat(localtime())<CR>
nnoremap <C-a> <ScriptCmd>reformatdate#inc(v:count)<CR>
nnoremap <C-x> <ScriptCmd>reformatdate#dec(v:count)<CR>
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
nnoremap <expr> <Space>f $'{(getreg('"') =~ '^\d\+$' ? ':' : '/')}{getreg('"')}<CR>'
# スマホだと:と/とファンクションキーが遠いので…
nmap <Space>. :
nmap <Space>, /
for i in range(1, 10)
	execute $'nmap <Space>{i % 10} <F{i}>'
endfor
nmap <Space><Space>1 <F11>
nmap <Space><Space>2 <F12>
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# カーソルを行頭に沿わせて移動 {{{
def PutHat(): string
	const x = getline('.')->match('\S') + 1
	if x !=# 0 || !exists('w:my_hat')
		w:my_hat = col('.') ==# x ? '^' : ''
	endif
	return w:my_hat
enddef
nnoremap <expr> j $'j{<SID>PutHat()}'
nnoremap <expr> k $'k{<SID>PutHat()}'
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# 折り畳み {{{
# こんなかんじでインデントに合わせて表示📁 {{{
def! g:MyFoldText(): string
	const src = getline(v:foldstart)
	const indent = repeat(' ', indent(v:foldstart))
	const text = &foldmethod ==# 'indent' ? '' : src->substitute(matchstr(&foldmarker, '^[^,]*'), '', '')->trim()
	return $'{indent}{text} 📁'
enddef
set foldtext=g:MyFoldText()
set fillchars+=fold:\ # 折り畳み時の「-」は半角空白
au vimrc ColorScheme * hi! link Folded Delimiter
au vimrc ColorScheme * hi! link ALEVirtualTextWarning ALEWarningSign
au vimrc ColorScheme * hi! link ALEVirtualTextError ALEErrorSign
#}}}
# ホールドマーカーの前にスペース、後ろに改行を入れる {{{
def Zf()
	var [firstline, lastline] = VFirstLast()
	execute ':' firstline 's/\v(\S)?$/\1 /'
	append(lastline, IndentStr(firstline))
	cursor([firstline, 1])
	cursor([lastline + 1, 1])
	normal! zf
enddef
xnoremap zf <ScriptCmd>Zf()<CR>
#}}}
# ホールドマーカーを削除したら行末をトリムする {{{
def Zd()
	if foldclosed(line('.')) ==# -1
		normal! zc
	endif
	const head = foldclosed(line('.'))
	const tail = foldclosedend(line('.'))
	if head ==# -1
		return
	endif
	const org = getpos('.')
	normal! zd
	RemoveEmptyLine(tail)
	RemoveEmptyLine(head)
	setpos('.', org)
enddef
nnoremap zd <ScriptCmd>Zd()<CR>
#}}}
# その他折りたたみ関係 {{{
set foldmethod=marker
au vimrc FileType markdown,yaml setlocal foldlevelstart=99 foldmethod=indent
au vimrc BufReadPost * :silent! normal! zO
nnoremap <expr> h (col('.') ==# 1 && 0 < foldlevel('.') ? 'zc' : 'h')
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
xnoremap u <ScriptCmd>KeepingCurPos('undo')<CR>
xnoremap <Space>u u
xnoremap <C-R> <ScriptCmd>KeepingCurPos('redo')<CR>
xnoremap <Tab> <Cmd>normal! >gv<CR>
xnoremap <S-Tab> <Cmd>normal! <gv<CR>
#}}}

# ----------------------------------------------------------
# コマンドモードあれこれ {{{
cnoremap <C-h> <Left>
cnoremap <C-l> <Right>
cnoremap <C-j> <Down>
cnoremap <C-k> <Up>
cnoremap <expr> <C-r><C-r> trim(@")->substitute('\n', ' \| ', 'g')
cnoremap <expr> <C-r><C-e> escape(@", '~^$.*?/\[]')->substitute('\n', '\\n', 'g')
cnoreabbrev cs colorscheme
# 「jj」で<CR>、「kk」はキャンセル
# ただし保存は片手で「;jj」でもOK(「;wjj」じゃなくていい)
cnoremap kk <C-c>
cnoremap <expr> jj (empty(getcmdline()) && getcmdtype() ==# ':' ? 'update<CR>' : '<CR>')
inoremap ;jj <Esc>`^<Cmd>update<CR>
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
	for l in VRange()
		const a = getline(l)
		var b = substitute(a, '^\(\s*\)- \[ \]', '\1- [x]', '') # check on
		if a ==# b
			b = substitute(a, '^\(\s*\)- \[x\]', '\1- [ ]', '') # check off
		endif
		if a ==# b
			b = substitute(a, '^\(\s*\)\(- \)*', '\1- [ ] ', '') # a new check box
		endif
		setline(l, b)
		if l ==# line('.')
			var c = getpos('.')
			c[2] += len(b) - len(a)
			setpos('.', c)
		endif
	endfor
enddef
noremap <Space>x <ScriptCmd>ToggleCheckBox()<CR>
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# バッファの情報を色付きで表示 {{{
def ShowBufInfo(event: string = '')
	if &ft ==# 'qf'
		return
	endif

	var isReadPost = event ==# 'BufReadPost'
	if isReadPost && !filereadable(expand('%'))
		# プラグインとかが一時的なbufnameを付与して開いた場合は無視する
		return
	endif

	var msg = []
	add(msg, ['Title', $'"{bufname()}"'])
	add(msg, ['Normal', ' '])
	if &modified
		add(msg, ['Delimiter', '[+]'])
		add(msg, ['Normal', ' '])
	endif
	if !isReadPost && !filereadable(expand('%'))
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
	add(msg, ['MoreMsg', $'{&ff} {empty(&fenc) ? &encoding : &fenc} {&ft}'])
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
enddef

# Zenモードで位置が分からなくなるのでPOPUPで現在位置を表示
def PopupCursorPos()
	popup_create($' {line(".")}:{col(".")} ', {
		pos: 'botleft',
		line: 'cursor-1',
		col: 'cursor',
		moved: 'any',
		padding: [1, 1, 1, 1],
	})
enddef

# TODO: ↓`call <SID>`を削ったら"not an editor command"になった要調査
nnoremap <C-g> <ScriptCmd>call <SID>ShowBufInfo()<CR><scriptCmd>call <SID>PopupCursorPos()<CR>
au vimrc BufNewFile,BufReadPost,BufWritePost * ShowBufInfo('BufNewFile')
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# 閉じる {{{
def Quit(expr: string = '')
	if !!expr
		if winnr() ==# winnr(expr)
			return
		endif
		execute 'wincmd' expr
	endif
	if mode() ==# 't'
		quit!
	else
		confirm quit
	endif
enddef
nnoremap q <Nop>
nnoremap Q q
nnoremap qh <ScriptCmd>Quit('h')<CR>
nnoremap qj <ScriptCmd>Quit('j')<CR>
nnoremap qk <ScriptCmd>Quit('k')<CR>
nnoremap ql <ScriptCmd>Quit('l')<CR>
nnoremap qq <ScriptCmd>Quit()<CR>
nnoremap q<CR> <ScriptCmd>Quit()<CR>
nnoremap qn <Cmd>confirm tabclose +<CR>
nnoremap qp <Cmd>confirm tabclose -<CR>
nnoremap q# <Cmd>confirm tabclose #<CR>
nnoremap qo <Cmd>confirm tabonly<CR>
nnoremap q: q:
nnoremap q/ q/
nnoremap q? q?
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# ファイルを移動して保存 {{{
def MoveFile(newname: string)
	const oldpath = expand('%')
	const newpath = expand(newname)
	if ! empty(oldpath) && filereadable(oldpath)
		if filereadable(newpath)
			echoh Error
			echo $'file "{newname}" already exists.'
			echoh None
			return
		endif
		rename(oldpath, newpath)
	endif
	execute 'saveas!' newpath
	# 開き直してMRUに登録
	edit
enddef
command! -nargs=1 -complete=file MoveFile MoveFile(<f-args>)
cnoreabbrev mv MoveFile
#}}}

# ----------------------------------------------------------
# vimrc作成用 {{{
# カーソル行を実行するやつ
cnoremap <expr> <SID>(exec_line) $'{getline('.')->substitute('^[ \t"#:]\+', '', '')}<CR>'
nmap g: :<C-u><SID>(exec_line)
nmap g9 :<C-u>vim9cmd <SID>(exec_line)
xnoremap g: "vy:<C-u><C-r>=@v<CR><CR>
xnoremap g9 "vy:<C-u>vim9cmd <C-r>=@v<CR><CR>
# カーソル位置のハイライトを確認するやつ
nnoremap <expr> <Space>gh $'<Cmd>hi {synID(line('.'), col('.'), 1)->synIDattr('name')->substitute('^$', 'Normal', '')}<CR>'
# 保存して実行 TODO: `g!`は微妙かな…
au vimrc FileType vim nnoremap g! <Cmd>update<CR><Cmd>source %<CR>
#}}}

# ----------------------------------------------------------
# その他細々したの {{{
if has('clipboard')
	au vimrc FocusGained * @" = @+
	au vimrc FocusLost   * @+ = @"
endif

def ToggleNumber()
	if &number
		set nonumber
	elseif &relativenumber
		set number norelativenumber
	else
		set relativenumber
	endif
enddef

nnoremap <F11> <ScriptCmd>ToggleNumber()<CR>
nnoremap <F12> <Cmd>set wrap!<CR>

cnoremap <expr> <SID>(rpl) $'s///g \| noh{repeat('<Left>', 9)}'
nmap gs :<C-u>%<SID>(rpl)
nmap gS :<C-u>%<SID>(rpl)<ScriptCmd>feedkeys(expand('<cword>')->escape('^$.*?/\[]'), 'ni')<CR><Right>
vmap gs :<SID>(rpl)

nnoremap Y y$
nnoremap <Space>p $p
nnoremap <Space>P ^P
nnoremap <Space><Space>p o<Esc>P
nnoremap <Space><Space>P O<Esc>p

# 分割キーボードで右手親指が<CR>になったので
nmap <CR> <Space>

# `T`多少潰しても大丈夫だろう…
nnoremap TE :<C-u>tabe<Space>
nnoremap TN <Cmd>tabnew<CR>
nnoremap TD <Cmd>tabe ./<CR>
nnoremap TT <Cmd>silent! tabnext #<CR>

onoremap <expr> } $"\<Esc>m`0{v:count1}{v:operator}\}"
onoremap <expr> { $"\<Esc>m`V{v:count1}\{{v:operator}"

xnoremap <expr> h mode() ==# 'V' ? '<Esc>h' : 'h'
xnoremap <expr> l mode() ==# 'V' ? '<Esc>l' : 'l'
xnoremap J j
xnoremap K k

inoremap ｋｊ <Esc>`^
inoremap 「 「」<Left>
inoremap 「」 「」<Left>
inoremap （ ()<Left>
inoremap （） ()<Left>
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# 様子見中 {{{
# 使わなそうなら削除する
xnoremap <expr> p $'"_s<C-R>{v:register}<ESC>'
xnoremap P p
nnoremap <Space>h ^
nnoremap <Space>l $
nnoremap <Space>d "_d
nnoremap <Space>n <Cmd>nohlsearch<CR>
au vimrc CursorHold * feedkeys(' n') # nohはauで動かない(:help noh)

# どっちも<C-w>w。左手オンリーと右手オンリーのマッピング
nnoremap <Space>w <C-w>w
nnoremap <Space>o <C-w>w

# CSVとかのヘッダを固定表示する。ファンクションキーじゃなくてコマンド定義すればいいかな…
nnoremap <silent> <F10> <ESC>1<C-w>s:1<CR><C-w>w
xnoremap <F10> <ESC>1<C-w>s<C-w>w

# US→「"」押しにくい、JIS→「'」押しにくい
# デフォルトのMはあまり使わないかなぁ…
nnoremap ' "
nnoremap m '
nnoremap M m

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
inoremap jjx <ScriptCmd>ToggleCheckBox()<CR>
# これはちょっと押しにくい(自分のキーボードだと)
inoremap <M-x> <ScriptCmd>ToggleCheckBox()<CR>
# 英単語は`q`のあとは必ず`u`だから`q`をプレフィックスにする手もありか？
# そもそも`q`が押しにくいか…
cnoremap qq <C-f>

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
# 「==#」とかの存在を忘れないように
au vimrc Syntax javascript,vim AddMySyntax('SpellRare', '\s[=!]=\s')
# 基本的にnormalは再マッピングさせないように「!」を付ける
au vimrc Syntax vim AddMySyntax('SpellRare', '\<normal!\@!')

# 自分で作ったのに使わなすぎるので啓発
textobj#user#map('twochars', {'-': {'select-a': 'aa', 'select-i': 'ii'}})

# 'itchyny/vim-cursorword'の簡易CursorHold版
def HiCursorWord()
	var cword = expand('<cword>')
	if cword !=# '' && cword !=# get(w:, 'cword_match', '')
		if exists('w:cword_match_id')
			matchdelete(w:cword_match_id)
			unlet w:cword_match_id
		endif
		if cword =~ "^[a-zA-Z0-9]"
			w:cword_match_id = matchadd('CWordMatch', cword)
			w:cword_match = cword
		endif
	endif
enddef
au vimrc CursorHold * HiCursorWord()
au vimrc ColorScheme * hi CWordMatch cterm=underline gui=underline

# 選択中の文字数をポップアップ
def PopupVisualLength()
	var text = GetVisualSelectionLines()->join('')
	popup_create($'{strlen(text)}chars', {
		pos: 'botleft',
		line: 'cursor-1',
		col: 'cursor',
		moved: 'any',
		padding: [1, 1, 1, 1],
	})
enddef
vnoremap <C-g> <ScriptCmd>PopupVisualLength()<CR>

#noremap <F1> <Cmd>smile<CR>
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# † あともう1回「これ使ってないな…」と思ったときに消す {{{

nnoremap <Space>a A

# sandwich
MultiCmd nnoremap,xnoremap Sa <Plug>(operator-sandwich-add)<if-nnoremap>iw
nmap S^ v^S
nmap S$ vg_S

# 最後の選択範囲を現在行の下に移動する
nnoremap <expr> <Space>m $'<Cmd>{getpos("'<")[1]},{getpos("'>")[1]}move {getpos('.')[1]}<CR>'

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
au vimrc ColorScheme * hi! link CmdHeight0Horiz TabLineFill
au vimrc ColorScheme * hi! link ALEVirtualTextWarning ALEStyleWarningSign
au vimrc ColorScheme * hi! link ALEVirtualTextError ALEStyleErrorSign

# 好みでハイライト
# vimrc再読み込みでクリア&再設定されないけど面倒だからヨシ
def MyMatches()
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
	# 全角空白と半角幅の円記号
	matchadd('SpellBad', '[　¥]')
	# 稀によくtypoする単語(気づいたら追加する)
	matchadd('SpellBad', 'stlye')
enddef
au vimrc VimEnter,WinEnter * MyMatches()

# 文末空白(&listが有効のときだけSpellBadで目立たせる)
def HiTail()
	if &list && !exists('w:hi_tail')
		w:hi_tail = matchadd('SpellBad', '\s\+$')
	elseif !&list && exists('w:hi_tail')
		# calendar.vim等で見づらくなるのでその対応
		matchdelete(w:hi_tail)
		unlet w:hi_tail
	endif
enddef
au vimrc OptionSet list silent! HiTail()
# matchaddはウィンドウ単位だが、`setlocal list`を考慮してBuf...イベントで実行する
au vimrc BufNew,BufReadPost * silent! HiTail()

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

if '~/.vimrc_local'->expand()->filereadable()
	source ~/.vimrc_local
endif

def OpenLastfile()
	var lastfile = get(v:oldfiles, 0, '')->expand()
	if lastfile->filereadable()
		execute 'edit' lastfile
	endif
enddef
au vimrc VimEnter * ++nested if !BufIsSmth() | OpenLastfile() | endif

