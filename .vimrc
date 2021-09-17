set encoding=utf-8
scriptencoding utf-8

" ----------------------------------------------------------
" 基本設定 {{{
set fileencodings=ucs-bom,utf-8,iso-2022-jp,cp932,euc-jp
set noexpandtab
set tabstop=3 " 意外とありな気がしてきた…
set shiftwidth=0
set autoindent
set smartindent
set breakindent
set nf=alpha,hex
set virtualedit=block
set list
set listchars=tab:\|\ ,trail:-,extends:>,precedes:<,nbsp:%
set fillchars=
set laststatus=2
set ruler
set display=lastline
set ambiwidth=double
set belloff=all
set ttimeoutlen=50
set wildmenu
set autochdir
set backupskip=/var/tmp/*
set undodir=~/.vim/undo
set undofile
set incsearch
set hlsearch
nohlsearch

augroup vimrc
	" 新しい自由
	au!
augroup End
"}}} -------------------------------------------------------

" ----------------------------------------------------------
" ユーティリティ {{{

" 「nmap <agrs>|vmap <agrs>」と同じ。
" 引数の「<if-normal>」から行末までは「nmap」だけに適用する。
command! -nargs=* NVmap
	\ execute 'nmap ' . substitute(<q-args>, '<if-normal>', '', '') |
	\ execute 'vmap ' . substitute(<q-args>, '<if-normal>.*', '', '')

" その他
command! -nargs=1 Enable  let <args>=1
command! -nargs=1 Disable let <args>=0

function! s:RemoveEmptyLine(line) abort
	silent! execute a:line . 's/\s\+$//'
	silent! execute a:line . 's/^\s*\n//'
endfunction

function! s:BufIsSmth()
	return &modified || ! empty(bufname())
endfunction

function! s:IndentStr(expr)
	return matchstr(getline(a:expr), '^\s*')
endfunction

function! s:GetVisualSelection()
	let l:org = @"
	silent normal! gvy
	let l:text = @"
	let @" = l:org
	return l:text
endfunction
"}}}

" ----------------------------------------------------------
" プラグイン {{{
let s:dein_dir = expand('~/.vim/dein')
let s:dein_vim = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
if isdirectory(s:dein_vim)
	" dein {{{
	let &runtimepath = s:dein_vim . ',' . &runtimepath
	call dein#begin(s:dein_dir)
	call dein#add('Shougo/dein.vim')
	call dein#add('airblade/vim-gitgutter')
	call dein#add('alvan/vim-closetag')
	call dein#add('cohama/lexima.vim')      " 括弧補完
	call dein#add('dense-analysis/ale')     " Syntaxチェッカー
	call dein#add('easymotion/vim-easymotion')
	call dein#add('hrsh7th/vim-vsnip')
	call dein#add('hrsh7th/vim-vsnip-integ')
	call dein#add('itchyny/lightline.vim')
	call dein#add('jceb/vim-hier')          " quickfixをハイライト
	call dein#add('jistr/vim-nerdtree-tabs')
	call dein#add('kana/vim-textobj-user')
	call dein#add('luochen1990/rainbow')    " 虹色括弧
	call dein#add('machakann/vim-sandwich')
	call dein#add('mattn/vim-maketable')
	call dein#add('matze/vim-move')         " 複数行移動
	call dein#add('mbbill/undotree')
	call dein#add('mechatroner/rainbow_csv')
	call dein#add('michaeljsmith/vim-indent-object')
	call dein#add('osyo-manga/vim-monster', {'lazy':1, 'on_ft':'ruby'}) " rubyの補完
	call dein#add('othree/html5.vim')       " html5の補完やチェック
	call dein#add('prabirshrestha/asyncomplete-buffer.vim')
	call dein#add('prabirshrestha/asyncomplete.vim')
	call dein#add('rafamadriz/friendly-snippets')
	call dein#add('scrooloose/nerdtree')
	call dein#add('skanehira/translate.vim')
	call dein#add('thinca/vim-portal')
	call dein#add('tpope/vim-fugitive')      " Gdiffとか
	call dein#add('tyru/caw.vim')            " コメント化
	call dein#add('utubo/vim-colorscheme-utb')
	call dein#add('utubo/vim-reformatdate')
	call dein#add('utubo/vim-shrink')
	call dein#add('utubo/vim-textobj-twochars')
	call dein#add('yami-beta/asyncomplete-omni.vim')
	call dein#add('yegappan/mru')
	call dein#end()
	call dein#save_state()
	" 削除したら↓をやる
	" :call map(dein#check_clean(), "delete(v:val, 'rf')")
	" :call dein#recache_runtimepath()
	"}}}

	" easymotion {{{
	Disable g:EasyMotion_do_mapping
	Enable g:EasyMotion_smartcase
	Enable g:EasyMotion_use_migemo
	Enable g:EasyMotion_enter_jump_first
	map s <Plug>(easymotion-s)
	au vimrc VimEnter,BufEnter * EMCommandLineNoreMap <Space><Space> <Esc>
	"}}}

	" sandwich {{{
	let g:sandwich#recipes = deepcopy(g:sandwich#default_recipes)
	let g:sandwich#recipes += [
		\ {'buns': ["\r", ''  ], 'input': ["\r"], 'command': ["normal! i\r"]},
		\ {'buns': ['',   ''  ], 'input': ['q']},
		\ {'buns': ['「', '」'], 'input': ['k']},
		\ {'buns': ['>',  '<' ], 'input': ['>']},
		\ {'buns': ['{ ', ' }'], 'input': ['{']},
		\ {'buns': ['${', '}' ], 'input': ['${']},
		\ {'buns': ['CommentString(0)','CommentString(1)'], 'expr': 1, 'input': ['c']},
		\ ]
	function! CommentString(index) abort
		return get(split(&commentstring, '%s'), a:index, '')
	endfunction
	Enable g:sandwich_no_default_key_mappings
	Enable g:operator_sandwich_no_default_key_mappings
	NVmap Sd <Plug>(operator-sandwich-delete)<if-normal>as
	NVmap Sr <Plug>(operator-sandwich-replace)<if-normal>as
	NVmap Sa <Plug>(operator-sandwich-add)<if-normal>iw
	NVmap S  <Plug>(operator-sandwich-add)<if-normal>iw
	nmap SD <Plug>(operator-sandwich-delete)<if-normal>ab
	nmap SR <Plug>(operator-sandwich-replace)<if-normal>ab
	nmap S^ v^S
	nmap S$ vg_S
	nmap <expr> SS (matchstr(getline('.'), '[''"]', getpos('.')[2]) ==# '"') ? 'Sr"''' : 'Sr''"'

	" 改行で挟んだあとタブでインデントされると具合が悪くなるので…
	function! s:FixSandwichPos() abort
		let l:c = g:operator#sandwich#object.cursor
		if g:fix_sandwich_pos[1] != c.inner_head[1]
			let l:c.inner_head[2] = match(getline(c.inner_head[1]), '\S') + 1
			let l:c.inner_tail[2] = match(getline(c.inner_tail[1]), '$') + 1
		endif
	endfunction
	au vimrc User OperatorSandwichAddPre let g:fix_sandwich_pos = getpos('.')
	au vimrc User OperatorSandwichAddPost call <SID>FixSandwichPos()

	" 内側に連続で挟むやつ
	function! s:RemarkPatty() abort
		call setpos("'<", g:operator#sandwich#object.cursor.inner_head)
		call setpos("'>", g:operator#sandwich#object.cursor.inner_tail)
	endfunction
	nmap <silent> S. :<C-u>call <SID>RemarkPatty()<CR>gvSa

	function! s:BigMac(...) abort
		let l:c = a:0 ? g:operator#sandwich#object.cursor.inner_head[1:2] : []
		if ! a:0 || s:big_mac_crown != l:c
			let s:big_mac_crown = l:c
			au vimrc User OperatorSandwichAddPost ++once call <SID>BigMac(1)
			call feedkeys(a:0 ? 'S.' : 'gvSa')
		end
	endfunction
	nmap Sm viwSm
	vmap <silent> Sm :<C-u>call <SID>BigMac()<CR>

	" 行末空白と空行を削除
	function! s:RemoveAirBuns() abort
		let l:c = g:operator#sandwich#object.cursor
		call s:RemoveEmptyLine(l:c.tail[1])
		call s:RemoveEmptyLine(l:c.head[1])
	endfunction
	au vimrc User OperatorSandwichDeletePost call <SID>RemoveAirBuns()
	"}}}

	" MRU {{{
	function! s:MRUwithNumKey(tab) abort
		setlocal number
		echoh Question
		echo printf('[1]..[9] => open with a %s.', a:tab ? 'tab' : 'window')
		echoh None
		redraw
		let l:key = a:tab ? 't' : '<CR>'
		for l:i in range(1, 9)
			execute printf('nmap <buffer> <silent> %d :<C-u>%d<CR>%s', l:i, l:i, l:key)
		endfor
	endfunction
	function! s:MyMRU() abort
		let l:open_with_tab = s:BufIsSmth()
		MRU
		nnoremap <buffer> f <C-f>
		nnoremap <buffer> b <C-b>
		nnoremap <buffer> <silent> <F2> :<C-u>echo ''<CR>:q<CR>
		nnoremap <buffer> <silent> w :<C-u>call <SID>MRUwithNumKey(0)<CR>
		nnoremap <buffer> <silent> T :<C-u>call <SID>MRUwithNumKey(1)<CR>
		call s:MRUwithNumKey(l:open_with_tab)
	endfunction
	nnoremap <silent> <F2> :<C-u>call <SID>MyMRU()<CR>
	"}}}

	" 補完 {{{
	inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
	inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
	inoremap <expr> <CR>    pumvisible() ? "\<C-y>" : "\<CR>"
	function! s:RegisterSource(name, white, black) abort
		" とても長い
		execute printf("call asyncomplete#register_source(asyncomplete#sources#%s#get_source_options({ 'name': '%s', 'whitelist': %s, 'blacklist': %s, 'completor': function('asyncomplete#sources#%s#completor') }))", a:name, a:name, a:white, a:black, a:name)
	endfunction
	call s:RegisterSource('omni', ['*'], ['c', 'cpp', 'html'])
	call s:RegisterSource('buffer', ['*'], ['go'])

	" Expand
	imap <expr> JJ   vsnip#expandable() ? '<Plug>(vsnip-expand)'         : 'JJ'
	smap <expr> JJ   vsnip#expandable() ? '<Plug>(vsnip-expand)'         : 'JJ'
	" Expand or jump
	imap <expr> <C-l>   vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
	smap <expr> <C-l>   vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
	" Jump forward or backward
	imap <expr> <Tab>   vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
	smap <expr> <Tab>   vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
	imap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
	smap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
	"}}}

	" 翻訳 {{{
	function! s:AutoTranslate(text)
		if matchstr(a:text, '[^\x00-\x7F]') ==# ''
			execute ':Translate ' . a:text
		else
			execute ':Translate! ' . a:text
		endif
	endfunction
	nnoremap <script> <Space>t :<C-u>call <SID>AutoTranslate(expand('<cword>'))<CR>
	vnoremap <script> <Space>t :<C-u>call <SID>AutoTranslate(<SID>GetVisualSelection())<CR>gv
	"}}}

	" ALE {{{
	let g:ale_sign_error = '🐞'
	let g:ale_sign_warning = '🐝'
	let g:ale_lint_on_insert_leave = 0
	let g:ale_fixers = {'typescript': ['deno']}
	let g:ale_fix_on_save = 1 " run deno fmt when saving a buffer
	let g:ale_set_loclist = 0
	let g:ale_set_quickfix = 1
	nmap <silent> [a <Plug>(ale_previous_wrap)
	nmap <silent> ]a <Plug>(ale_next_wrap)
	" }}}

	" lightline {{{
	" utf-8じゃないときだけエンコーディングを表示する
	function! g:LLNoUtf8() abort
		return &fenc !=# 'utf-8' ? &fenc : ''
	endfunction
	" yankの内容を表示する
	function! g:LLReg() abort
		let r = substitute(@", '[ \t\r\n]', ' ', 'g')
		return '📎[' . (len(r) <= 10 ? r : (substitute(r, '^\(.\{8\}\).*', '\1..', ''))) . ']'
	endfunction
	" 毎時45分から15分間休憩しようね
	function! g:LLTeaBreak() abort
		if !exists('g:opentime')
			let g:opentime = localtime()
		endif
		let tick = (localtime() - g:opentime) / 60
		let mm = tick % 60
		let tea = mm >= 45 ? '☕🍴🍰' : ''
		return tea . printf('%d:%02d', tick / 60, mm)
	endfunction
	function! g:VimrcTimer60s(timer) abort
		call lightline#update()
	endfunction
	if exists('g:vimrc_timer_60s')
		call timer_stop(g:vimrc_timer_60s)
	endif
	let g:vimrc_timer_60s = timer_start(60000, 'VimrcTimer60s', { 'repeat': -1 })
	" lightline
	let g:lightline = {
		\ 'colorscheme': 'wombat',
		\ 'active': { 'right': [['teabreak'],['fileformat', 'noutf8', 'lineinfo'],['reg']] },
		\ 'component_function': { 'teabreak': 'LLTeaBreak', 'reg': 'LLReg', 'noutf8': 'LLNoUtf8' }
		\ }
	" }}}

	" その他 {{{
	Enable g:rainbow_active
	let g:rcsv_colorpairs = [['105', '#9999ee',], ['120', '#99ee99'], ['212', '#ee99cc'], ['228', '#eeee99'], ['177', '#cc99ee'], ['117', '#99ccee']]
	NVmap <Space>c <Plug>(caw:hatpos:toggle)
	nnoremap <silent> <F1> :<C-u>NERDTreeTabsToggle<CR>
	nnoremap <silent> <Space><F1> :<C-u>tabe ./<CR>
	let g:nerdtree_tabs_autofind = 1
	Enable g:undotree_SetFocusWhenToggle
	Disable g:undotree_DiffAutoOpen
	nnoremap <silent> <F3> :<C-u>silent! UndotreeToggle<cr>
	let g:move_key_modifier = 'C'
	nmap <silent> <C-w><C-s> <Plug>(shrink-height)<C-w>w
	tmap <silent> <C-w><C-s> <Plug>(shrink-height)<C-w>w
	nmap <silent> <C-w><C-h> <Plug>(shrink-width)<C-w>w
	tmap <silent> <C-w><C-h> <Plug>(shrink-width)<C-w>w
	"}}}
endif
filetype plugin indent on
"}}} -------------------------------------------------------

" ----------------------------------------------------------
" コピペ寄せ集め色々 {{{
au vimrc InsertLeave * set nopaste
au vimrc BufReadPost *.log* normal! G
nnoremap <silent> <C-c> o<Esc>
vnoremap <silent> * "vy/\V<C-r>=substitute(escape(@v,'\/'),"\n",'\\n','g')<CR><CR>
xnoremap . :normal! .<CR>
inoremap kj <Esc>`^
inoremap kk <Esc>`^
" https://github.com/junegunn/dotfiles/master/vimrc
inoremap <C-h> <C-o>h
inoremap <C-k> <C-o>k
inoremap <C-^> <C-o><C-^>
" http://deris.hatenablog.jp/entry/2014/05/20/235807
nnoremap gs :<C-u>%s///g<Left><Left><Left>
vnoremap gs :s///g<Left><Left><Left>
xnoremap Y "+y
" https://github.com/astrorobot110/myvimrc/blob/master/vimrc
set matchpairs+=（:）,「:」,『:』,【:】,［:］,＜:＞
"}}} -------------------------------------------------------

" ----------------------------------------------------------
" 色 {{{
set t_Co=256
function! s:MyColorScheme() abort
	hi! link Folded Delimiter
	hi CursorLine NONE
endfunction
au vimrc ColorScheme * call <SID>MyColorScheme()
function! s:MyMatches() abort
	if exists('w:my_matches') && len(getmatches())
		return
	end
	let w:my_matches = 1
	call matchadd('SpellBad', '　\|¥\|\s\+$')
	call matchadd('String', '「[^」]*」')
	call matchadd('Label', '^\s*■.*$')
	call matchadd('Delimiter', 'WARN|注意\|注:\|[★※][^\s()（）]*')
	call matchadd('Error', 'ERROR')
	call matchadd('Delimiter', '- \[ \]')
	" 稀によくtypoする単語(気づいたら追加する)
	call matchadd('SpellBad', 'stlye')
endfunction
au vimrc VimEnter,WinEnter * call <SID>MyMatches()
syntax on
set background=dark
colorscheme utb
"}}} -------------------------------------------------------

" ----------------------------------------------------------
" タブ幅やタブ展開を自動設定 {{{
function! s:SetupTabstop() abort
	const l:limit = 100
	const l:org = getpos('.')
	call cursor(1, 1)
	if search('^\t', 'nc', l:limit)
		setlocal noexpandtab
		setlocal tabstop=3 " 意外とありな気がしてきた…
	elseif search('^  \S', 'nc', l:limit)
		setlocal expandtab
		setlocal tabstop=2
	elseif search('^    \S', 'nc', l:limit)
		setlocal expandtab
		setlocal tabstop=4
	endif
	call setpos('.', l:org)
endfunction
au vimrc BufRead * call <SID>SetupTabstop()
"}}}

" ----------------------------------------------------------
" vimgrep {{{
function! s:MyVimgrep(keyword, ...) abort
	let l:path = join(a:000, ' ')
	" パスを省略した場合は、同じ拡張子のファイルから探す
	if empty(l:path)
		let l:path = expand('%:e') ==# '' ? '*' : ('*.' . expand('%:e'))
	endif
	" 適宜タブで開く(ただし明示的に「%」を指定したらカレントで開く)
	let l:open_with_tab = s:BufIsSmth() && l:path !=# '%'
	if l:open_with_tab
		tabnew
	endif
	" lvimgrepしてなんやかんやして終わり
	silent! execute printf('lvimgrep %s %s', a:keyword, l:path)
	if ! empty(getloclist(0))
		lwindow
	else
		echoh ErrorMsg
		echomsg 'Not found.: ' . a:keyword
		echoh None
		if l:open_with_tab
			tabnext -
			tabclose +
		endif
	endif
endfunction
command! -nargs=+ MyVimgrep call <SID>MyVimgrep(<f-args>)
nnoremap <Space>/ :<C-u>MyVimgrep<Space>

function! s:MyQuickFixWindow() abort
	nnoremap <buffer> <silent> ; <CR>:silent! normal! zv<CR><C-W>w
	nnoremap <buffer> <silent> w <C-W><CR>:silent! normal! zv<CR><C-W>w
	nnoremap <buffer> <silent> t <C-W><CR>:silent! normal! zv<CR><C-W>T
	nnoremap <buffer> <silent> <nowait> q :<C-u>q<CR>:lexpr ''<CR>
	nnoremap <buffer> f <C-f>
	nnoremap <buffer> b <C-b>
	" 様子見中(使わなそうなら削除する)
	execute printf('nnoremap <buffer> T <C-W><CR><C-W>T%dgt', tabpagenr())
endfunction
au vimrc FileType qf call s:MyQuickFixWindow()
au vimrc WinEnter * if winnr('$') == 1 && &buftype ==# 'quickfix' | q | endif
"}}} -------------------------------------------------------

" ----------------------------------------------------------
" diff {{{
set splitright
set fillchars+=diff:\ " 削除行は空白文字で埋める
command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis
nnoremap <F4> :<C-u>DiffOrig<CR>
" diffモードを自動でoff https://hail2u.net/blog/software/vim-turn-off-diff-mode-automatically.html
au vimrc WinEnter * if (winnr('$') == 1) && (getbufvar(winbufnr(0), '&diff')) == 1 | diffoff | endif
"}}} -------------------------------------------------------

" ----------------------------------------------------------
" 日付関係 {{{
inoremap <F5> <C-r>=strftime('%Y/%m/%d')<CR>
cnoremap <F5> <C-r>=strftime('%Y%m%d')<CR>
nnoremap <silent> <F5> :<C-u>call reformatdate#reformat(localtime())<CR>
nnoremap <silent> <C-a> <C-a>:call reformatdate#reformat()<CR>
nnoremap <silent> <C-x> <C-x>:call reformatdate#reformat()<CR>
nnoremap <Space><F5> /\d\{4\}\/\d\d\/\d\d<CR>
"}}} -------------------------------------------------------

" ----------------------------------------------------------
" スマホ用キーバインド {{{
" ・キーが小さいので押しにくいものはSpaceへマッピング
" ・スマホでのコーディングは基本的にバグ取り
nnoremap <Space>zz :<C-u>q!<CR>
" スタックトレースからyankしてソースの該当箇所を探すのを補助
nnoremap <Space>e G?\cErr\\|Exception<CR>
nnoremap <Space>y yiw
nnoremap <expr> <Space>n (@" =~ '^\d\+$' ? ':' : '/').@"."\<CR>"
"}}} -------------------------------------------------------

" ----------------------------------------------------------
" インデントが現在行以下の行まで移動 {{{
function! s:FindSameIndent(flags, inner = 0) abort
	let l:size = len(s:IndentStr('.'))
	let l:pattern = printf('^\s\{0,%d\}\S', l:size)
	call setpos('.', [0, getpos('.')[1], 1, 1])
	return search(l:pattern, a:flags) + a:inner
endfunction
noremap <expr> <Space>[ <SID>FindSameIndent('bW').'G'
noremap <expr> <Space>] <SID>FindSameIndent('W').'G'
noremap <expr> <Space>i[ <SID>FindSameIndent('bW', 1).'G'
noremap <expr> <Space>i] <SID>FindSameIndent('W', -1).'G'
"}}} -------------------------------------------------------

" ----------------------------------------------------------
" カーソルを行頭に合わせて移動 {{{
function! s:PutHat() abort
	let l:x = match(getline('.'), '\S.') + 1
	if l:x || !exists('w:my_hat')
		let w:my_hat = col('.') == l:x ? '^' : ''
	endif
	return w:my_hat
endfunction
nnoremap <expr> j 'j'.<SID>PutHat()
nnoremap <expr> k 'k'.<SID>PutHat()
"}}} -------------------------------------------------------

" ----------------------------------------------------------
" 折り畳み {{{
" こんなかんじでインデントに合わせて表示... {{{
function! MyFoldText() abort
	let l:src = getline(v:foldstart)
	let l:indent = repeat(' ', indent(v:foldstart))
	let l:text = &foldmethod ==# 'indent' ? '' : trim(substitute(l:src, matchstr(&foldmarker, '^[^,]*'), '', ''))
	return l:indent . l:text . '...'
endfunction
set foldtext=MyFoldText()
set fillchars+=fold:\ " 折り畳み時の「-」は半角空白
set foldmethod=marker
nnoremap <expr> h (col('.') == 1 && 0 < foldlevel('.') ? 'zc' : 'h')
nnoremap Z<Tab> :<C-u>set foldmethod=indent<CR>
nnoremap Z{ :<C-u>set foldmethod=marker<CR>
nnoremap Zy :<C-u>set foldmethod=syntax<CR>
au vimrc filetype markdown,yaml setlocal foldlevelstart=99 | setlocal foldmethod=indent
"}}}
" マーカーの前にスペース、後ろに改行を入れる {{{
function! s:Zf() range abort
	execute a:firstline 's/\v(\S)?$/\1 /'
	execute a:lastline "normal! o\<Esc>i" . s:IndentStr(a:firstline)
	call cursor([a:firstline, 1])
	normal! V
	call cursor([a:lastline + 1, 1])
	normal! zf
endfunction
vnoremap <silent> zf :call <SID>Zf()<CR>
"}}}
" マーカーを削除したら行末をトリムする {{{
function! s:Zd() abort
	if foldclosed(line('.')) == -1
		normal! zc
	endif
	const l:head = foldclosed(line('.'))
	const l:tail = foldclosedend(line('.'))
	if l:head == -1
		return
	endif
	const l:org = getpos('.')
	normal! zd
	call s:RemoveEmptyLine(l:tail)
	call s:RemoveEmptyLine(l:head)
	call setpos('.', l:org)
endfunction
nnoremap <silent> zd :call <SID>Zd()<CR>
"}}}
"}}} -------------------------------------------------------

" ----------------------------------------------------------
" コマンドモードあれこれ {{{
cnoremap <C-h> <Space><BS><Left>
cnoremap <C-l> <Space><BS><Right>
cnoremap <C-r><C-r> <C-r>=trim(@")<CR>
nnoremap q: :q
nnoremap q; q:
nnoremap ; :
vnoremap ; :
nnoremap <Space>; ;
cnoreabbrev cs colorscheme
cnoreabbrev gv Gvdiffsplit

" 「jj」で<CR>、「kk」はキャンセル
" ただし保存は片手で「;jj」でもOK(「;wjj」じゃなくていい)
cnoremap kk <C-c>
cnoremap <expr> jj (empty(getcmdline()) ? 'update<CR>' : '<CR>')
inoremap ;jj <Esc>`^:update<CR>

"}}} -------------------------------------------------------

" ----------------------------------------------------------
" terminalとか {{{
if has('win32')
	command! Powershell :bo terminal ++close pwsh
	nnoremap <silent> SH :<C-u>Powershell<CR>
	nnoremap <silent> <S-F1> :<C-u>silent !start explorer %:p:h<CR>
else
	nnoremap <silent> SH :<C-u>bo terminal<CR>
endif
tnoremap <C-w>; <C-w>:
tnoremap <C-w><C-w> <C-w>w
"}}} -------------------------------------------------------

" ----------------------------------------------------------
" markdownのチェックボックス {{{
function! s:ToggleCheckBox() range abort
	for l:n in range(a:firstline, a:lastline)
		let l:a = getline(l:n)
		let l:b = substitute(l:a, '^\(\s*\)- \[ \]', '\1- [x]', '') " check on
		if l:a ==# l:b
			let l:b = substitute(l:a, '^\(\s*\)- \[x\]', '\1- [ ]', '') " check off
		endif
		if l:a ==# l:b
			let l:b = substitute(l:a, '^\(\s*\)\(- \)*', '\1- [ ] ', '') " a new check box
		endif
		if l:a !=# l:b
			call setline(l:n, l:b)
		endif
	endfor
endfunction
noremap <silent> <Space>x :call <SID>ToggleCheckBox()<CR>
"}}} -------------------------------------------------------

" ----------------------------------------------------------
" その他細々したの {{{
if has('clipboard')
	autocmd vimrc FocusGained * let @" = @+
	autocmd vimrc FocusLost   * let @+ = @"
endif
nnoremap <silent> <F11> :<C-u>set number! \| let &cursorline=&number<CR>
nnoremap <silent> <F12> :<C-u>set wrap! wrap?<CR>
nnoremap <silent> <Space><Space> :<C-u>noh<CR>
nnoremap <expr> g: ":\<C-u>".substitute(getline('.'), '^[\t ":]\+', '', '')."\<CR>"
vnoremap g: "vy:<C-r>=@v<CR><CR>
nnoremap Y y$
nnoremap <Space>p $p
nnoremap <Space>P ^P
nnoremap <Space><Space>p o<C-r>"<Esc>
nnoremap <Space><Space>P O<C-r>"<Esc>
nnoremap <silent> qq :<C-u>confirm q<CR>
onoremap <expr> } '<Esc>m`0' . v:count1 . v:operator . '}``'
onoremap <expr> { '<Esc>m`V' . v:count1 . '{' . v:operator . '``'
vnoremap <expr> h mode() ==# 'V' ? "\<Esc>h" : 'h'
vnoremap <expr> l mode() ==# 'V' ? "\<Esc>l" : 'l'
vnoremap J j
vnoremap K k
inoremap <C-r><C-r> <C-r>"
inoremap ｋｊ <Esc>`^
inoremap 「 「」<Left>
inoremap 「」 「」<Left>
inoremap （ ()<Left>
inoremap （） ()<Left>
"}}} -------------------------------------------------------

" ----------------------------------------------------------
" 様子見中 {{{
" 使わなそうなら削除する
inoremap <CR> <CR><C-g>u
vnoremap <expr> p '"_s<C-R>' . v:register . '<ESC>'
vnoremap P p
nnoremap <Space>h ^
nnoremap <Space>l $
nnoremap <Space>a A
nnoremap TE :<C-u>tabe<Space>
nnoremap TN :<C-u>tabnew<CR>
nnoremap gS :<C-u>%s/<C-r>"//g<Left><Left>
vnoremap gS :s/<C-r>"//g<Left><Left>
nnoremap g* yiw:<C-u>%s/<C-r>0//g<Left><Left>
nnoremap <Space>d "_d

" どっちも<C-w>w。左手オンリーと右手オンリーのマッピング
nnoremap <Space>w <C-w>w
nnoremap <Space>o <C-w>w

" 一部qを潰しちゃうけど…
function s:Quit()
	if mode() ==# 't'
		execute 'quit!'
	else
		execute 'confirm quit'
	endif
endfunction
nnoremap <silent> qh <C-w>h<C-w>:<C-u>call <SID>Quit()<CR>
nnoremap <silent> qj <C-w>j<C-w>:<C-u>call <SID>Quit()<CR>
nnoremap <silent> qk <C-w>k<C-w>:<C-u>call <SID>Quit()<CR>
nnoremap <silent> ql <C-w>l<C-w>:<C-u>call <SID>Quit()<CR>

" CSVとかのヘッダを固定表示する。ファンクションキーじゃなくてコマンド定義すればいいかな…
nnoremap <silent> <F10> <ESC>1<C-w>s:1<CR><C-w>w
vnoremap <F10> <ESC>1<C-w>s<C-w>w

" https://github.com/justinmk/config/blob/master/.config/nvim/init.vim
inoremap {; {<CR>};<C-o>O
inoremap {, {<CR>},<C-o>O
inoremap [; [<CR>];<C-o>O
inoremap [, [<CR>],<C-o>O

" 実はTabキーでインデント増減するのは>.や<.より指が動く距離短いのでは…？
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv
vnoremap u <ESC>ugv

" 分割キーボードで右手親指が<CR>になったので…
nmap <CR> <Space>

" うーん…
inoremap jjx <C-o>:call <SID>ToggleCheckBox()<CR>
inoremap jj; <C-o>$;
inoremap jj, <C-o>$,
inoremap jj{ <C-o>$ {
inoremap jj} <C-o>$ }
inoremap jj<CR> <C-o>$<CR>
inoremap jjl <Esc>ea
inoremap jjk 「」<Left>

au vimrc FileType javascript inoremap <buffer> <expr> = match(getline('.'), '^.*\<if\s*(') ? '=' : '=== '
au vimrc FileType javascript inoremap <buffer> != !==<Space>

" これするともっといらっとするよ
"nnoremap <F1> :<C-u>smile<CR>

" あともう1回「これ使ってないな…」と思ったときに消す
nnoremap <silent> <F8> :<C-u>q<CR>
nnoremap <F9> <C-w>w
nnoremap <S-F9> <C-w>W

"}}} -------------------------------------------------------

" ----------------------------------------------------------
" デフォルトマッピングデー {{{
if strftime('%d') ==# '01'
	au vimrc VimEnter * echo "+^`^+.,.+ Today, Let's enjoy VIM with default key mapping ! +^`^+.,.+"
	imapclear
	mapclear
endif
"}}} -------------------------------------------------------

" ----------------------------------------------------------
" メモ {{{
" <F1> NERDTree <S-F1>でフォルダを開く(win32)
" <F2> MRU
" <F3> UndoTree
" <F4> DiffOrig
" <F5> 日付関係
" <F6>
" <F7>
" <F8>
" <F9> ウィンドウ切替(様子見中)
" <F10> ヘッダ行を表示(様子見中)
" <F11> 行番号表示切替
" <F12> 折り返し表示切替
"}}}

if filereadable(expand('~/.vimrc_local'))
	source ~/.vimrc_local
endif

