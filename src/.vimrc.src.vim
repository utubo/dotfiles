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

# こんな感じ
#   Each nmap,xmap j gj
#   → nmap j gj | xmap j gj
# 先頭以外に差し込んだりネストしたい場合はこう
#   Each j,k Each nmap,xmap {1} {0} g{0}
#   → nmap j gj | xmap j gj | nmap k gk | xmap k gk
# ※これ使うよりべたで書いたほうが起動は速い
g:util_each_nest = 0
def! g:UtilEach(qargs: string)
	const [items, args] = qargs->split('^\S*\zs')
	g:util_each_nest += 1
	for i in items->split(',')
		var a = args->substitute('{0\?}', i, 'g')
		if a ==# args
			a = $'{i} {a}'
		endif
		execute a->substitute($"\{{g:util_each_nest}\}", '{}', 'g')
	endfor
	g:util_each_nest -= 1
enddef
command! -keepscript -nargs=* Each g:UtilEach(<q-args>)

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

# 自作マネージャ {{{
g:ezpack_home = expand($'{&pp->split(',')[0]}/pack/ezpack')
if !isdirectory(g:ezpack_home)
	system($'git clone https://github.com/utubo/vim-ezpack.git {g:ezpack_home}/opt/vim-ezpack')
	vimrc#ezpack#Install()
endif
command! EzpackInstall vimrc#ezpack#Install()
command! EzpackCleanUp vimrc#ezpack#CleanUp()
# }}}

# zenmode {{{
g:zenmode = {}
au vimrc User Vim9skkModeChanged zenmode#Invalidate()
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
# 見出しモードでスタートする
au vimrc User Vim9skkEnter feedkeys('Q')
# AZIKライクな設定とか
au vimrc User Vim9skkInitPre vimrc#vim9skk#ApplySettings()
#}}}

# textobj-user {{{
Each onoremap,xnoremap ab <Plug>(textobj-multiblock-a)
Each onoremap,xnoremap ib <Plug>(textobj-multiblock-i)
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

filetype plugin indent on
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

	const ruler = $' {line(".")}:{col(".")}'

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
	const maxlen = &columns - len(ruler) - 2
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
	add(msg, ['Normal', repeat(' ', maxlen - msglen) .. ruler])
	redraw
	echo ''
	for m in msg
		execute 'echohl' m[0]
		echon m[1]
	endfor
	echohl Normal
enddef

nnoremap <script> <C-g> <ScriptCmd>ShowBufInfo()<CR>
au vimrc BufNewFile,BufReadPost,BufWritePost * ShowBufInfo('BufNewFile')
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
set background=light
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
au vimrc SafeStateAgain * ++once vimrc#lazyload#LazyLoad()
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

