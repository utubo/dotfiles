set encoding=utf-8
scriptencoding utf-8

" ----------------------------------------------------------
" 基本設定 {{{
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
set display=lastline
set belloff=all
set autochdir
set backupskip=/var/tmp/*
set ttimeoutlen=50

let s:is_raspi = has('unix') && system('uname -a') =~ 'raspberrypi'

augroup vimrc
	au!
augroup End
" }}} -----------------------------------------------------

" ----------------------------------------------------------
"  ユーティリティ {{{
"  「nmap <agrs>|vmap <agrs>」と同じ。「<if-normal>」以降は「nmap」だけに適用。
command! -nargs=* NVmap execute 'nmap ' . substitute(<q-args>, '<if-normal>', '', '') | execute 'vmap ' . substitute(<q-args>, '<if-normal>.*', '', '')
"  }}}

" ----------------------------------------------------------
" プラグイン {{{
let s:dein_dir = expand('~/.vim/dein')
let s:dein_vim = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
if isdirectory(s:dein_vim)
	" dein {{{
	let &runtimepath = s:dein_vim . ',' . &runtimepath
	let g:neocomplcache_enable_at_startup = 1
	call dein#begin(s:dein_dir)
	call dein#add('Lokaltog/vim-easymotion')
	call dein#add('Shougo/dein.vim')
	call dein#add('Shougo/neocomplcache.vim', (s:is_raspi ? {'rtp': ''} : { }))
	call dein#add('Shougo/neosnippet')
	call dein#add('Shougo/neosnippet-snippets')
	call dein#add('itchyny/lightline.vim')
	call dein#add('jceb/vim-hier')
	call dein#add('machakann/vim-sandwich')
	call dein#add('mattn/jscomplete-vim', {'lazy':1, 'on_ft':'javascript'})
	call dein#add('mbbill/undotree')
	call dein#add('osyo-manga/shabadou.vim')
	call dein#add('osyo-manga/vim-monster', {'lazy':1, 'on_ft':'ruby'})
	call dein#add('osyo-manga/vim-watchdogs')
	call dein#add('rhysd/github-complete.vim')
	call dein#add('scrooloose/nerdtree')
	call dein#add('t9md/vim-quickhl')
	call dein#add('thinca/vim-portal')
	call dein#add('thinca/vim-quickrun')
	call dein#add('tyru/caw.vim')
	call dein#add('utubo/vim-reformatdate', {'lazy':1, 'on_cmd':'reformatdate#reformat'})
	call dein#add('yegappan/mru', {'lazy':1, 'on_cmd':'MRU'})
	" vimproc
	if has('win32')
		let g:vimproc#download_windows_dll = 1
		call dein#add('Shougo/vimproc')
	else
		call dein#add('Shougo/vimproc', {'build': {'linux': 'make', 'unix': 'gmake'}})
	endif
	call dein#end()
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
	let g:EasyMotion_enter_jump_first = 1
	map s <Plug>(easymotion-s)
	au vimrc VimEnter,BufEnter * EMCommandLineNoreMap <Space><Space> <Esc>
	au vimrc ColorScheme *
		\   hi EasyMotionTarget ctermfg=green guifg=#00ffcc
		\ | hi EasyMotionTarget2First ctermfg=darkcyan guifg=#00ccff
		\ | hi! link EasyMotionTarget2Second EasyMotionTarget2First
	" }}}

	" undotree {{{
	if has("persistent_undo")
		set undodir='~/.undodir/'
		set undofile
		let g:undotree_TreeNodeShape = 'o'
		let g:undotree_SetFocusWhenToggle = 1
		let g:undotree_DiffAutoOpen = 0
		nnoremap <silent> <F3> :<C-u>silent! UndotreeToggle<cr>
	endif
	" }}}

	" watchdogs {{{
	let g:watchdogs_check_BufWritePost_enable = 1
	let g:watchdogs_check_CursorHold_enable = 1
	" }}}

	" sandwitch {{{
	let g:sandwich#recipes = deepcopy(g:sandwich#default_recipes)
	let g:sandwich#recipes += [{'buns': ['「', '」'],'input': ['k']}] " kakko
	let g:operator_sandwich_no_default_key_mappings = 1
	NVmap Sd <Plug>(operator-sandwich-delete)<if-normal><Plug>(textobj-sandwich-query-a)
	NVmap Sr <Plug>(operator-sandwich-replace)<if-normal><Plug>(textobj-sandwich-query-a)
	NVmap Sa <Plug>(operator-sandwich-add)
	NVmap S <Plug>(operator-sandwich-add)<if-normal>iw
	nmap SR' Sr"'
	nmap SR" Sr'"
	" メモ
	" i:都度入力, t:タグ, k:括弧
	" }}}

	" その他 {{{
	autocmd FileType javascript setlocal omnifunc=jscomplete#CompleteJS
	let g:neocomplete#sources#omni#input_patterns = {'ruby' : '[^. *\t]\.\w*\|\h\w*::',}
	NVmap <Leader>c <Plug>(caw:i:toggle)
	nmap <Space>m <Plug>(quickhl-manual-this)
	nmap <Space>M <Plug>(quickhl-manual-reset)
	nnoremap <silent> <F1> :<C-u>NERDTreeToggle<CR>
	nnoremap <silent> <F2> :<C-u>MRU<CR>
	" }}}
endif
filetype plugin indent on
" }}} -----------------------------------------------------

" ↓ここからしばらくコピペ寄せ集め

" ----------------------------------------------------------
" Movement in insert mode {{{
" https://github.com/junegunn/dotfiles/blob/dbeddfce1bd1975e499984632191d2d1ec080e25/vimrc からコピペ
inoremap <C-h> <C-o>h
inoremap <C-l> <C-o>a
inoremap <C-j> <C-o>j
inoremap <C-k> <C-o>k
inoremap <C-^> <C-o><C-^>
" }}} -----------------------------------------------------

" ----------------------------------------------------------
" DIFF関係 {{{
set splitright
set diffopt=vertical
command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis
nnoremap <F4> :<C-u>DiffOrig<CR>
" DIFFモードを自動でOFF https://hail2u.net/blog/software/vim-turn-off-diff-mode-automatically.html
au vimrc WinEnter * if (winnr('$') == 1) && (getbufvar(winbufnr(0), '&diff')) == 1 | diffoff | endif
" }}} -----------------------------------------------------

" ---------------------------------------------------------
" その他パクリ {{{
au vimrc InsertLeave * set nopaste
au vimrc BufReadPost *.log* normal G
nnoremap <silent> <C-c> o<Esc>
vnoremap <silent> * "vy/\V<C-r>=substitute(escape(@v,'\/'),"\n",'\\n','g')<CR><CR>
xnoremap . :normal! .<CR>
inoremap kj <Esc>`^
inoremap kk <Esc>`^
" http://deris.hatenablog.jp/entry/2014/05/20/235807
nnoremap gs :<C-u>%s///g<Left><Left><Left>
vnoremap gs :%s///g<Left><Left><Left>
" }}} -----------------------------------------------------

" ↑ここまでコピペ寄せ集め

" ---------------------------------------------------------
" 色 {{{
set t_Co=256
function! s:MyColorScheme()
	hi String ctermfg=156 ctermbg=234
	hi! link Folded Comment
endfunction
au vimrc ColorScheme * call <SID>MyColorScheme()
colorscheme elflord
syntax on
" }}} -----------------------------------------------------

" ---------------------------------------------------------
" 日付関係 {{{
inoremap <F5> <C-r>=strftime('%Y/%m/%d')<CR>
cnoremap <F5> <C-r>=strftime('%Y%m%d')<CR>
nnoremap <silent> <F5> :<C-u>call reformatdate#reformat(localtime())<CR>
nnoremap <silent> <C-a> <C-a>:call reformatdate#reformat()<CR>
nnoremap <silent> <C-x> <C-x>:call reformatdate#reformat()<CR>
nnoremap <Space><F5> /\d\{4\}\/\d\d\/\d\d<CR>
" }}} -----------------------------------------------------

" ---------------------------------------------------------
" スマホ用キーバインド {{{
" ・キーが小さいので押しにくいものはSpaceへマッピング
" ・スマホでのコーディングは基本的にバグ取り
nnoremap <Space>zz :<C-u>q!<CR>
nnoremap <Space>n /
nnoremap <Space>b ?
" スタックトレースからyankしてソースの該当箇所を探すのを補助
nnoremap <Space>e G?\cErr\\|Exception<CR>
nnoremap <Space>w eb"wyee:echo 'yanked "'.@w.'" to @w'<CR>
nnoremap <expr> <Space>g (@w =~ '^\d\+$' ? ':' : '/').@w."\<CR>"
" }}} -----------------------------------------------------

" ---------------------------------------------------------
" 同じインデントの行まで移動 {{{
function! s:FindSameIndentLine(forwardOrBack)
	let l:flags = a:forwardOrBack == '>' ? 'e' : 'be'
	return search('^'.matchstr(getline('.'), '^\s*').'\%'.a:forwardOrBack.line('.').'l\S', l:flags)
endfunction
noremap <expr> <Space>] <SID>FindSameIndentLine('>').'G'
noremap <expr> <Space>[ <SID>FindSameIndentLine('<').'G'
noremap <expr> <Space>} (<SID>FindSameIndentLine('>') - 1).'G'
noremap <expr> <Space>{ (<SID>FindSameIndentLine('<') + 1).'G'
" }}} -----------------------------------------------------

" ---------------------------------------------------------
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
" }}} -----------------------------------------------------

" ---------------------------------------------------------
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
au vimrc BufNewFile * call <SID>ReadTemplate()
" }}} -----------------------------------------------------

" ---------------------------------------------------------
" 折りたたみ {{{
function! MyFoldText()
	let l:text = getline(v:foldstart)
	let l:indent = substitute(matchstr(l:text, '^\s\+'), '\t', repeat(' ', &shiftwidth), 'g')
	return l:indent . (&foldmethod != 'indent' ? substitute(l:text,  '^\s\+\|{' . '{{',  '', 'g') : '') . '[+]'
endfunction
set foldtext=MyFoldText()
set fillchars=fold:\ " 折りたたみの「-」を非表示
set foldmethod=marker
nnoremap <expr> h (col('.') == 1 ? 'zc' : 'h')
nnoremap Z<Tab> :<C-u>set foldmethod=indent<CR>
nnoremap Z{ :<C-u>set foldmethod=marker<CR>
nnoremap Zy :<C-u>set foldmethod=syntax<CR>
" }}} -----------------------------------------------------

" ---------------------------------------------------------
" コマンドモード {{{
cnoremap <C-h> <Left>
cnoremap <C-l> <Right>
cnoremap kj <C-c>
cnoremap <C-r><C-r> <C-r>=substitute(@", '^\s\+\\|\n\+$', '', 'g')<CR>
nnoremap q: q:a
" }}} -----------------------------------------------------

" ---------------------------------------------------------
" やりすぎ注意 {{{
if exists('g:vimrc_tea_break')
	call timer_stop(g:vimrc_tea_break.timer)
endif
let g:vimrc_tea_break = { 'count': 0 }
function! g:vimrc_tea_break.exec(timer)
	let self.count += 1
	if self.count == 45
		echo "そろそろ休憩(*'∀`*)っ 旦~"
	elseif self.count >= 60
		echo '休憩終わり'
		let self.count = 0
	endif
endfunction
let g:vimrc_tea_break.timer = timer_start(60000, g:vimrc_tea_break.exec, { 'repeat': -1 })
" }}} -----------------------------------------------------

" ---------------------------------------------------------
" その他細々したの {{{
au vimrc BufRead * let &expandtab=(!search('^\t', 'cn', 99) && search('^  ', 'cn', 99))
au vimrc VimEnter,WinEnter *
	\   if !exists('w:match_badchars') || !len(getmatches())
	\ | 	let w:match_badchars = matchadd('SpellBad', '　\|¥\|\s\+$')
	\ | endif
nnoremap <F9> <C-w>w
nnoremap <F10> :q<CR>
nnoremap <silent> <F12> :<C-u>set wrap! wrap?<CR>
nnoremap <silent> <Space><Space> :<C-u>noh<CR>
nnoremap <expr> g: ":\<C-u>".substitute(getline('.'), '^[\t ":]\+', '', '')."\<CR>"
vnoremap g: "vy:<C-r>=@v<CR><CR>
nnoremap Y y$
nnoremap <Space>p $p
nnoremap <Space>P ^P
inoremap <C-r><C-r> <C-r>"
inoremap ｋｊ <Esc>`^
inoremap 「 「」<Left>
inoremap （ ()<Left>
inoremap :w <Esc>`^:w
" 「::w…」は出番がそこそこあるので、↑のマッピングが誤爆しないように…
inoremap :: ::
" }}} -----------------------------------------------------

" ---------------------------------------------------------
" 設定したのを忘れるくらい使って無いのはここに移動して様子見 {{{

" }}} -----------------------------------------------------

" ---------------------------------------------------------
" デフォルトマッピングデー {{{
if strftime('%d') == '01'
	au vimrc VimEnter * echo '+^`^+.,.+ Today is default-mapping-day ! +^`^+.,.+'
	imapclear
	mapclear
endif
" }}} -----------------------------------------------------

" ---------------------------------------------------------
" メモ {{{
" <F1> NERDTree
" <F2> MRU
" <F3> UndoTree
" <F4> DiffOrig
" <F5> 日付関係
" <F6>
" <F8>
" <F9> ウィンドウ切替
" <F10> :q
" <F11>
" <F12> 折り返し切替
" ※「構文等のインデントはタブ、見た目の桁合わせは半角スペース」なのでキモインデントになってる所があるかも…ごめんなさい
" }}}

