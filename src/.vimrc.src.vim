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
set shortmess+=FI # 後で:introする
filetype plugin indent on

augroup vimrc
	# 新しい自由
	au!
augroup END
#}}} -------------------------------------------------------

# ------------------------------------------------------
# 自作マネージャ {{{
g:ezpack_home = expand($'{&pp->split(',')[0]}/pack/ezpack')
if !isdirectory(g:ezpack_home)
	system($'git clone https://github.com/utubo/vim-ezpack.git {g:ezpack_home}/opt/vim-ezpack')
	vimrc#ezpack#Install()
endif
command! EzpackInstall vimrc#ezpack#Install()
command! EzpackCleanUp vimrc#ezpack#CleanUp()
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
nnoremap <expr> h (col('.') ==# 1 && 0 < foldlevel('.') ? 'zc' : 'h')
nnoremap Z<Tab> <Cmd>set foldmethod=indent<CR>
nnoremap Z{ <Cmd>set foldmethod=marker<CR>
nnoremap Zy <Cmd>set foldmethod=syntax<CR>
xnoremap zf <ScriptCmd>vimrc#myutil#Zf()<CR>
nnoremap zd <ScriptCmd>vimrc#myutil#Zd()<CR>
nnoremap g; <ScriptCmd>silent! normal! g;zO<CR>
#}}}
#}}} -------------------------------------------------------

# ------------------------------------------------------
# 色 {{{
nnoremap <expr> ZB $"<Cmd>set background={&background ==# 'dark' ? 'light' : 'dark'}<CR>"

# defaultも悪くない
au vimrc ColorScheme default {
	hi MatchParen ctermbg=7 ctermfg=13 cterm=bold
	hi Search ctermbg=12 ctermfg=7
	hi TODO ctermbg=7 ctermfg=14
	hi String ctermbg=7
	hi SignColumn ctermbg=7
	hi FoldColumn ctermbg=7
	hi WildMenu ctermbg=7
	hi DiffText ctermbg=227
}

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
# 以下はローカル設定後にやる
# set background=light
# silent! colorscheme girly
#}}} -------------------------------------------------------

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
# }}}

# ------------------------------------------------------
# ローカル設定 {{{
if '~/.vimrc_local'->expand()->filereadable()
	source ~/.vimrc_local
endif
#}}}

# ------------------------------------------------------
# 色(ローカル設定後) {{{
if !exists('g:colors_name')
  set background=light
  silent! colorscheme girly
endif
# }}}

# ------------------------------------------------------
# ファイルを開いたらカーソル位置を復元する {{{
# http://advweb.seesaa.net/article/13443981.html
def RestorePos()
	const n = line('''"')
	if 1 <= n && n <= line('$')
		silent! normal! g`"zOzz
	endif
enddef
au vimrc BufRead * RestorePos()
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
#}}}

