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
set fillchars=vert:\|
set cursorline
set hidden
set showtabline=0
set cmdheight=1
set noshowcmd
set noshowmode
set wildmenu
set wildcharm=<Tab>
set display=lastline
set ambiwidth=double
set belloff=all
set ttimeoutlen=50
set autochdir
set backupskip=/var/tmp/*
set undodir=~/.vim/undo
set undofile
set updatetime=2000
set incsearch
set hlsearch
set autocomplete
set shortmess+=FI # 後で:introする
set noruler
g:maplocalleader = ';'

filetype plugin indent on

augroup vimrc
	# 新しい自由
	au!
augroup END
# }}}

# ------------------------------------------------------
# 自作マネージャ {{{
g:ezpack_home = expand($'{&pp->split(',')[0]}/pack/ezpack')
if !isdirectory(g:ezpack_home)
	system($'git clone https://github.com/utubo/vim-ezpack.git {g:ezpack_home}/opt/vim-ezpack')
	vimrc#ezpack#Install()
endif
command! EzpackInstall vimrc#ezpack#Install()
command! EzpackCleanUp vimrc#ezpack#CleanUp()
# }}}

# ------------------------------------------------------
# 折り畳み {{{
def! g:MyFoldText(): string
	const icon = "\uf196"
	const indent = repeat(' ', indent(v:foldstart))
	if &foldmethod ==# 'syntax'
		# こんなかんじ
		# ああああ⊞
		const text = getline(v:foldstart)->trim()
		return $'{indent}{text}{icon}'
	endif
	if &foldmethod ==# 'marker'
		# syntaxと同じfoldmarkerは削除
		const text = getline(v:foldstart)
			->substitute(matchstr(&foldmarker, '^[^,]*'), '', '')
			->trim()
		return $'{indent}{text}{icon}'
	endif
	# こんなかんじ
	# ⊞lines 3
	const text = $'{indent}{icon}{v:foldend - v:foldstart + 1}lines'
	if &ft !=# 'markdown'
		return text
	endif
	# こんなかんじでマークダウンのチェックボックスの数を表示
	# ⊞lines 3 [1/3]
	var checkbox = matchbufline(bufnr(), '^\s*- \[[ x*]]', v:foldstart, v:foldend)
	const total = checkbox->len()
	if total ==# 0
		return text
	endif
	const checked = checkbox
		->filter((index, value) => value.text[-2 : -2] !=# ' ')
		->len()
	return $'{text} [{checked}/{total}]'
enddef
set foldtext=g:MyFoldText()
set fillchars+=fold:\ # 折り畳み時の「-」は半角空白

# その他折りたたみ関係 {{{
au vimrc ColorScheme * {
	hi! link Folded Delimiter
	hi! link ALEVirtualTextWarning ALEWarningSign
	hi! link ALEVirtualTextError ALEErrorSign
}
set foldmethod=syntax
au vimrc FileType markdown,yaml setlocal foldlevelstart=99 foldmethod=indent
au vimrc FileType vim setlocal foldmethod=marker
nnoremap <expr> h (col('.') ==# 1 && 0 < foldlevel('.') ? 'zc' : 'h') .. '<Cmd>noh<CR>'
nnoremap l l<Cmd>normal zv<CR><Cmd>noh<CR>
nnoremap <silent> n n<Cmd>normal zv<CR>
nnoremap <silent> N N<Cmd>normal zv<CR>
nnoremap Z<Tab> <Cmd>set foldmethod=indent<CR>
nnoremap Z{ <Cmd>set foldmethod=marker<CR>
nnoremap Zy <Cmd>set foldmethod=syntax<CR>
xnoremap zf <ScriptCmd>vimrc#myutil#Zf()<CR>
nnoremap zd <ScriptCmd>vimrc#myutil#Zd()<CR>
nnoremap g; <ScriptCmd>silent! normal! g;zv<CR>
# }}}
# }}}

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
	const v = synIDattr(id, name)->matchstr(&termguicolors ? '.*[^0-9].*' : '^[0-9]\+$')
	return !v ? 'NONE' : v
enddef

def GetHl(name: string): any
	const id = hlID(name)->synIDtrans()
	return { fg: GetAttr(id, 'fg'), bg: GetAttr(id, 'bg') }
enddef

def MyHighlight()
	const x = &termguicolors ? 'gui' : 'cterm'
	const signBg = GetHl('LineNr').bg
	# lspのsign
	for [a, b] in items({
		Error: 'ErrorMsg',
		Hint: 'Question',
		Info: 'MoreMsg',
		Warning: 'WarningMsg',
	})
		execute $'hi LspDiagSign{a}Text {x}bg={signBg} {x}fg={GetHl(b).fg}'
	endfor
	# luaParenErrorを定義しておかないと以下のエラーになることがある(最小構成は不明)
	# E28: No such highlight group name: luaParenError " See issue #11277
	hi link luaParenError Error
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
	matchadd('Todo', '^\s*- \zs\[ \]')
	matchadd('Error', 'ERROR')
	matchadd('SpellRare', '[ａ-ｚＡ-Ｚ０-９（）｛｝]')
	# 全角空白と半角幅の円記号
	matchadd('SpellBad', '[　¥]')
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
set termguicolors
# 以下はローカル設定後にやる
# set background=light
# silent! colorscheme girly
# }}}

# ------------------------------------------------------
# その他 {{{
g:loaded_matchparen = 1
g:loaded_matchit = 1

# カーソルの形
if has('vim_starting')
	&t_SI = "\e[0 q"
	&t_EI = "\e[2 q"
	&t_SR = "\e[4 q"
endif

# しばらくタブパネルをおためし
if 60 < &columns
	vimrc#tabpanel#Toggle(2)
endif
# }}}

# ------------------------------------------------------
# タブパネル {{{
g:anypanel = [
	[''],
	'anypanel#TabBufs()',
	['anypanel#HiddenBufs()->g:TabpanelIdx2Chars()'],
	[
		'anypanel#Padding(1)',
		'anypanel#File("~/todolist.md")',
		'anypanel#Padding(1)',
		'anypanel#Calendar()',
		'vimrc#ruler#MyRuler()'
	],
]
# }}}

# ------------------------------------------------------
# 数字キー無しでバッファを操作 {{{
g:idxchars = '%jklhdsanmvcgqwertyuiopzxb'
def! g:TabpanelIdx2Chars(lines: string): string
	return lines->substitute('\(\n \)\(\d\+\)', (m) => m[1] .. (g:idxchars[str2nr(m[2])] ?? m[2]), 'g')
enddef
def! g:Getchar2idx(): number
	echo 'Input bufnr: '
	const idx = stridx(g:idxchars, getchar()->nr2char())
	if idx ==# -1
		return bufnr('#')
	else
		return idx
	endif
enddef
nnoremap <LocalLeader>f <ScriptCmd>execute $'buffer {g:Getchar2idx()}'<CR>
nnoremap <LocalLeader>d <ScriptCmd>execute $'confirm bdel {g:Getchar2idx()}'<CR>
# }}}

# ------------------------------------------------------
# ローカル設定 {{{
if '~/.vimrc_local'->expand()->filereadable()
	source ~/.vimrc_local
endif
# }}}

# ------------------------------------------------------
# 色(ローカル設定後) {{{
if !exists('g:colors_name')
	set background=light
	silent! colorscheme girly
endif

# 色の設定が終ってからtabpanelを表示する
anypanel#Init()
# }}}

# ------------------------------------------------------
# ファイルを開いたらカーソル位置を復元する {{{
def RestorePos()
	if &ft ==# 'help' || &ft ==# 'gitrebase'
		return
	endif
	if !!&diff
		return
	endif
	const n = line('''"')
	if n < 1 || line('$') < n
		return
	endif
	# ここまで来たらOK
	silent! normal! g`"zvzz
enddef
# FileTypeでfoldmethodを指定したあとにzvしたいのでSafeState後に実行する
au vimrc BufRead * au vimrc SafeState * ++once RestorePos()
# }}}

# ------------------------------------------------------
# 起動時に前回のファイルを開く {{{
au vimrc VimEnter * ++nested {
	if empty(bufname())
		const lastfile = get(v:oldfiles, 0, '')->expand()
		if lastfile->filereadable()
			# 読み込み重いけどこのタイミングでpackaddするしかない…
			packadd vim-gitgutter
			packadd vim-log-highlighting
			packadd vim-polyglot
			vimrc#lsp#LazyLoad()
			execute 'edit' lastfile
			silent! execute('normal! zv') # executeじゃないとおかしくなる？
		endif
	endif
	if empty(bufname())
		intro
	endif
}
# }}}

# ------------------------------------------------------
# 初期表示後の設定 {{{
au vimrc SafeStateAgain * ++once vimrc#lazyload#LazyLoad()
# }}}

