set encoding=utf-8
scriptencoding utf-8
set fileencoding=utf-8 encoding=utf-8
set fileencodings=ucs-bom,utf-8,sjis,euc-jp,iso-2022-jp
set tabstop=4
set shiftwidth=4
set list
set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:%
set nf=
set hlsearch
set autoindent
set smartindent
set virtualedit=block
set ruler
filetype indent on

augroup s:MyAu
	au!
augroup End

" ↓ここからしばらくコピペ

" -----------------------------------------------------------------------------
" Movement in insert mode {{{
inoremap <C-h> <C-o>h
inoremap <C-l> <C-o>a
inoremap <C-j> <C-o>j
inoremap <C-k> <C-o>k
inoremap <C-^> <C-o><C-^>
" https://github.com/junegunn/dotfiles/blob/dbeddfce1bd1975e499984632191d2d1ec080e25/vimrc
" }}} -------------------------------------------------------------------------

" -----------------------------------------------------------------------------
" その他パクリ {{{
au s:MyAu InsertLeave * set nopaste
nnoremap Y y$
nnoremap d\ d$
nnoremap <silent> <C-c> o<ESC>
xnoremap . :normal .<CR>
inoremap <F6> <C-r>=strftime('%Y/%m/%d(%a)')<CR>
inoremap jj <ESC>
inoremap kk <ESC>
" }}} -------------------------------------------------------------------------

" ↑ここまでコピペ(頭のいい人が書いたのでメンテ不要)
" ↓ここから自作(頭の悪い人が書いたので要メンテ)

" -----------------------------------------------------------------------------
" 色 {{{
function! s:MyColorScheme()
	hi String ctermfg=blue ctermbg=lightblue
	hi! link Folded Comment
endfunction
au s:MyAu colorscheme * call <SID>MyColorScheme()
set t_Co=256
syntax on
colorscheme elflord
" }}} -------------------------------------------------------------------------

" -----------------------------------------------------------------------------
" 日付関係 {{{
" 「%Y/%m/%d」の文字列を加算減算
nnoremap <silent> <C-a> <C-a>:call reformatdate#reformat()<CR>
nnoremap <silent> <C-x> <C-x>:call reformatdate#reformat()<CR>
" 「%Y/%m/%d」の文字列を今日の日付に置換
nnoremap <silent> <F6> :call reformatdate#reformat(localtime())<CR>
" }}} -------------------------------------------------------------------------

" -----------------------------------------------------------------------------
" Android の Hacker's-Keybord用キーバインド {{{
" ・キーちっちゃいので宇宙へマッピング
" ・スマホでのコーディングは基本的にバグ取り
if $MOBILE_NOW
	nnoremap ; :
	nnoremap <Space>; ;
endif
nnoremap <Space>zz :q!<CR>
nnoremap <Space>n /
nnoremap <Space>m ?
" スタックトレースからyankしてソースの該当箇所を探す
nnoremap <Space>e G?\cErr\\|Exception<CR>
noremap  <Space>w eb"wyee:echo 'yanked "'.@w.'" to "w'<CR>
nnoremap <expr> <Space>g (@w =~ '^\d\+$' ? ':' : '/').@w."\<CR>"
" }}} -------------------------------------------------------------------------

" -----------------------------------------------------------------------------
" 同じインデントの行まで移動 {{{
noremap  <expr> <Space>jj search('^'.matchstr(getline('.'), '^\s\+').'\S', 'W').'G^'
noremap  <expr> <Space>kk cursor(0, 1).search('^'.matchstr(getline('.'), '^\s\+').'\S', 'bW').'G^'
noremap  <expr> <Space>jv 'V'.search('^'.matchstr(getline('.'), '^\s\+').'\S', 'W').'G^'
noremap  <expr> <Space>kv 'V'.cursor(0, 1).search('^'.matchstr(getline('.'), '^\s\+').'\S', 'bW').'G^'
" }}} -------------------------------------------------------------------------

" -----------------------------------------------------------------------------
" 文頭に合わせて行移動 {{{
function! s:PutMyHat()
	if 1 < len(getline('.'))
		let l:x = match(getline('.'), '\S') + 1
		let w:my_hat = (l:x ? l:x : len(getline('.'))) == col('.') ? '^' : ''
	elseif !exists('w:my_hat')
		let w:my_hat = ''
	endif
	return w:my_hat
endfunction
nnoremap <expr> j 'j'.<SID>PutMyHat()
nnoremap <expr> k 'k'.<SID>PutMyHat()
" }}} -------------------------------------------------------------------------

" -----------------------------------------------------------------------------
" テンプレート {{{
function! s:ReadTemplate()
	let l:filename = expand('~/.vim/template/'.&filetype.'.txt')
	if filereadable(l:filename)
		execute '0r '.l:filename
		if search('<+CURSOR+>')
			silent! normal! "_da>
		endif
		if col('.') == col('$') - 1
			startinsert!
		else
			startinsert
		endif
	endif
endfunction
au s:MyAu BufNewFile * call <SID>ReadTemplate()
" }}} -------------------------------------------------------------------------

" -----------------------------------------------------------------------------
" 折りたたみ {{{
function! MyFoldText()
	let l:indent = repeat(' ', matchend(getline(v:foldstart), '^\s\+') * &shiftwidth)
	if &foldmethod == 'indent'
		return l:indent.'>...'
	elseif &foldmethod == 'marker'
		return l:indent.'+>'.substitute(getline(v:foldstart), '{'.'{{', '', '')
	else
		return l:indent.'+>'.getline(v:foldstart)
	endif
endfunction
set foldtext=MyFoldText()
set fillchars=fold:\ " 折りたたみの「-」を非表示
set foldmethod=marker
nnoremap <expr> h (col('.') == 1 ? 'zc' : 'h')
nnoremap z<TAB> :set fdm=indent<CR>
nnoremap z{ :set fdm=marker<CR>
" }}} -------------------------------------------------------------------------

" -----------------------------------------------------------------------------
" やりすぎ注意 {{{
function! s:ShowEditingTime()
	if exists('g:edit_start_time')
		let l:t = localtime() - g:edit_start_time
		let l:h = l:t / 3600
		let l:m = (l:t % 3600) / 60
		if 1 < h
			let l:sufix = '(^q^)'
		elseif 0 < h
			let l:sufix = '(><)'
		else
			let l:sufix = ''
		endif
		echo h.'時間'.m.'分経過'.l:sufix
	else
		let g:edit_start_time = localtime()
	endif
endfunction
au s:MyAu VimEnter * call <SID>ShowEditingTime()
nnoremap <silent> <ESC><ESC> :noh \| :call <SID>ShowEditingTime()<CR>
" }}} -------------------------------------------------------------------------

" -----------------------------------------------------------------------------
" その他細々したの {{{
au s:MyAu VimEnter,WinEnter *
	\   if !exists('w:match_badchars')
	\ | 	let w:match_badchars = matchadd('SpellBad', '　\|¥\|\s\+$')
	\ | endif
nnoremap <expr> y: ':'.substitute(getline('.'), '^[\t ":]\+', '', '')."\<CR>"
nnoremap <expr> Y: ':'.substitute(getline('.')[col('.')-1:], '^[\t ":]\+', '', '')."\<CR>"
inoremap <C-r><C-r> <C-r>"
cnoremap <expr> <C-r><C-r> "\<C-r>\"".(@" =~ '\n$' ? "\<BS>" : '')
nnoremap <Space>p $p
inoremap 「 「」<Left>
inoremap （ ()<Left>
" }}} -------------------------------------------------------------------------

