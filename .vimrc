set encoding=utf-8
scriptencoding utf-8

" -----------------------------------------------------------------------------
" 基本設定 {{{
set fileencoding=utf-8 encoding=utf-8
set fileencodings=iso-2022-jp,ucs-bom,cp932,sjis,euc-jp,utf-8
set tabstop=4
set shiftwidth=4
set autoindent
set smartindent
set breakindent
set nf=
set virtualedit=block
set hlsearch
nohlsearch
set list
set listchars=tab:\|\ ,trail:-,extends:>,precedes:<,nbsp:%
set laststatus=2
set ruler
set visualbell
set t_vb=
set autochdir
set backupskip=/var/tmp/*

let s:is_raspi = !has('win32') && !has('mac') && system('uname -a') =~ 'raspberrypi'

augroup s:MyAu
	au!
augroup End
" }}} -------------------------------------------------------------------------

" -----------------------------------------------------------------------------
" プラグイン {{{
if filereadable(expand('~/.vim/bundle/neobundle.vim/autoload/neobundle.vim'))
	" ばんどる {{{
	if has('vim_starting')
		if &compatible
			set nocompatible " Be iMproved
		endif
		set runtimepath+=~/.vim/bundle/neobundle.vim
	endif
	let g:neocomplcache_enable_at_startup = 1
	call neobundle#begin(expand('~/.vim/bundle'))
	NeoBundleFetch 'Shougo/neobundle.vim'
	NeoBundle 'Shougo/neosnippet'
	NeoBundle 'Shougo/neosnippet-snippets'
	if s:is_raspi
		NeoBundleFetch 'Shougo/neocomplcache.vim'
	else
		NeoBundle 'Shougo/neocomplcache.vim'
	end
	NeoBundle 'Lokaltog/vim-easymotion'
	NeoBundle 'itchyny/lightline.vim'
	NeoBundle 'mbbill/undotree'
	NeoBundle 't9md/vim-quickhl'
	NeoBundle 'tyru/caw.vim'
	NeoBundle 'scrooloose/nerdtree'
	" filetypesで読み込み
	NeoBundleLazy 'mattn/jscomplete-vim',   {'autoload' : {'filetypes' : 'javascript'}}
	NeoBundleLazy 'osyo-manga/vim-monster', {'autoload' : {'filetypes' : 'ruby'}}
	" commandsで読み込み
	NeoBundleLazy 'utubo/vim-reformatdate', {'autoload' : {'commands' : 'reformatdate#reformat'}}
	NeoBundleLazy 'yegappan/mru',           {'autoload' : {'commands' : 'MRU'}}
	call neobundle#end()
	" }}}

	" neosnippet {{{
	imap <S-Tab> <Plug>(neosnippet_expand_or_jump)
	smap <S-Tab> <Plug>(neosnippet_expand_or_jump)
	xmap <S-Tab> <Plug>(neosnippet_expand_target)
	imap <expr> <Tab> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? "\<C-n>" : "\<Tab>"
	smap <expr> <Tab> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<Tab>"
	" }}}

	" easymotion {{{
	let g:EasyMotion_do_mapping = 0
	let g:EasyMotion_smartcase = 1
	let g:EasyMotion_use_migemo = 1
	nmap s <Plug>(easymotion-s)
	" }}}

	" undotree {{{
	if has("persistent_undo")
		set undodir='~/.undodir/'
		set undofile
		let g:undotree_TreeNodeShape = 'o'
		let g:undotree_SetFocusWhenToggle = 1
		let g:undotree_DiffAutoOpen = 0
		nnoremap <silent> <F5> :silent! UndotreeToggle<cr>
	endif
	" }}}

	" その他 {{{
	autocmd FileType javascript setlocal omnifunc=jscomplete#CompleteJS
	let g:neocomplete#sources#omni#input_patterns = {'ruby' : '[^. *\t]\.\w*\|\h\w*::',}
	" }}}
	map <Leader>c <Plug>(caw:i:toggle)
	nmap <Space>m <Plug>(quickhl-manual-this)
	nmap <Space>M <Plug>(quickhl-manual-reset)
	nnoremap <silent> <F1> :NERDTreeToggle<CR>
endif
filetype plugin indent on " required
" }}} -------------------------------------------------------------------------

" ↓ここからしばらくコピペ

" -----------------------------------------------------------------------------
" Movement in insert mode {{{
" https://github.com/junegunn/dotfiles/blob/dbeddfce1bd1975e499984632191d2d1ec080e25/vimrc からコピペ
inoremap <C-h> <C-o>h
inoremap <C-l> <C-o>a
inoremap <C-j> <C-o>j
inoremap <C-k> <C-o>k
inoremap <C-^> <C-o><C-^>
" }}} -------------------------------------------------------------------------

" -----------------------------------------------------------------------------
" その他パクリ {{{
au s:MyAu InsertLeave * set nopaste
au s:MyAu BufReadPost *.log* normal G
noremap  <Space>h ^
noremap  <Space>l $
nnoremap <silent> <C-c> o<Esc>
vnoremap <silent> * "vy/\V<C-r>=substitute(escape(@v,'\/'),"\n",'\\n','g')<CR><CR>
xnoremap . :normal! .<CR>
inoremap kj <Esc>`^
inoremap <F6> <C-r>=strftime('%Y/%m/%d(%a)')<CR>
" }}} -------------------------------------------------------------------------

" ↑ここまでコピペ(頭のいい人が書いたのでメンテ不要)
" ↓ここから自作(頭の悪い人が書いたので要メンテ)

" -----------------------------------------------------------------------------
" 色 {{{
function! s:MyColorScheme()
	hi String ctermfg=blue ctermbg=lightblue
	hi! link Folded Comment
endfunction
au s:MyAu ColorScheme * call <SID>MyColorScheme()
set t_Co=256
syntax on
colorscheme elflord
if s:is_raspi
	au s:MyAu BufEnter * if 500 < line('$') | setlocal syntax=off | endif
endif
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
" ・キーが小さいので押しにくいものはSpaceへマッピング
" ・スマホでのコーディングは基本的にバグ取り
if $IS_MOBILE
	nnoremap ; :
	nnoremap <Space>; ;
endif
nnoremap <Space>zz :<C-u>q!<CR>
nnoremap <Space>n /
nnoremap <Space>b ?
" スタックトレースからyankしてソースの該当箇所を探すのを補助
nnoremap <Space>e G?\cErr\\|Exception<CR>
nnoremap <Space>w eb"wyee:echo 'yanked "'.@w.'" to "w'<CR>
nnoremap <expr> <Space>g (@w =~ '^\d\+$' ? ':' : '/').@w."\<CR>"
" }}} -------------------------------------------------------------------------

" -----------------------------------------------------------------------------
" 同じインデントの行まで移動 {{{
noremap <expr> <Space>] search('^' . matchstr(getline('.'), '^\s*') . '\%>' . line('.') . 'l\S', 'e').'G'
noremap <expr> <Space>[ search('^' . matchstr(getline('.'), '^\s*') . '\%<' . line('.') . 'l\S', 'be').'G'
noremap <expr> <Space>} (search('^' . matchstr(getline('.'), '^\s*') . '\%>' . line('.') . 'l\S', 'e') - 1).'G'
noremap <expr> <Space>{ (search('^' . matchstr(getline('.'), '^\s*') . '\%<' . line('.') . 'l\S', 'be') + 1).'G'
" }}} -------------------------------------------------------------------------

" -----------------------------------------------------------------------------
" 文頭に合わせて行移動 {{{
function! s:PutHat()
	let l:x = match(getline('.'), '\S.') + 1
	if l:x || !exists('w:my_hat')
		let w:my_hat = col('.') == l:x ? '^' : ''
	endif
	return w:my_hat
endfunction
nnoremap <expr> j 'j'.<SID>PutHat()
nnoremap <expr> k 'k'.<SID>PutHat()
" }}} -------------------------------------------------------------------------

" -----------------------------------------------------------------------------
" テンプレート {{{
function! s:ReadTemplate()
	let l:filename = expand('~/.vim/template/'.&filetype.'.txt')
	if filereadable(l:filename)
		execute '0r '.l:filename
		if search('<+CURSOR+>')
			normal! "_da>
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
	let l:text = getline(v:foldstart)
	let l:indent = substitute(matchstr(l:text, '^\s\+'), '\t', repeat(' ', &shiftwidth), 'g')
	if &foldmethod == 'indent'
		return l:indent.'>...'
	elseif &foldmethod == 'marker'
		return l:indent.'+>'.substitute(l:text, '{'.'{{', '', '')
	else
		return l:indent.'+>'.l:text
	endif
endfunction
set foldtext=MyFoldText()
set fillchars=fold:\ " 折りたたみの「-」を非表示
set foldmethod=marker
nnoremap <expr> h (col('.') == 1 ? 'zc' : 'h')
nnoremap z<Tab> :<C-u>set foldmethod=indent<CR>
nnoremap z{ :<C-u>set foldmethod=marker<CR>
nnoremap zy :<C-u>set foldmethod=syntax<CR>
" }}} -------------------------------------------------------------------------

" -----------------------------------------------------------------------------
" 括弧でくくる {{{
" これでいいや。不便に感じたらプラグインを入れる。
let g:put_quotation_dic = {'「':'」', '(':')', '{':'}', '{{{':'}}}', '[':']', '<':'>' }
function! PutQuotationComp(A, L, P)
	return keys(g:put_quotation_dic)
endfunction
function! s:PutQuotation()
	let l:start = input('括る文字: ', '', 'customlist,PutQuotationComp')
	let l:end = has_key(g:put_quotation_dic, l:start) ? g:put_quotation_dic[l:start] : substitute(l:start, '^<', '</', '')
	let l:cur = getpos("'>")
	call setpos('.', getpos("'<"))
	execute 'normal! i'.l:start
	call cursor(l:cur[1], min([l:cur[2], col([l:cur[1], '$']) - len(l:start)]) + len(l:start))
	execute 'normal! a'.l:end
endfunction
vnoremap <silent> <Space>q :call <SID>PutQuotation()<CR>
nmap <Space>q viw q
" }}} -------------------------------------------------------------------------

" -----------------------------------------------------------------------------
" やりすぎ注意 {{{
function! s:ShowEditingTime()
	if exists('g:edit_start_time')
		let l:t = localtime() - g:edit_start_time
		let l:h = l:t / 3600
		let l:m = (l:t % 3600) / 60
		echo l:h.'時間'.l:m.'分経過'.(1 < l:h ? '(^q^)' : l:h ? '(><)' : '')
	else
		let g:edit_start_time = localtime()
	endif
endfunction
au s:MyAu VimEnter * call <SID>ShowEditingTime()
nnoremap <silent> <Esc><Esc> :noh \| :call <SID>ShowEditingTime()<CR>
" }}} -------------------------------------------------------------------------

" -----------------------------------------------------------------------------
" その他細々したの {{{
au s:MyAu BufNew * set noexpandtab
au s:MyAu BufRead *
	\   if !search('^\t', 'n', 100) && search('^  ', 'n', 100)
	\ | 	set expandtab
	\ | endif
au s:MyAu VimEnter,WinEnter *
	\   if !exists('w:match_badchars')
	\ | 	let w:match_badchars = matchadd('SpellBad', '　\|¥\|\s\+$')
	\ | endif
nnoremap <expr> g: ":\<C-u>".substitute(getline('.'), '^[\t ":]\+', '', '')."\<CR>"
vnoremap g: "vy:<C-r>=@v<CR><CR>
cnoremap <expr> <C-r><C-r> "\<C-r>\"".(@" =~ '\n$' ? "\<BS>" : '')
nnoremap <Space>y y$
nnoremap <Space>d d$
nnoremap <Space>p $p
nnoremap <Space>P ^P
inoremap ｋｊ <ESC>`^
inoremap 「 「」<Left>
inoremap （ ()<Left>
inoremap <C-S-h> ←
inoremap <C-S-j> ↓
inoremap <C-S-k> ↑
inoremap <C-S-l> →
" }}} -------------------------------------------------------------------------

" -----------------------------------------------------------------------------
" 設定したのを忘れるくらい使って無いので削除しようかな {{{
nnoremap <Space><Space> <C-w>
inoremap <C-r><C-r> <C-r>"
" }}} -------------------------------------------------------------------------

" -----------------------------------------------------------------------------
" ノーマッピングデー {{{
if strftime('%d') == '01'
	au s:MyAu VimEnter * echo "* * * It's no-mapping-day ! * * *"
	imapclear
	mapclear
endif
" }}} -------------------------------------------------------------------------

