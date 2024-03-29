vim9script noclear
set encoding=utf-8
scriptencoding utf-8

# ------------------------------------------------------
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

# ------------------------------------------------------
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

def BufIsSmth(): bool
	return &modified || ! empty(bufname())
enddef

def g:IndentStr(expr: any): string
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
	if width <= 0
		return ''
	endif
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

# ------------------------------------------------------
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
Jetpack 'easymotion/vim-easymotion'
Jetpack 'hrsh7th/vim-vsnip'
Jetpack 'hrsh7th/vim-vsnip-integ'
Jetpack 'itchyny/calendar.vim'
Jetpack 'kana/vim-textobj-user'
Jetpack 'kana/vim-smartword'
Jetpack 'KentoOgata/vim-vimscript-gd'
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
Jetpack 'prabirshrestha/asyncomplete-buffer.vim'
Jetpack 'prabirshrestha/asyncomplete.vim'
Jetpack 'skanehira/gh.vim'
Jetpack 'thinca/vim-portal'
Jetpack 'thinca/vim-themis'
Jetpack 'tpope/vim-fugitive' # Gdiffとか
Jetpack 'tyru/capture.vim' # 実行結果をバッファにキャプチャ
Jetpack 'tyru/caw.vim' # コメント化
Jetpack 'yami-beta/asyncomplete-omni.vim'
Jetpack 'yegappan/lsp'
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
Jetpack 'utubo/vim-altkey-in-term'
Jetpack 'utubo/vim-colorscheme-girly'
Jetpack 'utubo/vim-colorscheme-softgreen'
Jetpack 'utubo/vim-hlpairs'
Jetpack 'utubo/vim-minviml'
Jetpack 'utubo/vim-cmdheight0'
Jetpack 'utubo/vim-registers-lite'
Jetpack 'utubo/vim-reformatdate'
Jetpack 'utubo/vim-skipslash'
Jetpack 'utubo/vim-yomigana'
Jetpack 'utubo/vim-vim9skk'
# 🐶🍚様子見中
Jetpack 'utubo/jumpcursor.vim'
Jetpack 'utubo/vim-ddgv'
Jetpack 'utubo/vim-portal-aim'
Jetpack 'utubo/vim-shrink'
Jetpack 'utubo/vim-tablist'
Jetpack 'utubo/vim-tabpopupmenu'
Jetpack 'utubo/vim-textobj-twochars'

if has_deno
	Jetpack 'vim-denops/denops.vim'
endif
jetpack#end()
if ! has_jetpack
	jetpack#sync()
endif
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
		b:stl_bufinfo = '%#Cmdheight0Warn#' .. info->join(',') .. '%#CmdHeight0#'
	endif
enddef
au vimrc BufNew,BufRead,OptionSet * UpdateStlBufInfo()

# カーソル以下のmarkdownのチェックボックスの数
# 本体は.vim/after/ftplugin/markdown.vim
w:ruler_mdcb = ''
au vimrc VimEnter,WinNew * w:ruler_mdcb = ''
au vimrc Colorscheme * {
	hi! link ChkCountIcon CmdHeight0Warn
	hi! link ChkCountIconOk CmdHeight0Info
}

# ヤンクしたやつを表示するやつ
g:stl_reg = ''
def UpdateStlRegister()
	var reg = v:event.regcontents
		->join('↵')
		->substitute('\t', '›', 'g')
		->TruncToDisplayWidth(20)
		->substitute('%', '%%', 'g')
	g:stl_reg = $'%#Cmdheight0Info#📋%#CmdHeight0#{reg}'
enddef
au vimrc TextYankPost * UpdateStlRegister()

# 毎時vim起動後45分から15分間休憩しようね
g:stl_worktime = '%#Cmdheight0Info#🕛'
g:stl_worktime_open_at = get(g:, 'ruler_worktime_open_at', localtime())
def! g:VimrcTimer60s(timer: any)
	const hhmm = (localtime() - g:stl_worktime_open_at) / 60
	const mm = hhmm % 60
	#:stl_worktime = '🕛🕐🕑🕒🕓🕔🕕🕖🕗🕘🕙🕚'[mm / 5]
	g:stl_worktime = '🕛🕐🕑🕒🕓🕔🕕🕖🕗🍰🍰🍰'[mm / 5]
	if mm ==# 45
		notification#show("       ☕🍴🍰\nHave a break time !")
	endif
	if g:stl_worktime ==# '🍰'
		g:stl_worktime = '%#Cmdheight0Warn#' .. g:stl_worktime
	else
		g:stl_worktime = '%#Cmdheight0Info#' .. g:stl_worktime
	endif
enddef
timer_stop(get(g:, 'vimrc_timer_60s', 0)) # .vimrc再実行を考慮してタイマーをストップ
g:vimrc_timer_60s = timer_start(60000, 'g:VimrcTimer60s', { repeat: -1 })

# cmdheight0設定
g:cmdheight0 = {}
g:cmdheight0.delay = -1
#g:cmdheight0.tail = "\ue0c6"
g:cmdheight0.tail = "\ue0b8"
g:cmdheight0.sep  = "\ue0b8"
#g:cmdheight0.sub  = ["\ue0b9", "\ue0bb"]
g:cmdheight0.sub = ' '
g:cmdheight0.statusline = ' ' .. # パディング
	'%{b:stl_icon}%t ' ..       # アイコンとファイル名
	'%#CmdHeight0Error#%m%*' .. # 編集済みか
	'%|%=%|' ..                 # 中央
	'%{%w:ruler_mdcb|%}' ..     # markdownのチェックボックスの数
	'%{%g:stl_reg|%}' ..        # レジスタ
	'%3l:%-2c:%L%|' ..          # カーソル位置
	'%{%b:stl_bufinfo|%}%*' ..  # 文字コードと改行コード
	'%{g:vim9skk_mode}%*' ..    # vim9skk
	' ' ..                      # パディング
	'%{%g:stl_worktime%}%*' ..  # 作業時間
	' '                         # パディング
g:cmdheight0.laststatus = 0
nnoremap ZZ <ScriptCmd>cmdheight0#ToggleZen()<CR>
au vimrc User Vim9skkModeChanged cmdheight0#Invalidate()

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
def GitAdd(args: string)
	const current_dir = getcwd()
	try
		chdir(expand('%:p:h'))
		echoh MoreMsg
		echo 'git add --dry-run ' .. args
		const list = system('git add --dry-run ' .. args)
		if !!v:shell_error
			echoh ErrorMsg
			echo list
			return
		endif
		if !list
			echo 'none.'
			return
		endif
		for item in split(list, '\n')
			execute 'echoh' (item =~# '^remove' ? 'DiffDelete' : 'DiffAdd')
			echo item
		endfor
		echoh Question
		if input('execute ? (y/n) > ', 'y') ==# 'y'
			system('git add ' .. args)
		endif
	finally
		echoh Normal
		chdir(current_dir)
	endtry
enddef
command! -nargs=* GitAdd GitAdd(<q-args>)
def! g:ConventionalCommits(a: any, l: string, p: number): list<string>
	return ['✨feat:', '🐞fix:', '📝docs:', '🔨refactor:', '🎨style:', '⏪revert:', '✅test:', '🔧chore:', '🎉release:']
enddef
command! -nargs=1 -complete=customlist,g:ConventionalCommits GitCommit Git commit -m <q-args>
def GitTagPush(tagname: string)
	echo system($"git tag '{tagname}'")
	echo system($"git push origin '{tagname}'")
enddef
command! -nargs=1 GitTagPush GitTagPush(<q-args>)
nnoremap <Space>ga <Cmd>GitAdd -A<CR>
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

# gh {{{
# ftpluginにすると定義がバラバラになって見通し悪くなるかな
au vimrc FileType gh-repos {
	nnoremap <buffer> i <ScriptCmd>execute 'edit!' ['gh:/', getline('.')->matchstr('\S\+'), 'issues']->join('/')<CR>
}
au vimrc FileType gh-issues {
	nnoremap <buffer> <CR> <ScriptCmd>execute 'new' [expand('%'), getline('.')->matchstr('[0-9]\+'), 'comments']->join('/')<CR>
	nnoremap <buffer> r <ScriptCmd>execute 'edit!' expand('%:h:h') .. '/repos'<CR>
}
au vimrc FileType gh-issue-comments {
	nnoremap <buffer> <CR> <ScriptCmd>execute 'bo vsplit' [expand('%'), getline('.')->matchstr('[0-9]\+')]->join('/')<CR><Cmd>setlocal wrap<CR>
}
nnoremap <Space>gh <Cmd>tabe gh://utubo/repos<CR>
# }}}

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

# LSP {{{
# minviml:fixed=lspOptions,lspServers
var lspOptions = {
	diagSignErrorText: '🐞',
	diagSignHintText: '💡',
	diagSignInfoText: '💠',
	diagSignWarningText: '🐝',
	showDiagWithVirtualText: true,
	diagVirtualTextAlign: 'after',
}
const commandExt = has('win32') ? '.cmd' : ''
var lspServers = [{
	name: 'typescriptlang',
	filetype: ['javascript', 'typescript'],
	path: $'typescript-language-server{commandExt}',
	args: ['--stdio'],
}, {
	name: 'vimlang',
	filetype: ['vim'],
	path: $'vim-language-server{commandExt}',
	args: ['--stdio'],
}, {
	name: 'htmllang',
	filetype: ['html'],
	path: $'html-languageserver{commandExt}',
	args: ['--stdio'],
}, {
	name: 'jsonlang',
	filetype: ['json'],
	path: $'vscode-json-languageserver{commandExt}',
	args: ['--stdio'],
}]
au vimrc VimEnter * call LspOptionsSet(lspOptions)
au vimrc VimEnter * call LspAddServer(lspServers)
nnoremap [l <Cmd>LspDiagPrev<CR>
nnoremap ]l <Cmd>LspDiagNext<CR>
#}}}

# MRU {{{
nnoremap <F2> <Cmd>MRUToggle<CR>
g:MRU_Exclude_Files = has('win32') ? $'{$TEMP}\\.*' : '^/tmp/.*\|^/var/tmp/.*'
# MRUに関してのその他の設定は.vim/after/ftplugin/mru.src.vimで指定している
#}}}

# Portal {{{
nnoremap <Leader>a <Cmd>PortalAim<CR>
nnoremap <Leader>b <Cmd>PortalAim blue<CR>
nnoremap <Leader>o <Cmd>PortalAim orange<CR>
nnoremap <Leader>r <Cmd>PortalReset<CR>
#}}}

# sandwich {{{
Enable g:sandwich_no_default_key_mappings
Enable g:operator_sandwich_no_default_key_mappings
CmdEach nmap,xmap S <ScriptCmd>vimrc#sandwich#ApplySettings('S')<CR>
#}}}

# vim9skk {{{
g:vim9skk = {
	keymap: {
		toggle: ['<C-j>', ';j'],
		midasi: [':', 'Q'],
	}
}
g:vim9skk_mode = '' # statuslineでエラーにならないように念の為設定しておく
nnoremap ;j i<Plug>(vim9skk-enable)
au vimrc User Vim9skkEnter g:asyncomplete_auto_popup = 0
au vimrc User Vim9skkLeave g:asyncomplete_auto_popup = 1
# 見出しモードでスタートする
au vimrc User Vim9skkEnter feedkeys('Q')
# AZIKライクな設定とか
au vimrc User Vim9skkInitPre vimrc#vim9skk#ApplySettings()
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
def SkipParen(): string
	const c = matchstr(getline('.'), '.', col('.') - 1)
	# 閉じ括弧の間にTAB文字を入れることはないだろう…
	if !c || stridx(')]}>"''`」', c) ==# -1
		return "\<Tab>"
	else
		return  "\<C-o>a"
	endif
enddef
CmdEach imap,smap <expr> <Tab> vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : pumvisible() ? '<C-n>' : SkipParen()
CmdEach imap,smap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : pumvisible() ? '<C-p>' : '<S-Tab>'
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
Each w,b,e,ge nnoremap {} <Plug>(smartword-{})
nnoremap [c <Plug>(GitGutterPrevHunk)
nnoremap ]c <Plug>(GitGutterNextHunk)
CmdEach nnoremap,xnoremap <Space>c <Plug>(caw:hatpos:toggle)
# 🐶🍚
g:skipslash_autocomplete = 1
g:loaded_matchparen = 1
g:loaded_matchit = 1
nnoremap % <ScriptCmd>hlpairs#Jump()<CR>
nnoremap ]% <ScriptCmd>hlpairs#Jump('f')<CR>
nnoremap [% <ScriptCmd>hlpairs#Jump('b')<CR>
onoremap a% <ScriptCmd>hlpairs#TextObj(true)<CR>
onoremap i% <ScriptCmd>hlpairs#TextObj(false)<CR>
nnoremap <Leader>% <ScriptCmd>hlpairs#HighlightOuter()<CR>
nnoremap <Space>% <ScriptCmd>hlpairs#ReturnCursor()<CR>
nnoremap <Space>t <ScriptCmd>tabpopupmenu#popup()<CR>
nnoremap <Space>T <ScriptCmd>tablist#Show()<CR>
CmdEach nnoremap,tnoremap <silent> <C-w><C-s> <Plug>(shrink-height)<C-w>w
CmdEach nnoremap,tnoremap <silent> <C-w><C-h> <Plug>(shrink-width)<C-w>w
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

# ------------------------------------------------------
# コピペ寄せ集め色々 {{{
au vimrc InsertLeave * set nopaste
au vimrc BufReadPost *.log* normal! G
xnoremap * "vy/\V<C-r>=substitute(escape(@v,'\/'),"\n",'\\n','g')<CR><CR>
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

# ------------------------------------------------------
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
	&shiftwidth = &tabstop
	&softtabstop = &tabstop
	setpos('.', org)
enddef
au vimrc BufReadPost * SetupTabstop()
#}}} -------------------------------------------------------

# ------------------------------------------------------
# vimgrep {{{
command! -nargs=+ -complete=dir VimGrep vimrc#myutil#VimGrep(<f-args>)
au vimrc WinEnter * if winnr('$') ==# 1 && &buftype ==# 'quickfix' | q | endif
#}}} -------------------------------------------------------

# ------------------------------------------------------
# diff {{{
set splitright
set fillchars+=diff:\ # 削除行は空白文字で埋める
# diffモードを自動でoff https://hail2u.net/blog/software/vim-turn-off-diff-mode-automatically.html
au vimrc WinEnter * if (winnr('$') ==# 1) && !!getbufvar(winbufnr(0), '&diff') | diffoff | endif
#}}} -------------------------------------------------------

# ------------------------------------------------------
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

# ------------------------------------------------------
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
# その他
nnoremap <Space>a A
nnoremap <Space>h ^
nnoremap <Space>l $
nnoremap <Space>y yiw
#}}} -------------------------------------------------------

# ------------------------------------------------------
# 折り畳み {{{
# こんなかんじでインデントに合わせて表示📁 {{{
def! g:MyFoldText(): string
	const src = getline(v:foldstart)
	const indent = repeat(' ', indent(v:foldstart))
	if &foldmethod ==# 'indent'
		return $'{indent}📁 {v:foldend - v:foldstart + 1}lines'
	else
		const text = src->substitute(matchstr(&foldmarker, '^[^,]*'), '', '')->trim()
		return $'{indent}{text} 📁'
	endif
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
xnoremap zf <ScriptCmd>vimrc#myutil#Zf()<CR>
nnoremap zd <ScriptCmd>vimrc#myutil#Zd()<CR>
nnoremap <silent> g; g;zO
#}}}
#}}} -------------------------------------------------------

# ------------------------------------------------------
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

# ------------------------------------------------------
# セミコロン {{{
# インサートモードでも使うプレフィックス
inoremap ;<CR> ;<CR>
inoremap ;<Esc> ;<Esc>
inoremap ;<Space> ;<Space>
inoremap ;; <Esc>`^
cnoremap ;; <C-c>
inoremap ;e <C-o>e<C-o>a
inoremap ;k 「」<C-g>U<Left>
inoremap ;l <C-g>R<Right>
inoremap ;u <C-o>u
nnoremap ;r <C-r>
nnoremap ;v V
CmdEach nnoremap,inoremap ;<Tab> <ScriptCmd>StayCurPos('normal! >>')<CR>
CmdEach nnoremap,inoremap ;<S-Tab> <ScriptCmd>StayCurPos('normal! <<')<CR>
CmdEach nnoremap,xnoremap ;; <Esc>
CmdEach nnoremap,inoremap ;n <Cmd>update<CR><Esc>
nnoremap <Space>; ;
# `;h`+`h`連打で<BS>
map! <script> <SID>bs_ <Nop>
map! <script> ;h <SID>bs_h
noremap! <script> <SID>bs_h <BS><SID>bs_
# }}}

# ------------------------------------------------------
# ビジュアルモードあれこれ {{{
xnoremap u <ScriptCmd>undo\|normal! gv<CR>
xnoremap <C-R> <ScriptCmd>redo\|normal! gv<CR>
xnoremap <Tab> <ScriptCmd>StayCurPos('normal! >gv')<CR>
xnoremap <S-Tab> <ScriptCmd>StayCurPos('normal! <gv')<CR>
const vmode = ['v', 'V', "\<C-v>", "\<ESC>"] # minviml:fixed=vmode
xnoremap <script> <expr> v vmode[vmode->index(mode()) + 1]
#}}}

# ------------------------------------------------------
# コマンドモードあれこれ {{{
CmdEach nnoremap,xnoremap / <Cmd>noh<CR>/
CmdEach nnoremap,xnoremap ? <Cmd>noh<CR>?
# 考え中
CmdEach nnoremap,xnoremap ;c :
CmdEach nnoremap,xnoremap ;s <Cmd>noh<CR>/
CmdEach nnoremap,xnoremap + :
CmdEach nnoremap,xnoremap , :
CmdEach nnoremap,xnoremap <Space><Space>, ,
# その他の設定
au vimrc CmdlineEnter * ++once vimrc#cmdline#ApplySettings()
#}}}

# ------------------------------------------------------
# terminalとか {{{
# `SH`で開く
if has('win32')
	command! Powershell :bo terminal ++close pwsh
	nnoremap SH <Cmd>Powershell<CR>
	nnoremap <S-F1> <Cmd>silent !start explorer %:p:h<CR>
else
	nnoremap SH <Cmd>bo terminal<CR>
endif
# `drop`コマンドでterminalからvimで開く
def g:Tapi_drop(bufnr: number, arglist: list<string>)
	 vimrc#terminal#Tapi_drop(bufnr, arglist)
enddef
# その他の設定
au vimrc TerminalOpen * ++once vimrc#terminal#ApplySettings()

#}}} -------------------------------------------------------

# ------------------------------------------------------
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

# ------------------------------------------------------
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

# ------------------------------------------------------
# vimrc、plugin、colorscheme作成用 {{{
# カーソル行を実行するやつ
cnoremap <script> <expr> <SID>(exec_line) $'{getline('.')->substitute('^[ \t"#:]\+', '', '')}<CR>'
nnoremap <script> g: :<C-u><SID>(exec_line)
nnoremap <script> g9 :<C-u>vim9cmd <SID>(exec_line)
xnoremap g: "vy:<C-u><C-r>=@v<CR><CR>
xnoremap g9 "vy:<C-u>vim9cmd <C-r>=@v<CR><CR>
# カーソル位置のハイライトを確認するやつ
nnoremap <expr> <Space>hl $'<Cmd>hi {synID(line('.'), col('.'), 1)->synIDattr('name')->substitute('^$', 'Normal', '')}<CR>'
# 他の定義は.vim/after/ftplugin/vim.vim
#}}}

# ------------------------------------------------------
# その他細々したの {{{
if has('clipboard')
	au vimrc FocusGained * @" = @+
	au vimrc FocusLost   * @+ = @"
endif

nnoremap <F11> <ScriptCmd>vimrc#myutil#ToggleNumber()<CR>
nnoremap <F12> <Cmd>set wrap!<CR>

nnoremap gs :<C-u>%s///g<Left><Left><Left>
nnoremap gS :<C-u>%s/<C-r>=escape(expand('<cword>'), '^$.*?/\[]')<CR>//g<Left><Left>
xnoremap gs :s///g<Left><Left><Left>
xnoremap gS "vy:<C-u>%s/<C-r>=substitute(escape(@v,'^$.*?/\[]'),"\n",'\\n','g')<CR>//g<Left><Left>

nnoremap <CR> j0
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
xnoremap <expr> p $'"_s<C-R>{v:register}<ESC>'
xnoremap P p

inoremap ｋｊ <Esc>`^
inoremap 「 「」<C-g>U<Left>
inoremap 「」 「」<C-g>U<Left>
inoremap （ ()<C-g>U<Left>
inoremap （） ()<C-g>U<Left>

# US配列→「"」押しにくい、JIS配列→「'」押しにくい
# デフォルトのMはあまり使わないかなぁ…
nnoremap ' "
nnoremap m '
nnoremap M m
#}}} -------------------------------------------------------

# ------------------------------------------------------
# 様子見中 使わなそうなら削除する {{{
nnoremap <Space><Tab>u <Cmd>call vimrc#recentlytabs#ReopenRecentlyTab()<CR>
nnoremap <Space><Tab>l <Cmd>call vimrc#recentlytabs#ShowMostRecentlyClosedTabs()<CR>
nnoremap <Space>n <Cmd>nohlsearch<CR>
au vimrc CursorHold * feedkeys(' n') # nohはauで動かない(:help noh)

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

# ここまで読(y)んだ
nnoremap <F9> my
nnoremap <S-F9> 'y

# syntax固有の追加強調 {{{
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
# やりがちなミスにハイライトを付ける
au vimrc Syntax javascript {
	AddMySyntax('SpellRare', '\s[=!]=\s')
}
au vimrc Syntax vim {
	AddMySyntax('SpellRare', '\s[=!]=\s')
	AddMySyntax('SpellBad', '\s[=!]==\s')
	AddMySyntax('SpellBad', '\s\~[=!][=#]\?\s')
	AddMySyntax('SpellRare', '\<normal!\@!')
}
#}}}

# yankした文字をポップアップ {{{
def PopupYankText()
	const text = ('📋 ' .. @"[0 : winwidth(0)])
		->substitute('\t', '›', 'g')
		->substitute('\n', '↵', 'g')
	const truncated = text->TruncToDisplayWidth(winwidth(0) - 10)
	const winid = popup_create(truncated, {
		line: 'cursor+1',
		col: 'cursor+1',
		pos: 'topleft',
		padding: [0, 1, 0, 1],
		fixed: true,
		moved: 'any',
		time: 2000,
	})
	win_execute(winid, 'syntax match PmenuExtra /[›↵]\|.\@<=>$/')
enddef
au vimrc TextYankPost * PopupYankText()
#}}}

# 選択中の文字数をポップアップ {{{
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
#}}}

# cmdlineでノーマルモードみたいにするやつ {{{
def CmdToNormal(): string
	cnoremap ;; <C-c>
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
	cnoremap <script> <expr> ;n CmdToNormal()
	return c ==# 'i' ? '' : "\<Right>"
enddef
au vimrc ModeChanged *:c CmdToInsert()
#}}}

# `:%g!/re/d` の結果を新規ウインドウに表示
# (Buffer Regular Expression Print)
command! -nargs=1 Brep vimrc#myutil#Brep(<q-args>, <q-mods>)

# <C-f>と<C-b>、CTRLおしっぱがつらいので…
Each f,b nmap <C-{}> <C-{}><SID>(hold-ctrl)
Each f,b nnoremap <script> <SID>(hold-ctrl){} <C-{}><SID>(hold-ctrl)
nmap <SID>(hold-ctrl) <Nop>

# 🐶🍚
CmdEach onoremap A <Plug>(textobj-twochars-a)
CmdEach onoremap I <Plug>(textobj-twochars-i)

#noremap <F1> <Cmd>smile<CR>
#}}} -------------------------------------------------------

# ------------------------------------------------------
# † あともう1回「これ使ってないな…」と思ったときに消す {{{

# 存在を忘れる
# どっちも<C-w>w。左手オンリーと右手オンリーのマッピング
nnoremap <Space>w <C-w>w
nnoremap <Space>o <C-w>w
nnoremap <Space><Space>p o<Esc>P
nnoremap <Space><Space>P O<Esc>p
nnoremap <Space>d "_d

#}}} -------------------------------------------------------

# ------------------------------------------------------
# デフォルトマッピングデー {{{
if strftime('%d') ==# '91'
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

# ------------------------------------------------------
# 色 {{{
nnoremap <expr> ZB $"<Cmd>set background={&background ==# 'dark' ? 'light' : 'dark'}<CR>"
au vimrc ColorSchemePre * {
	g:rcsv_colorpairs = [
		['105', '#9999ee'], ['117', '#99ccee'], ['120', '#99ee99'],
		['228', '#eeee99'], ['212', '#ee99cc'], ['177', '#cc99ee']
	]
}

def GetAttr(id: number, name: string): string
	const v = synIDattr(id, name)->matchstr(has('gui') ? '.*[^0-9].*' : '^[0-9]\+$')
	return !v ? 'NONE' : v
enddef

def GetHl(name: string): any
	const id = hlID(name)->synIDtrans()
	return { fg: GetAttr(id, 'fg'), bg: GetAttr(id, 'bg') }
enddef

def MyHighlight()
	hi! link CmdHeight0Horiz MoreMsg
	const x = has('gui') ? 'gui' : 'cterm'
	const signBg = GetHl('LineNr').bg
	execute $'hi LspDiagSignErrorText   {x}bg={signBg} {x}fg={GetHl("ErrorMsg").fg}'
	execute $'hi LspDiagSignHintText    {x}bg={signBg} {x}fg={GetHl("Question").fg}'
	execute $'hi LspDiagSignInfoText    {x}bg={signBg} {x}fg={GetHl("Pmenu").fg}'
	execute $'hi LspDiagSignWarningText {x}bg={signBg} {x}fg={GetHl("WarningMsg").fg}'
enddef

au vimrc VimEnter,ColorScheme * MyHighlight()

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

silent! syntax enable
set t_Co=256
set background=dark
silent! colorscheme girly
#}}} -------------------------------------------------------

# ------------------------------------------------------
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

# ------------------------------------------------------
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

