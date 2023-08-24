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
set wildcharm=<Tab>
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
# CmdEach nmap,xmap xxx yyy<if-nmap>NNN<if-xmap>VVV<endif>zzz
# ↓
# nmap xxx yyyNNNzzz | xmap xxx yyyVVVzzz
def CmdEach(qargs: string)
	const [cmds, args] = qargs->split('^\S*\zs')
	for cmd in cmds->split(',')
		const a = args
			->substitute($'<if-{cmd}>', '<endif>', 'g')
			->substitute('<if-[^>]\+>.\{-1,}\(<endif>\|$\)', '', 'g')
			->substitute('<endif>', '', 'g')
		execute cmd a
	endfor
enddef
command! -nargs=* CmdEach CmdEach(<q-args>)

# こんな感じ
# Each j,k nnoremap {} g{}
# ↓
# nnoremap j gj
# nnoremap k gk
# ※これ使うよりべたで書いたほうが起動は速い
# ※CmdEachを統合できそう
# ※やりすぎ感は否めない
# ※`{}`を全て置換してしまうのでこのコマンドは重ねられない
def Each(qargs: string)
	const [items, args] = qargs->split('^\S*\zs')
	for i in items->split(',')
		execute args->substitute('{}', i, 'g')
	endfor
enddef
command! -nargs=* Each Each(<q-args>)

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

def StayCurPos(expr: string)
	const len = getline('.')->len()
	var cur = getcurpos()
	execute expr
	cur[2] += getline('.')->len() - len
	setpos('.', cur)
enddef

# 指定幅以上なら'>'で省略する
def TruncToDisplayWidth(str: string, width: number): string
	return strdisplaywidth(str) <= width ? str : $'{str->matchstr($'.*\%<{width + 1}v')}>'
enddef

# <Cmd>でdefを実行したときのビジュアルモードの範囲(行)
def! g:VFirstLast(): list<number>
	return [line('.'), line('v')]->sort('n')
enddef

def! g:VRange(): list<number>
	const a = g:VFirstLast()
	return range(a[0], a[1])
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
Jetpack 'cohama/lexima.vim' # 括弧補完
Jetpack 'delphinus/vim-auto-cursorline'
Jetpack 'dense-analysis/ale'
Jetpack 'easymotion/vim-easymotion'
Jetpack 'hrsh7th/vim-vsnip'
Jetpack 'hrsh7th/vim-vsnip-integ'
Jetpack 'itchyny/calendar.vim'
Jetpack 'kana/vim-textobj-user'
Jetpack 'kana/vim-smartword'
Jetpack 'LeafCage/vimhelpgenerator'
Jetpack 'luochen1990/rainbow' # 虹色括弧
Jetpack 'machakann/vim-sandwich'
Jetpack 'mattn/vim-notification'
Jetpack 'matze/vim-move' # 行移動
Jetpack 'michaeljsmith/vim-indent-object'
Jetpack 'MTDL9/vim-log-highlighting'
Jetpack 'obcat/vim-hitspop'
Jetpack 'obcat/vim-sclow' # スクロールバー
Jetpack 'osyo-manga/vim-textobj-multiblock'
Jetpack 'othree/html5.vim'
Jetpack 'othree/yajs.vim'
Jetpack 'prabirshrestha/asyncomplete-buffer.vim'
Jetpack 'prabirshrestha/asyncomplete.vim'
Jetpack 'thinca/vim-portal'
Jetpack 'thinca/vim-themis'
Jetpack 'tpope/vim-fugitive' # Gdiffとか
Jetpack 'tyru/capture.vim' # 実行結果をバッファにキャプチャ
Jetpack 'tyru/caw.vim' # コメント化
Jetpack 'yami-beta/asyncomplete-omni.vim'
Jetpack 'yegappan/mru'
Jetpack 'yuki-yano/dedent-yank.vim' # yankするときにインデントを除去
Jetpack 'vim-jp/vital.vim'
# Fern
Jetpack 'lambdalisue/fern.vim'
Jetpack 'lambdalisue/fern-git-status.vim'
Jetpack 'lambdalisue/fern-renderer-nerdfont.vim'
Jetpack 'lambdalisue/fern-hijack.vim'
Jetpack 'lambdalisue/nerdfont.vim'
# 👀様子見中
Jetpack 'ctrlpvim/ctrlp.vim'
Jetpack 'mattn/ctrlp-matchfuzzy'
Jetpack 'sheerun/vim-polyglot' # いろんなシンタックスハイライト
Jetpack 'tani/vim-typo'
# 🐶🍚
Jetpack 'utubo/vim-colorscheme-girly'
Jetpack 'utubo/vim-hlpairs'
Jetpack 'utubo/vim-minviml'
Jetpack 'utubo/vim-cmdheight0'
Jetpack 'utubo/vim-registers-lite'
Jetpack 'utubo/vim-reformatdate'
Jetpack 'utubo/vim-tabtoslash'
Jetpack 'utubo/vim-yomigana'
# 🐶🍚様子見中
Jetpack 'utubo/jumpcursor.vim'
Jetpack 'utubo/vim-portal-aim'
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

# ALE {{{
Enable  g:ale_fix_on_save
Enable  g:ale_set_quickfix
Disable g:ale_echo_cursor
Disable g:ale_lint_on_insert_leave
Disable g:ale_set_loclist
g:ale_sign_error = '🐞'
g:ale_sign_warning = '🐝'
g:ale_linters = { javascript: ['eslint'] }
g:ale_fixers = { typescript: ['deno'] }
g:ale_lint_delay = &updatetime
nnoremap <silent> [a <Plug>(ale_previous_wrap)
nnoremap <silent> ]a <Plug>(ale_next_wrap)
#}}}

# cmdheight0, statusline {{{
# アイコン
au vimrc WinNew,FileType * b:stl_icon = nerdfont#find()

# 文字コードと改行コード
b:stl_bufinfo = ''
def UpdateStlBufInfo()
	var info = []
	if &fenc !=# 'utf-8' && !!&fenc
		info += [&fenc->toupper()]
	endif
	# なんか `&ff !=# ...` を括弧でくくらないとType mismatchになる…
	if &ff !=# '' && (has('win32') && (&ff !=# 'dos') || !has('win32') && (&ff !=# 'unix'))
		info += [&ff ==# 'dos' ? 'CRLF' : &ff ==# 'unix' ? 'LF' : 'CR']
	endif
	if !info
		b:stl_bufinfo = ''
	else
		b:stl_bufinfo = '%#Cmdheight0Warn#' .. info->join(',') .. '%*'
	endif
enddef
au vimrc BufNew,BufRead,OptionSet * UpdateStlBufInfo()

# カーソル以下のmarkdownのチェックボックスの数
# 本体は.vim/after/ftplugin/markdown.vim
w:ruler_mdcb = ''
au vimrc VimEnter,WinNew * w:ruler_mdcb = ''

# ヤンクしたやつを表示するやつ
g:stl_reg = ''
def UpdateStlRegister()
	var reg = v:event.regcontents
		->join('↵')
		->substitute('\t', '›', 'g')
		->TruncToDisplayWidth(20)
		->substitute('%', '%%', 'g')
	g:stl_reg = $'📋%#Cmdheight0Info#{reg}%*'
enddef
au vimrc TextYankPost * UpdateStlRegister()

# 毎時vim起動後45分から15分間休憩しようね
g:stl_worktime = '🕛'
g:stl_worktime_open_at = get(g:, 'ruler_worktime_open_at', localtime())
def! g:VimrcTimer60s(timer: any)
	const hhmm = (localtime() - g:stl_worktime_open_at) / 60
	const mm = hhmm % 60
	#:stl_worktime = '🕛🕐🕑🕒🕓🕔🕕🕖🕗🕘🕙🕚'[mm / 5]
	g:stl_worktime = '🕛🕐🕑🕒🕓🕔🕕🕖🕗🍰🍰🍰'[mm / 5]
	if (mm ==# 45)
		notification#show("       ☕🍴🍰\nHave a break time !")
	endif
	if g:stl_worktime ==# '🍰'
		g:stl_worktime = '%#Cmdheight0Warn#' .. g:stl_worktime .. '%*'
	endif
enddef
timer_stop(get(g:, 'vimrc_timer_60s', 0)) # .vimrc再実行を考慮してタイマーをストップ
g:vimrc_timer_60s = timer_start(60000, 'VimrcTimer60s', { repeat: -1 })

# cmdheight0設定
g:cmdheight0 = {}
g:cmdheight0.delay = -1
g:cmdheight0.tail = "\ue0c6"
g:cmdheight0.sep  = "\ue0c6"
g:cmdheight0.sub  = ["\ue0b9", "\ue0bb"]
g:cmdheight0.horiznr = '─'
g:cmdheight0.format = ' ' ..   # パディング
	'%{b:stl_icon}%t' ..        # アイコンとファイル名
	'%#CmdHeight0Error#%m%*' .. # 編集済みか
	'%|%=%|' ..                 # 中央
	'%{w:ruler_mdcb|}' ..       # markdownのチェックボックスの数
	'%{%g:stl_reg|%}' ..        # レジスタ
	'%3l:%-2c:%L%|' ..          # カーソル位置
	'%{%b:stl_bufinfo|%}' ..    # 文字コードと改行コード
	'%{%g:stl_worktime%}' ..    # 作業時間
	' '                         # パディング
g:cmdheight0.laststatus = 0
nnoremap ZZ <ScriptCmd>cmdheight0#ToggleZen()<CR>

# Zenモードでterminalだけになると混乱するので
au vimrc WinEnter * {
	if winnr('$') ==# 1 && tabpagenr('$') ==# 1 && &buftype ==# 'terminal'
		cmdheight0#ToggleZen(0)
	endif
}
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

# fern {{{
Enable g:fern#default_hidden
g:fern#renderer = "nerdfont"
au vimrc FileType fern {
	Enable b:auto_cursorline_disabled
	setlocal cursorline
	nnoremap <buffer> <F1> <Cmd>:q!<CR>
	nnoremap <buffer> p <Plug>(fern-action-leave)
}
nnoremap <F1> <Cmd>Fern . -reveal=% -opener=split<CR>
#}}}

# Git {{{
def GitAddAll()
	echoh MoreMsg
	echo 'git add -A -n'
	const list = system('git add -A -n')
	if !list
		echo 'none.'
	elseif !!v:shell_error
		echoh ErrorMsg
		echo list
		echoh Normal
		return
	else
		echoh DiffAdd
		echo list
		echoh Question
		if input("execute ? (y/n) > ", 'y') ==# 'y'
			system("git add -A")
		endif
	endif
	echoh Normal
enddef
def! g:ConventionalCommits(a: any, l: string, p: number): list<string>
	return ['✨feat:', '🐞fix:', '📝docs:', '🔨refactor:', '🎨style:', '✅test:', '🔧chore', '🎉release:']
enddef
command! -nargs=1 -complete=customlist,g:ConventionalCommits GitCommit Git commit -m <q-args>
def GitTagPush(tagname: string)
	echo system($"git tag '{tagname}'")
	echo system($"git push origin '{tagname}'")
enddef
command! -nargs=1 GitTagPush GitTagPush(<q-args>)
nnoremap <Space>ga <ScriptCmd>GitAddAll()<CR>
nnoremap <Space>gA :<C-u>Git add %
nnoremap <Space>gc :<C-u>GitCommit<Space><Tab>
nnoremap <Space>gp :<C-u>Git push
nnoremap <Space>gs <Cmd>Git status -sb<CR>
nnoremap <Space>gv <Cmd>Gvdiffsplit<CR>
nnoremap <Space>gd <Cmd>Gdiffsplit<CR>
nnoremap <Space>gl <Cmd>Git pull<CR>
nnoremap <Space>gt :<C-u>GitTagPush<Space>
nnoremap <Space>gC :<C-u>Git checkout %
#}}}

# lexima {{{
Enable g:lexima_accept_pum_with_enter
# 正規表現の括弧 `\(\)`と`\{\}`
def g:SetupLexima(timer: number)
	lexima#add_rule({ char: '(', at: '\\\%#', input_after: '\)', mode: 'ic' })
	lexima#add_rule({ char: '{', at: '\\\%#', input_after: '\}', mode: 'ic' })
	lexima#add_rule({ char: ')', at: '\%#\\)', leave: 2, mode: 'ic' })
	lexima#add_rule({ char: '}', at: '\%#\\}', leave: 2, mode: 'ic' })
	lexima#add_rule({ char: '\', at: '\%#\\[)}]', leave: 1, mode: 'ic' })
	# cmdlineでの括弧
	au vimrc ModeChanged *:c* ++once {
		for pair in ['()', '{}', '""', "''", '``']
			lexima#add_rule({ char: pair[0], input_after: pair[1], mode: 'c' })
			lexima#add_rule({ char: pair[1], at: '\%#' .. pair[1], leave: 1, mode: 'c' })
		endfor
		# `I'm`を入力できるようにするルール
		lexima#add_rule({ char: "'", at: '[a-zA-Z]\%#''\@!', mode: 'c' })
	}
enddef
timer_start(1000, g:SetupLexima)
# }}}

# MRU {{{
nnoremap <F2> <Cmd>MRUToggle<CR>
g:MRU_Exclude_Files = has('win32') ? $'{$TEMP}\\.*' : '^/tmp/.*\|^/var/tmp/.*'
#}}}

# Portal {{{
nnoremap <Leader>a <Cmd>PortalAim<CR>
nnoremap <Leader>b <Cmd>PortalAim blue<CR>
nnoremap <Leader>o <Cmd>PortalAim orange<CR>
nnoremap <Leader>r <Cmd>PortalReset<CR>
#}}}

# sandwich {{{
g:sandwich#recipes = deepcopy(g:sandwich#default_recipes)
g:sandwich#recipes += [
	{ buns: ["\r", ''  ], input: ["\r"], command: ["normal! a\r"] },
	{ buns: ['',   ''  ], input: ['q'] },
	{ buns: ['「', '」'], input: ['k'] },
	{ buns: ['【', '】'], input: ['K'] },
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
CmdEach nmap,xmap Sd <Plug>(operator-sandwich-delete)<if-nmap>ab
CmdEach nmap,xmap Sr <Plug>(operator-sandwich-replace)<if-nmap>ab
CmdEach nnoremap,xnoremap S <Plug>(operator-sandwich-add)<if-nnoremap>iw
nmap <expr> Srr (matchstr(getline('.'), '[''"]', col('.')) ==# '"') ? "Sr'" : 'Sr"'
# `S${`と被ってしまうけどまぁいいか
nmap S$ vg_S
# 微調整
au vimrc User OperatorSandwichAddPre g:fix_sandwich_pos = getpos('.')
au vimrc User OperatorSandwichAddPost myutil#FixSandwichPos()
au vimrc User OperatorSandwichDeletePost myutil#RemoveAirBuns()
# 内側に連続で挟むやつ
xnoremap Sm <ScriptCmd>myutil#BigMac()<CR>
nmap Sm viwSm
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

# textobj-user {{{
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
#}}}

# 補完 {{{
CmdEach inoremap,snoremap <expr> JJ    vsnip#expandable() ? '<Plug>(vsnip-expand)' : 'JJ'
CmdEach inoremap,snoremap <expr> <C-l> vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
def RegisterAsyncompSource(name: string, white: list<string>, black: list<string>)
	execute printf("asyncomplete#register_source(asyncomplete#sources#%s#get_source_options({ name: '%s', whitelist: %s, blacklist: %s, completor: asyncomplete#sources#%s#completor }))", name, name, white, black, name)
enddef
RegisterAsyncompSource('omni', ['*'], ['c', 'cpp', 'html'])
RegisterAsyncompSource('buffer', ['*'], ['go'])
#}}}

# その他 {{{
Enable g:rainbow_active
Enable  g:ctrlp_use_caching
Disable g:ctrlp_clear_cache_on_exit
g:ctrlp_match_func = {'match': 'ctrlp_matchfuzzy#matcher'}
g:ctrlp_cmd = 'CtrlPMixed'
g:auto_cursorline_wait_ms = &updatetime
g:hlairs = { delay: 250 }
g:loaded_matchparen = 1
au vimrc VimEnter * silent! NoMatchParen
Each w,b,e,ge nnoremap {} <Plug>(smartword-{})
nnoremap % <ScriptCmd>call hlpairs#Jump()<CR>
nnoremap [c <Plug>(GitGutterPrevHunk)
nnoremap ]c <Plug>(GitGutterNextHunk)
nnoremap <Space>t <ScriptCmd>tabpopupmenu#popup()<CR>
nnoremap <Space>T <ScriptCmd>tablist#Show()<CR>
CmdEach nnoremap,xnoremap <Space>c <Plug>(caw:hatpos:toggle)
CmdEach nnoremap,tnoremap <silent> <C-w><C-s> <Plug>(shrink-height)<C-w>w
CmdEach nnoremap,tnoremap <silent> <C-w><C-h> <Plug>(shrink-width)<C-w>w
# EasyMotionとどっちを使うか様子見中
noremap <Space>s <Plug>(jumpcursor-jump)
#}}}

# 開発用 {{{
const localplugins = expand($'{rtproot}/pack/local/opt/*')
if localplugins !=# ''
	&runtimepath = $'{substitute(localplugins, '\n', ',', 'g')},{&runtimepath}'
endif
g:vimhelpgenerator_version = ''
g:vimhelpgenerator_author = 'Author  : utubo'
g:vimhelpgenerator_defaultlanguage = 'en'
g:vimhelpgenerator_uri = 'https://github.com/utubo/'
#}}}

filetype plugin indent on
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# コピペ寄せ集め色々 {{{
au vimrc InsertLeave * set nopaste
au vimrc BufReadPost *.log* normal! G
xnoremap * "vy/\V<C-r>=substitute(escape(@v,'\/'),"\n",'\\n','g')<CR><CR>
inoremap jk <Esc>`^
inoremap <CR> <CR><C-g>u
# https://github.com/astrorobot110/myvimrc/blob/master/vimrc
set matchpairs+=（:）,「:」,『:』,【:】,［:］,＜:＞
# https://github.com/Omochice/dotfiles
Each i,a,A nnoremap <expr> {} !empty(getline('.')) ? '{}' : '"_cc'
# すごい
# https://zenn.dev/mattn/articles/83c2d4c7645faa
Each +,-,>,< CmdEach nmap,tmap <C-w>{} <C-w>{}<SID>ws
Each +,-,>,< CmdEach nnoremap,tnoremap <script> <SID>ws{} <C-w>{}<SID>ws
CmdEach nmap,tmap <SID>ws <Nop>
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
command! -nargs=+ -complete=dir VimGrep myutil#VimGrep(<f-args>)
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
# スタックトレースからyankしてソースの該当箇所を探すのを補助
nnoremap <Space>e G?\cErr\\|Exception<CR>
nnoremap <expr> <Space>f $'{(getreg('"') =~ '^\d\+$' ? ':' : '/')}{getreg('"')}<CR>'
# スマホだと:と/とファンクションキーが遠いので…
nmap <Space>. :
nmap <Space>, /
nmap g<Space> g;
for i in range(1, 10)
	execute $'nmap <Space>{i % 10} <F{i}>'
endfor
nmap <Space><Space>1 <F11>
nmap <Space><Space>2 <F12>
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
au vimrc ColorScheme * {
	hi! link Folded Delimiter
	hi! link ALEVirtualTextWarning ALEWarningSign
	hi! link ALEVirtualTextError ALEErrorSign
}
#}}}
# その他折りたたみ関係 {{{
set foldmethod=marker
au vimrc FileType markdown,yaml setlocal foldlevelstart=99 foldmethod=indent
au vimrc BufReadPost * :silent! normal! zO
nnoremap <expr> h (col('.') ==# 1 && 0 < foldlevel('.') ? 'zc' : 'h')
nnoremap Z<Tab> <Cmd>set foldmethod=indent<CR>
nnoremap Z{ <Cmd>set foldmethod=marker<CR>
nnoremap Zy <Cmd>set foldmethod=syntax<CR>
xnoremap zf <ScriptCmd>myutil#Zf()<CR>
nnoremap zd <ScriptCmd>myutil#Zd()<CR>
#}}}
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# Tabline {{{
# 例: `current.txt|✏sub.txt|🐙>`(3つめ以降は省略)
g:tabline_mod_sign = "\uf040" # 鉛筆アイコン(Cicaの絵文字だと半角幅になってしまう)
g:tabline_git_sign = '🐙'
g:tabline_dir_sign = '📂'
g:tabline_term_sign = "\uf489" # `>_`みたいなアイコン
g:tabline_labelsep = '|'
g:tabline_maxlen = 20

def MyTablabelSign(bufs: list<number>, overflow: bool = false): string
	var mod = ''
	var git = ''
	for b in bufs
		const bt = getbufvar(b, '&buftype')
		if bt ==# ''
			if !mod && getbufvar(b, '&modified')
				mod = g:tabline_mod_sign
			endif
			if !git
				var g = false
				silent! g = len(getbufvar(b, 'gitgutter', {'hunks': []}).hunks) !=# 0
				if g
					git = g:tabline_git_sign
				endif
			endif
		endif
		if overflow
			continue
		endif
		if bt ==# 'terminal'
			return g:tabline_term_sign
		endif
		const ft = getbufvar(b, '&filetype')
		if ft ==# 'netrw' || ft ==# 'fern'
			return g:tabline_dir_sign
		endif
	endfor
	return mod .. git
enddef

def! g:MyTablabel(tab: number = 0): string
	var label = ''
	var bufs = tabpagebuflist(tab)
	const win = tabpagewinnr(tab) - 1
	bufs = remove(bufs, win, win) + bufs
	var names = []
	var i = -1
	for b in bufs
		i += 1
		if len(names) ==# 2
			names += [(MyTablabelSign(bufs[i : ], true) .. '>')]
			break
		endif
		var name = bufname(b)
		if !name
			name = '[No Name]'
		elseif getbufvar(b, '&buftype') ==# 'terminal'
			name = term_getline(b, '.')->trim()
		endif
		name = name->pathshorten()
		if g:tabline_maxlen < len(name)
			name = '<' .. name->matchstr(repeat('.', g:tabline_maxlen - 1) .. '$')
		endif
		if names->index(name) ==# -1
			names += [MyTablabelSign([b]) .. name]
		endif
	endfor
	label ..= names->join(g:tabline_labelsep)
	return label
enddef

def! g:MyTabline(): string
	# 左端をバッファの表示に合わせる(ずれてるとなんか気持ち悪いので)
	var line = '%#TabLineFill#'
	line ..= repeat(' ', getwininfo(win_getid(1))[0].textoff)
	# タブ一覧
	const curtab = tabpagenr()
	for tab in range(1, tabpagenr('$'))
		line ..= tab ==# curtab ? '%#TabLineSel#' : '%#TabLine#'
		line ..= ' '
		line ..= g:MyTablabel(tab)
		line ..= ' '
	endfor
	line ..= '%#TabLineFill#%T'
	return line
enddef

set tabline=%!g:MyTabline()
set guitablabel=%{g:MyTablabel()}
#}}}

# ----------------------------------------------------------
# ビジュアルモードあれこれ {{{
xnoremap u <ScriptCmd>undo\|normal! gv<CR>
xnoremap <C-R> <ScriptCmd>redo\|normal! gv<CR>
xnoremap <Tab> <ScriptCmd>StayCurPos('normal! >gv')<CR>
xnoremap <S-Tab> <ScriptCmd>StayCurPos('normal! <gv')<CR>
#}}}

# ----------------------------------------------------------
# コマンドモードあれこれ {{{
CmdEach nnoremap,xnoremap / <Cmd>noh<CR>/
CmdEach nnoremap,xnoremap ? <Cmd>noh<CR>?
CmdEach nmap,xmap ; :
nnoremap <Space>; ;
nnoremap <Space>: :
cnoremap <C-h> <Left>
cnoremap <C-l> <Right>
cnoremap <C-n> <Down>
cnoremap <C-p> <Up>
cnoremap <expr> <C-r><C-r> trim(@")->substitute('\n', ' \| ', 'g')
cnoremap <expr> <C-r><C-e> escape(@", '~^$.*?/\[]')->substitute('\n', '\\n', 'g')
cnoreabbrev cs colorscheme
# 「jj」で<CR>
# ただし保存は片手で「;jj」でもOK(「;wjj」じゃなくていい)
cnoremap <expr> jj (empty(getcmdline()) && getcmdtype() ==# ':' ? 'update<CR>' : '<CR>')
inoremap ;jj <Esc>`^<Cmd>update<CR>
# `/`を補完 {{{
def CmdlineAutoPair(c: string): string
	if getcmdtype() !=# ':'
		return c
	endif
	const cl = getcmdline()
	if getcmdpos() !=# cl->len() + 1 || cl =~# '\s'
		return c
	endif
	const e = cl[-1]
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
# `/`以外も使うかも`%s#foo/bar#buz#g`みたいなかんじ
Each /,#,! cnoremap <script> <expr> {} CmdlineAutoPair('{}')
#}}}
#}}}

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
	add(msg, ['MoreMsg', &ff])
	add(msg, ['Normal', ' '])
	const enc = empty(&fenc) ? &encoding : &fenc
	add(msg, [enc ==# 'utf-8' ? 'MoreMsg' : 'WarningMsg', enc])
	add(msg, ['Normal', ' '])
	add(msg, ['MoreMsg', &ft])
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
			insert(msg, ['SpecialKey', '<'], 0)
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
		col: 'cursor+1',
		moved: 'any',
		padding: [1, 1, 1, 1],
	})
enddef

nnoremap <script> <C-g> <ScriptCmd>ShowBufInfo()<CR><scriptCmd>PopupCursorPos()<CR>
au vimrc BufNewFile,BufReadPost,BufWritePost * ShowBufInfo('BufNewFile')
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# 閉じる {{{
def QuitWin(expr: string)
	if winnr() ==# winnr(expr)
		return
	endif
	execute 'wincmd' expr
	if mode() ==# 't'
		quit!
	else
		confirm quit
	endif
enddef
Each h,j,k,l nnoremap q{} <ScriptCmd>QuitWin('{}')<CR>
nnoremap q <Nop>
nnoremap Q q
nnoremap qq <Cmd>confirm q<CR>
nnoremap qa <Cmd>confirm qa<CR>
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
command! -nargs=1 -complete=file MoveFile myutil#MoveFile(<f-args>)
cnoreabbrev mv MoveFile
#}}}

# ----------------------------------------------------------
# vimrc、plugin、colorscheme作成用 {{{
# カーソル行を実行するやつ
cnoremap <script> <expr> <SID>(exec_line) $'{getline('.')->substitute('^[ \t"#:]\+', '', '')}<CR>'
nnoremap <script> g: :<C-u><SID>(exec_line)
nnoremap <script> g9 :<C-u>vim9cmd <SID>(exec_line)
xnoremap g: "vy:<C-u><C-r>=@v<CR><CR>
xnoremap g9 "vy:<C-u>vim9cmd <C-r>=@v<CR><CR>
# カーソル位置のハイライトを確認するやつ
nnoremap <expr> <Space>gh $'<Cmd>hi {synID(line('.'), col('.'), 1)->synIDattr('name')->substitute('^$', 'Normal', '')}<CR>'
# 他の定義は.vim/after/ftplugin/vim.vim
#}}}

# ----------------------------------------------------------
# その他細々したの {{{
if has('clipboard')
	au vimrc FocusGained * @" = @+
	au vimrc FocusLost   * @+ = @"
endif

nnoremap <F11> <ScriptCmd>myutil#ToggleNumber()<CR>
nnoremap <F12> <Cmd>set wrap!<CR>

nnoremap gs :<C-u>%s///g<Left><Left><Left>
nnoremap gS :<C-u>%s/<C-r>=escape(expand('<cword>'), '^$.*?/\[]')<CR>//g<Left><Left>
xnoremap gs :s///g<Left><Left><Left>
xnoremap gS "vy:<C-u>%s/<C-r>=substitute(escape(@v,'^$.*?/\[]'),"\n",'\\n','g')<CR>//g<Left><Left>

nnoremap Y y$
nnoremap <Space>p $p
nnoremap <Space>P ^P
nnoremap <expr> j (getline('.')->match('\S') + 1 ==# col('.')) ? '+' : 'j'
nnoremap <expr> k (getline('.')->match('\S') + 1 ==# col('.')) ? '-' : 'k'

# `T`多少潰しても大丈夫だろう…
nnoremap TE :<C-u>tabe<Space>
nnoremap TN <Cmd>tabnew<CR>
nnoremap TD <Cmd>tabe ./<CR>
nnoremap TT <Cmd>tabnext #<CR>

onoremap <expr> } $"\<Esc>m`0{v:count1}{v:operator}\}"
onoremap <expr> { $"\<Esc>m`V{v:count1}\{{v:operator}"

xnoremap <expr> h mode() ==# 'V' ? '<Esc>h' : 'h'
xnoremap <expr> l mode() ==# 'V' ? '<Esc>l' : 'l'
xnoremap J j
xnoremap K k

inoremap ｋｊ <Esc>`^
inoremap 「 「」<C-g>U<Left>
inoremap 「」 「」<C-g>U<Left>
inoremap （ ()<C-g>U<Left>
inoremap （） ()<C-g>U<Left>
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# 様子見中 {{{
# 使わなそうなら削除する
nnoremap <Space>a A
xnoremap <expr> p $'"_s<C-R>{v:register}<ESC>'
xnoremap P p
nnoremap <Space>h ^
nnoremap <Space>l $
nnoremap <Space>n <Cmd>nohlsearch<CR>
au vimrc CursorHold * feedkeys(' n') # nohはauで動かない(:help noh)

# 移動した後折り畳みを展開
nnoremap <silent> g; g;zO

# 辞書ファイル書くときに便利だけどもしかして<CR>ってプレフィックスになりえる？
nnoremap <CR> j0

# ↓キーボードの設定で<CR>を<Space>に切り替えられるようにしたのでもう不要かな…
## 分割キーボードで右手親指が<CR>になったので
#nmap <CR> <Space>

# <Tab>でインデント
#nnoremap <Tab> <ScriptCmd>StayCurPos('normal! >>')<CR>
#nnoremap <S-Tab> <ScriptCmd>StayCurPos('normal! <<')<CR>

# <Tab>でtsvとかcsvとかhtmlの次の項目
nnoremap <Tab> <Cmd>call search('\(^\\|\t\\|, *\)\S\?', 'e')<CR>
nnoremap <S-Tab> <Cmd>call search('\(^\\|\t\\|, *\)\S\?', 'be')<CR>
au vimrc FileType html,xml,svg {
	nnoremap <buffer> <silent> <Tab> <Cmd>call search('>')<CR><Cmd>call search('\S')<CR>
	nnoremap <buffer> <silent> <S-Tab> <Cmd>call search('>', 'b')<CR><Cmd>call search('>', 'b')<CR><Cmd>call search('\S')<CR>
}

# CSVとかのヘッダを固定表示する。ファンクションキーじゃなくてコマンド定義すればいいかな…
nnoremap <silent> <F10> <ESC>1<C-w>s:1<CR><C-w>w
xnoremap <F10> <ESC>1<C-w>s<C-w>w

# US→「"」押しにくい、JIS→「'」押しにくい
# デフォルトのMはあまり使わないかなぁ…
nnoremap ' "
nnoremap m '
nnoremap M m

# ここまで読んだ
nnoremap <F9> my
nnoremap <S-F9> 'y

# 悪くないけどノーマルモードでjjを誤爆する
inoremap jj <C-o>
inoremap jje <C-o>e<C-o>a
inoremap jj; <C-o>$;<CR>
inoremap jj<Space> <C-o>$<CR>
inoremap jjk 「」<C-g>U<Left>
inoremap jj<Tab> <ScriptCmd>StayCurPos('normal! >>')<CR>
inoremap jj<S-Tab> <ScriptCmd>StayCurPos('normal! <<')<CR>
# これはちょっと押しにくい(自分のキーボードだと)
inoremap <M-x> <ScriptCmd>ToggleCheckBox()<CR>
# 英単語は`q`のあとは必ず`u`だから`q`をプレフィックスにする手もありか？
# そもそも`q`が押しにくいか…
cnoremap qj <Down>
cnoremap qk <Up>

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

# 選択中の文字数をポップアップ
def PopupVisualLength()
	normal! "vy
	var text = @v->substitute('\n', '', 'g')
	popup_create($'{strlen(text)}chars', {
		pos: 'botleft',
		line: 'cursor-1',
		col: 'cursor+1',
		moved: 'any',
		padding: [1, 1, 1, 1],
	})
enddef
xnoremap <C-g> <ScriptCmd>PopupVisualLength()<CR>

# これは誤爆しそう…例えば`all`とか`call`とか
def SkipParen(): string
	const c = matchstr(getline('.'), '.', col('.') - 1)
	if !c || stridx(')]}"''`」', c) ==# -1
		return 'll'
	endif
	# 誤爆防止
	const a = matchstr(getline('.'), '.', col('.') - 2)
	if stridx('ae', a) !=# -1
		return 'll'
	endif
	return  "\<C-o>a"
enddef
inoremap <expr> ll SkipParen()

# `:%g!/re/d` の結果を新規ウインドウに表示
# (Buffer Regular Expression Print)
command! -nargs=1 Brep myutil#Brep(<q-args>, <q-mods>)

# cmdlineでノーマルモードみたいにするやつ
def CmdToNormal(): string
	cnoremap jk <C-c>
	cnoremap h <Left>
	cnoremap l <Right>
	cnoremap b <S-Left>
	cnoremap w <S-Right>
	cnoremap $ <End><Left>
	cnoremap ^ <Home>
	cnoremap x <Delete>
	cnoremap <script> <expr> i CmdToInsert('i')
	cnoremap <script> <expr> a CmdToInsert('a')
	cmap A $a
	return ""
enddef
def CmdToInsert(c: string = 'i'): string
	Each h,l,b,w,^,$,x,i,a,A silent! cunmap {}
	cnoremap <script> <expr> jk CmdToNormal()
	return c ==# 'i' ? '' : "\<Right>"
enddef
au vimrc ModeChanged *:c CmdToInsert()
# ↓これは無しにしてみる
#cnoremap jk <C-c>

# もしかしてcmdwinを1行にすれば同じような使い心地になるかも？
set cmdwinheight=1
def ExpandCmdwin()
	if winheight(0) ==# 1
		resize 7
		normal! ggG
	else
		normal! k
	endif
enddef
au vimrc CmdwinEnter * {
	nnoremap <buffer> k <ScriptCmd>ExpandCmdwin()<CR>
	normal! i
}

#noremap <F1> <Cmd>smile<CR>
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# † あともう1回「これ使ってないな…」と思ったときに消す {{{

# 存在を忘れる
# どっちも<C-w>w。左手オンリーと右手オンリーのマッピング
nnoremap <Space>w <C-w>w
nnoremap <Space>o <C-w>w
nnoremap <Space><Space>p o<Esc>P
nnoremap <Space><Space>P O<Esc>p
nnoremap <Space>d "_d

# 使用頻度が低いうえにストロークの差が1つしかない(スマホで使うかも？)
nnoremap <Space>y yiw

# sandwich
nmap S^ v^S

#}}} -------------------------------------------------------

# ----------------------------------------------------------
# デフォルトマッピングデー {{{
if strftime('%d') ==# '01'
	au vimrc VimEnter * {
		notification#show("✨ Today, Let's enjoy the default key mapping ! ✨")
		mapclear
		imapclear
		xmapclear
		cmapclear
		omapclear
		tmapclear
		# CursorHoldでfeedkyesしているので…
		nnoremap <Space>n <Nop>
	}
endif
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# 色 {{{
nnoremap <expr> ZB $"<Cmd>set background={&background ==# 'dark' ? 'light' : 'dark'}<CR>"
def DefaultColors()
	# (メモ)autocmdの{}は行末が`,`だとエラーになる
	g:rcsv_colorpairs = [
		['105', '#9999ee'], ['117', '#99ccee'], ['120', '#99ee99'],
		['228', '#eeee99'], ['212', '#ee99cc'], ['177', '#cc99ee']
	]
enddef
au vimrc ColorSchemePre * DefaultColors()
au vimrc ColorScheme * {
	hi! link CmdHeight0Horiz TabLineFill
	hi! link ALEVirtualTextWarning ALEStyleWarningSign
	hi! link ALEVirtualTextError ALEStyleErrorSign
	hi! link CmdHeight0Horiz MoreMsg
}

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
# 終わりに {{{
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
#}}}

# ----------------------------------------------------------
# メモ {{{
# <F1> fern <S-F1>でフォルダを開く(win32)
# <F2> MRU
# <F3>
# <F4>
# <F5> 日付関係
# <F6>
# <F7>
# <F8>
# <F9> ここまでよんだ
# <F10> ヘッダ行を表示(あんまり使わない)
# <F11> 行番号表示切替
# <F12> 折り返し表示切替
#}}} -------------------------------------------------------

