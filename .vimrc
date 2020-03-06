set encoding=utf-8
scriptencoding utf-8

" ----------------------------------------------------------
" 基本設定 {{{
set fileencodings=iso-2022-jp,ucs-bom,cp932,sjis,euc-jp,utf-8
set backupskip=/var/tmp/*
set autochdir
set noexpandtab
set tabstop=4
set shiftwidth=0
set autoindent
set smartindent
set breakindent
set nf=alpha,hex
set virtualedit=block
set list
set listchars=tab:\|\ ,trail:-,extends:>,precedes:<,nbsp:%
set hlsearch
nohlsearch
set laststatus=2
set ruler
set display=lastline
set ambiwidth=double
set belloff=all
set ttimeoutlen=50
set wildmenu

augroup vimrc
	au!
augroup End
"}}} ------------------------------------------------------

" ----------------------------------------------------------
" ユーティリティ {{{
" 「nmap <agrs>|vmap <agrs>」と同じ。
" 引数の「<if-normal>」から行末までは「nmap」だけに適用する。
command! -nargs=* NVmap execute 'nmap ' . substitute(<q-args>, '<if-normal>', '', '') | execute 'vmap ' . substitute(<q-args>, '<if-normal>.*', '', '')
"}}}

" ----------------------------------------------------------
" プラグイン {{{
let s:dein_dir = expand('~/.vim/dein')
let s:dein_vim = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
if isdirectory(s:dein_vim)
	" dein {{{
	let &runtimepath = s:dein_vim . ',' . &runtimepath
	call dein#begin(s:dein_dir)
	call dein#add('Lokaltog/vim-easymotion')
	call dein#add('Shougo/dein.vim')
	call dein#add('alvan/vim-closetag')
	call dein#add('itchyny/lightline.vim')
	call dein#add('jceb/vim-hier')
	call dein#add('jiangmiao/auto-pairs')
	call dein#add('kana/vim-textobj-user')
	call dein#add('luochen1990/rainbow')
	call dein#add('machakann/vim-sandwich')
	call dein#add('mattn/jscomplete-vim', {'lazy':1, 'on_ft':'javascript'})
	call dein#add('mbbill/undotree')
	call dein#add('mechatroner/rainbow_csv')
	call dein#add('osyo-manga/shabadou.vim')
	call dein#add('osyo-manga/vim-monster', {'lazy':1, 'on_ft':'ruby'})
	call dein#add('osyo-manga/vim-textobj-multiblock')
	call dein#add('osyo-manga/vim-watchdogs')
	call dein#add('rhysd/github-complete.vim')
	call dein#add('scrooloose/nerdtree')
	call dein#add('thinca/vim-portal')
	call dein#add('thinca/vim-quickrun')
	call dein#add('tyru/caw.vim')
	call dein#add('utubo/vim-reformatdate', {'lazy':1, 'on_cmd':'reformatdate#reformat'})
	call dein#add('utubo/vim-textobj-twochars')
	call dein#add('utubo/vim-utb')
	call dein#add('yegappan/mru')
	" vimproc
	if has('win32')
		let g:vimproc#download_windows_dll = 1
		call dein#add('Shougo/vimproc')
	else
		call dein#add('Shougo/vimproc', {'build': 'make'})
	endif
	call dein#end()
	"}}}

	" easymotion {{{
	let g:EasyMotion_do_mapping = 0
	let g:EasyMotion_smartcase = 1
	let g:EasyMotion_use_migemo = 1
	let g:EasyMotion_enter_jump_first = 1
	map s <Plug>(easymotion-s)
	au vimrc VimEnter,BufEnter * EMCommandLineNoreMap <Space><Space> <Esc>
	"}}}

	" undotree {{{
	if has("persistent_undo")
		set undodir='~/.undodir/'
		set undofile
		let g:undotree_TreeNodeShape = 'o'
		let g:undotree_SetFocusWhenToggle = 1
		let g:undotree_DiffAutoOpen = 0
		nnoremap <silent> <F3> :<C-u>silent! UndotreeToggle<cr>
	endif
	"}}}

	" watchdogs {{{
	let g:watchdogs_check_BufWritePost_enable = 1
	let g:watchdogs_check_CursorHold_enable = 1
	"}}}

	" sandwitch {{{
	let g:sandwich#recipes = deepcopy(g:sandwich#default_recipes)
	let g:sandwich#recipes += [{'buns': ['「', '」'],'input': ['k']}] " kagikakko
	let g:sandwich_no_default_key_mappings = 1
	let g:operator_sandwich_no_default_key_mappings = 1
	NVmap Sd <Plug>(operator-sandwich-delete)<if-normal><Plug>(textobj-sandwich-query-a)
	NVmap Sr <Plug>(operator-sandwich-replace)<if-normal><Plug>(textobj-sandwich-query-a)
	NVmap Sa <Plug>(operator-sandwich-add)
	NVmap S <Plug>(operator-sandwich-add)<if-normal>iw
	nmap SD <Plug>(operator-sandwich-delete)<Plug>(textobj-sandwich-auto-a)
	nmap SR <Plug>(operator-sandwich-replace)<Plug>(textobj-sandwich-auto-a)
	nmap <expr> SS (matchstr(getline('.'), '[''"]', getpos('.')[2]) == '"') ? 'Sr"''' : 'Sr''"'
	" メモ
	" i:都度入力, t:タグ, k:鍵括弧
	"}}}

	" MRU {{{
	function! s:MRUwithNumKey(tab)
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
	function! s:MyMRU()
		let l:is_numkey_open_tab = &modified || expand('%') != ''
		MRU
		nnoremap <buffer> <F2> <nop>
		nnoremap <buffer> f <C-f>
		nnoremap <buffer> b <C-b>
		nnoremap <silent> <buffer> w :<C-u>call <SID>MRUwithNumKey(0)<CR>
		nnoremap <silent> <buffer> T :<C-u>call <SID>MRUwithNumKey(1)<CR>
		call s:MRUwithNumKey(l:is_numkey_open_tab)
	endfunction
	nnoremap <silent> <F2> :<C-u>call <SID>MyMRU()<CR>
	" }}}

	" その他 {{{
	let g:lightline = { 'colorscheme': 'wombat' }
	let g:rainbow_active = 1
	let g:rcsv_colorpairs = [['105', '#9999ee',], ['120', '#99ee99'], ['212', '#ee99cc'], ['228', '#eeee99'], ['177', '#cc99ee'], ['117', '#99ccee']]
	au vimrc FileType javascript setlocal omnifunc=jscomplete#CompleteJS
	call textobj#user#map('multiblock', {'-': {'select-a': 'ab', 'select-i': 'ib'}})
	let g:textobj_multiblock_blocks = [ ['>', '<'], ['「', '」'] ]
	NVmap <Space>c <Plug>(caw:hatpos:toggle)
	nnoremap <silent> <F1> :<C-u>NERDTreeToggle<CR>
	"}}}
endif
filetype plugin indent on
"}}} ------------------------------------------------------

" ↓ここからしばらくコピペ寄せ集め

" ----------------------------------------------------------
" Movement in insert mode {{{
" https://github.com/junegunn/dotfiles/blob/dbeddfce1bd1975e499984632191d2d1ec080e25/vimrc からコピペ
inoremap <C-h> <C-o>h
inoremap <C-l> <C-o>a
inoremap <C-j> <C-o>j
inoremap <C-k> <C-o>k
inoremap <C-^> <C-o><C-^>
"}}} ------------------------------------------------------

" ----------------------------------------------------------
" DIFF関係 {{{
set splitright
set diffopt=vertical,filler
command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis
nnoremap <F4> :<C-u>DiffOrig<CR>
" DIFFモードを自動でOFF https://hail2u.net/blog/software/vim-turn-off-diff-mode-automatically.html
au vimrc WinEnter * if (winnr('$') == 1) && (getbufvar(winbufnr(0), '&diff')) == 1 | diffoff | endif
"}}} ------------------------------------------------------

" ---------------------------------------------------------
" その他パクリ {{{
au vimrc InsertLeave * set nopaste
au vimrc BufReadPost *.log* normal! G
nnoremap <silent> <C-c> o<Esc>
vnoremap <silent> * "vy/\V<C-r>=substitute(escape(@v,'\/'),"\n",'\\n','g')<CR><CR>
xnoremap . :normal! .<CR>
inoremap kj <Esc>`^
inoremap kk <Esc>`^
" http://deris.hatenablog.jp/entry/2014/05/20/235807
nnoremap gs :<C-u>%s///g<Left><Left><Left>
vnoremap gs :s///g<Left><Left><Left>
xnoremap Y "+y
" https://github.com/astrorobot110/myvimrc/blob/master/vimrc
set matchpairs+=（:）,「:」,『:』,【:】,［:］,＜:＞
"}}} ------------------------------------------------------

" ↑ここまでコピペ寄せ集め

" ---------------------------------------------------------
" 色 {{{
set t_Co=256
function! s:MyColorScheme()
	hi! link Folded Comment
	hi CursorLine NONE
endfunction
au vimrc ColorScheme * call <SID>MyColorScheme()
function! s:MyMatches()
	if exists('w:my_matches') && len(getmatches())
		return
	end
	let w:my_matches = 1
	call matchadd('SpellBad', '　\|¥\|\s\+$')
	call matchadd('String', '「[^」]*」')
	call matchadd('Label', '^\s*■.*$')
	call matchadd('Delimiter', 'WARN|注意\|注:\|[★※][^\s()（）]*')
	call matchadd('Error', 'ERROR')
	" 稀によくtypoする単語(気づいたら追加する)
	call matchadd('SpellBad', 'stlye')
endfunction
au vimrc VimEnter,WinEnter * call <SID>MyMatches()
syntax on
set background=dark
colorscheme utb-green
"}}} ------------------------------------------------------

" ---------------------------------------------------------
" タブ幅やタブ展開を自動設定 {{{
function! s:SetupTabstop()
	const l:limit = 100
	const l:org = getpos('.')
	call cursor(1, 1)
	if search('^\t', 'nc', l:limit)
		setlocal noexpandtab
		setlocal tabstop=4
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

" ---------------------------------------------------------
" 日付関係 {{{
inoremap <F5> <C-r>=strftime('%Y/%m/%d')<CR>
cnoremap <F5> <C-r>=strftime('%Y%m%d')<CR>
nnoremap <silent> <F5> :<C-u>call reformatdate#reformat(localtime())<CR>
nnoremap <silent> <C-a> <C-a>:call reformatdate#reformat()<CR>
nnoremap <silent> <C-x> <C-x>:call reformatdate#reformat()<CR>
nnoremap <Space><F5> /\d\{4\}\/\d\d\/\d\d<CR>
"}}} ------------------------------------------------------

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
"}}} ------------------------------------------------------

" ---------------------------------------------------------
" 現在行と同じインデントまで移動 {{{
function! s:FindSameIndent(back)
	let l:indent_length = len(matchstr(getline('.'), '^\s*'))
	let l:pattern = printf('^\s\{0,%d\}\S', l:indent_length)
	return search(l:pattern, a:back ? 'bW' : 'W')
endfunction
noremap <expr> <Space>] <SID>FindSameIndent(0).'G'
noremap <expr> <Space>[ <SID>FindSameIndent(1).'G'
noremap <expr> <Space>i] (<SID>FindSameIndent(0) - 1).'G'
noremap <expr> <Space>i[ (<SID>FindSameIndent(1) + 1).'G'
"}}} ------------------------------------------------------

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
"}}} ------------------------------------------------------

" ---------------------------------------------------------
" テンプレート {{{
function! s:ReadTemplate()
	let l:filename = expand('~/.vim/template/'.&filetype.'.txt')
	if ! filereadable(l:filename)
		return
	endif
	execute '0r '.l:filename
	if search('<+CURSOR+>')
		normal! "_da>
	endif
	if col('.') == col('$') - 1
		startinsert!
	else
		startinsert
	endif
endfunction
au vimrc BufNewFile * call <SID>ReadTemplate()
"}}} ------------------------------------------------------

" ---------------------------------------------------------
" 折り畳み {{{
" こんなかんじでインデントに合わせて表示 [+] {{{
function! MyFoldText()
	let l:src = getline(v:foldstart)
	let l:indent = repeat(' ', strdisplaywidth(matchstr(l:src, '^\s*')))
	let l:text = &foldmethod == 'indent' ? '' : trim(substitute(l:src, matchstr(&foldmarker, '^[^,]*'), '', ''))
	return l:indent . l:text . '[+]'
endfunction
set foldtext=MyFoldText()
set fillchars=fold:\ " 折り畳み時の「-」を非表示(というか「\」の後の半角空白に置き換える)
set foldmethod=marker
nnoremap <expr> h (col('.') == 1 && 0 < foldlevel('.') ? 'zc' : 'h')
nnoremap Z<Tab> :<C-u>set foldmethod=indent<CR>
nnoremap Z{ :<C-u>set foldmethod=marker<CR>
nnoremap Zy :<C-u>set foldmethod=syntax<CR>
"}}}
" マーカーの前にスペース、後ろに改行を入れる {{{
function! s:Zf() range
	execute a:firstline 's/\v(\S)?$/\1 /'
	execute a:lastline 'normal! o'
	call cursor([a:firstline, 1])
	normal! V
	call cursor([a:lastline + 1, 1])
	normal! zf
endfunction
vnoremap <silent> zf :call <SID>Zf()<CR>
"}}}
" マーカーを削除したら行末をトリムする {{{
function! s:Zd()
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
	silent! execute l:tail . 's/\s\+$//'
	silent! execute l:tail . 's/^\s*\n//'
	silent! execute l:head . 's/\s\+$//'
	silent! execute l:head . 's/^\s*\n//'
	call setpos('.', l:org)
endfunction
nnoremap <silent> zd :call <SID>Zd()<CR>
"}}}
"}}} ------------------------------------------------------

" ---------------------------------------------------------
" 行移動 {{{
" オートインデント無し、折り畳みをスキップ
function! s:MoveLines(d) range
	let l:to = (a:d < 0 ? a:firstline : (a:lastline + 1)) + a:d
	let l:to = min([max([1, l:to]), line('w$') + 1])
	let l:foldstart = foldclosed(l:to)
	if l:foldstart != -1
		let l:to = a:d < 0 ? l:foldstart : (foldclosedend(l:to) + 1)
	endif
	execute printf('%d,%dmove%d', a:firstline, a:lastline, l:to - 1)
	let l:c = a:lastline - a:firstline + 1
	if l:c != 1
		normal! V
		call setpos('.', [0, a:d < 0 ? l:to : (l:to - l:c), 1])
	endif
endfunction
vnoremap <silent> <C-k> :call <SID>MoveLines(-1)<CR>
vnoremap <silent> <C-j> :call <SID>MoveLines(1)<CR>
nnoremap <silent> <C-k> :<C-u>call <SID>MoveLines(-v:count1)<CR>
nnoremap <silent> <C-j> :<C-u>call <SID>MoveLines(v:count1)<CR>
"}}} ------------------------------------------------------

" ---------------------------------------------------------
" コマンドモードあれこれ {{{
cnoremap <C-h> <Space><BS><Left>
cnoremap <C-l> <Space><BS><Right>
cnoremap kj <C-c>
cnoremap <C-r><C-r> <C-r>=trim(@")<CR>
nnoremap q: q:a
"}}} ------------------------------------------------------

" ---------------------------------------------------------
" terminal {{{
if has('win32')
	command! Powershell :terminal ++close powershell
endif
"}}} ------------------------------------------------------

" ---------------------------------------------------------
" やりすぎ注意 {{{
if exists('g:vimrc_tea_break')
	call timer_stop(g:vimrc_tea_break.timer)
else
	let g:vimrc_tea_break = { 'count': 0 }
endif
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
"}}} ------------------------------------------------------

" ---------------------------------------------------------
" その他細々したの {{{
nnoremap <silent> <F11> :<C-u>set number! \| let &cursorline=&number<CR>
nnoremap <silent> <F12> :<C-u>set wrap! wrap?<CR>
nnoremap <silent> <Space><Space> :<C-u>noh<CR>
nnoremap <expr> g: ":\<C-u>".substitute(getline('.'), '^[\t ":]\+', '', '')."\<CR>"
vnoremap g: "vy:<C-r>=@v<CR><CR>
nnoremap Y y$
nnoremap <Space>p $p
nnoremap <Space>P ^P
nnoremap SH :<C-u>terminal<CR>
onoremap <expr> } '<Esc>m`0' . v:count1 . v:operator . '}``'
onoremap <expr> { '<Esc>m`V' . v:count1 . '{' . v:operator . '``'
vnoremap <expr> h mode() ==# 'V' ? "\<Esc>h" : 'h'
vnoremap <expr> l mode() ==# 'V' ? "\<Esc>l" : 'l'
inoremap <C-r><C-r> <C-r>"
inoremap ｋｊ <Esc>`^
inoremap 「 「」<Left>
inoremap 「」 「」<Left>
inoremap （ ()<Left>
inoremap （） ()<Left>
inoremap <S-Tab> <Esc>ea
" Input-Modeでも :w で書き込み
" どうしても「:w」を入力したい場合は ::<BS>w とかで頑張る
inoremap :w <Esc>`^:w
inoremap :: ::
inoremap <silent> <F1> <C-r>=nr2char(getchar())<CR>
"}}} ------------------------------------------------------

" ---------------------------------------------------------
" 様子見中 {{{
" 使わなそうなら削除する
inoremap <CR> <CR><C-g>u
vnoremap <expr> <Space>p '"_s<C-R>' . v:register . '<ESC>'
nnoremap <Space>w <C-w>w
nnoremap <Space>l $
nnoremap <Space>a A
nnoremap <silent> <F8> :<C-u>q<CR>
nnoremap <F9> <C-w>w
nnoremap <silent> <F10> <ESC>1<C-w>s:1<CR><C-w>w
vnoremap <F10> <ESC>1<C-w>s<C-w>w
tnoremap <C-k><C-k> <C-w>N

" https://github.com/justinmk/config/blob/master/.config/nvim/init.vim
inoremap {; {<CR>};<Esc>O
inoremap {, {<CR>},<Esc>O
inoremap [; [<CR>];<Esc>O
inoremap [, [<CR>],<Esc>O
"}}} ------------------------------------------------------

" ---------------------------------------------------------
" デフォルトマッピングデー {{{
if strftime('%d') == '01'
	au vimrc VimEnter * echo "+^`^+.,.+ Today, Let's enjoy VIM with default key mapping ! +^`^+.,.+"
	imapclear
	mapclear
endif
"}}} ------------------------------------------------------

" ---------------------------------------------------------
" メモ {{{
" <F1> N→NERDTree, I→マッピングを無視して1文字入力
" <F2> MRU
" <F3> UndoTree
" <F4> DiffOrig
" <F5> 日付関係
" <F6> 時刻関係
" <F7>
" <F8> :q(様子見中)
" <F9> ウィンドウ切替(様子見中)
" <F10> ヘッダ行を表示(様子見中)
" <F11> 行番号表示切替
" <F12> 折り返し表示切替
" ※「構文等のインデントはタブ、見た目の桁合わせは半角スペース」なのでキモインデントになってる所があるかも…ごめんなさい
"}}}

