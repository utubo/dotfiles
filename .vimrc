vim9script
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
	# 新しい自由
	au!
augroup End
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# ユーティリティ {{{

# こんな感じ
# MultiCmd nmap,vmap xxx yyy<if-nmap>NNN<if-vmap>VVV<>zzz
# ↓
# nmap xxx yyyNNNzzz | vmap xxx yyyVVVzzz
def s:MultiCmd(qargs: string)
	const q = qargs->substitute('^\S*', '', '')
	for cmd in qargs->matchstr('^\S*')->split(',')
		var a = q
			->substitute('<if-' .. cmd .. '>', '<>', 'g')
			->substitute('<if-.\{-1,}\(<if-\|<>\|$\)', '', 'g')
			->substitute('<>', '', 'g')
		execute cmd .. a
	endfor
enddef
command! -nargs=* MultiCmd s:MultiCmd(<q-args>)

# その他
command! -nargs=1 -complete=var Enable  <args> = 1
command! -nargs=1 -complete=var Disable <args> = 0

def s:RemoveEmptyLine(line: number)
	execute 'silent! ' .. line .. 's/\s\+$//'
	execute 'silent! ' .. line .. 's/^\s*\n//'
enddef

def s:BufIsSmth(): bool
	return &modified || ! empty(bufname())
enddef

def s:IndentStr(expr: any): string
	return matchstr(getline(expr), '^\s*')
enddef

def s:GetVisualSelection(): string
	const org = @"
	silent normal! gvy
	const text = @"
	@" = org
	return text
enddef

var s:has_deno = executable('deno')
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# プラグイン {{{
var s:dein_dir = expand('~/.cache/dein')
var s:dein_vim = s:dein_dir .. '/repos/github.com/Shougo/dein.vim'
if isdirectory(s:dein_vim)
	# dein {{{
	&runtimepath = s:dein_vim .. ',' .. &runtimepath
	dein#begin(s:dein_dir)
	dein#add('Shougo/dein.vim')
	dein#add('airblade/vim-gitgutter')
	dein#add('alvan/vim-closetag')
	dein#add('cohama/lexima.vim')      # 括弧補完
	dein#add('delphinus/vim-auto-cursorline')
	dein#add('dense-analysis/ale')     # Syntaxチェッカー
	dein#add('easymotion/vim-easymotion')
	dein#add('hrsh7th/vim-vsnip')
	dein#add('hrsh7th/vim-vsnip-integ')
	dein#add('itchyny/lightline.vim')
	dein#add('jceb/vim-hier')          # quickfixをハイライト
	dein#add('jistr/vim-nerdtree-tabs')
	dein#add('kana/vim-textobj-user')
	dein#add('luochen1990/rainbow')    # 虹色括弧
	dein#add('machakann/vim-sandwich')
	dein#add('mattn/vim-maketable')
	dein#add('matze/vim-move')         # 複数行移動
	dein#add('mbbill/undotree')
	dein#add('mechatroner/rainbow_csv')
	dein#add('michaeljsmith/vim-indent-object')
	dein#add('osyo-manga/vim-monster', { lazy: 1, on_ft: 'ruby' }) # rubyの補完
	dein#add('othree/html5.vim')
	dein#add('othree/yajs.vim')
	dein#add('prabirshrestha/asyncomplete-buffer.vim')
	dein#add('prabirshrestha/asyncomplete.vim')
	dein#add('rafamadriz/friendly-snippets')
	dein#add('scrooloose/nerdtree')
	dein#add('skanehira/translate.vim')
	dein#add('thinca/vim-portal')
	dein#add('tpope/vim-fugitive')      # Gdiffとか
	dein#add('tyru/caw.vim')            # コメント化
	dein#add('utubo/vim-colorscheme-girly')
	dein#add('utubo/vim-reformatdate')
	dein#add('utubo/vim-shrink')
	dein#add('utubo/vim-textobj-twochars')
	#dein#add('utubo/vim-vindent')
	dein#add('yami-beta/asyncomplete-omni.vim')
	dein#add('yegappan/mru')
	if s:has_deno
		dein#add('vim-denops/denops.vim')
		dein#add('vim-skk/skkeleton')
	endif
	dein#end()
	dein#save_state()
	# 削除したら↓をやる
	# :call map(dein#check_clean(), "delete(v:val, 'rf')")
	# :call dein#recache_runtimepath()
	#}}}

	# easymotion {{{
	Enable  g:EasyMotion_smartcase
	Enable  g:EasyMotion_use_migemo
	Enable  g:EasyMotion_enter_jump_first
	Disable g:EasyMotion_do_mapping
	map s <Plug>(easymotion-s)
	au vimrc VimEnter,BufEnter * EMCommandLineNoreMap <Space><Space> <Esc>
	#}}}

	# sandwich {{{
	g:sandwich#recipes = deepcopy(g:sandwich#default_recipes)
	g:sandwich#recipes += [
		{ buns: ["\r", ''  ], input: ["\r"], command: ["normal! i\r"] },
		{ buns: ['',   ''  ], input: ['q'] },
		{ buns: ['「', '」'], input: ['k'] },
		{ buns: ['>',  '<' ], input: ['>'] },
		{ buns: ['{ ', ' }'], input: ['{'] },
		{ buns: ['${', '}' ], input: ['${'] },
		{ buns: ['CommentString(0)', 'CommentString(1)'], expr: 1, input: ['c'] },
	]
	def! g:CommentString(index: number): string
		return &commentstring->split('%s')->get(index, '')
	enddef
	Enable g:sandwich_no_default_key_mappings
	Enable g:operator_sandwich_no_default_key_mappings
	MultiCmd nmap,vmap Sd <Plug>(operator-sandwich-delete)<if-nmap>ab
	MultiCmd nmap,vmap Sr <Plug>(operator-sandwich-replace)<if-nmap>ab
	MultiCmd nmap,vmap Sa <Plug>(operator-sandwich-add)<if-nmap>iw
	MultiCmd nmap,vmap S  <Plug>(operator-sandwich-add)<if-nmap>iw
	nmap S^ v^S
	nmap S$ vg_S
	nmap <expr> SS (matchstr(getline('.'), '[''"]', getpos('.')[2]) ==# '"') ? 'Sr"''' : 'Sr''"'

	# 改行で挟んだあとタブでインデントされると具合が悪くなるので…
	def s:FixSandwichPos()
		var c = g:operator#sandwich#object.cursor
		if g:fix_sandwich_pos[1] != c.inner_head[1]
			c.inner_head[2] = getline(c.inner_head[1])->match('\S') + 1
			c.inner_tail[2] = getline(c.inner_tail[1])->match('$') + 1
		endif
	enddef
	au vimrc User OperatorSandwichAddPre g:fix_sandwich_pos = getpos('.')
	au vimrc User OperatorSandwichAddPost s:FixSandwichPos()

	# 内側に連続で挟むやつ
	def s:RemarkPatty()
		setpos("'<", g:operator#sandwich#object.cursor.inner_head)
		setpos("'>", g:operator#sandwich#object.cursor.inner_tail)
	enddef
	nmap <silent> S. :<C-u>call <SID>RemarkPatty()<CR>gvSa

	var s:big_mac_crown = []
	def s:BigMac(is_nest: bool = false)
		const c = is_nest ? g:operator#sandwich#object.cursor.inner_head[1 : 2] : []
		if ! is_nest || s:big_mac_crown !=# c
			s:big_mac_crown = c
			au vimrc User OperatorSandwichAddPost ++once s:BigMac(true)
			feedkeys(is_nest ? 'S.' : 'gvSa')
		endif
	enddef
	nmap Sm viwSm
	vmap <silent> Sm :<C-u>call <SID>BigMac()<CR>

	# 行末空白と空行を削除
	def s:RemoveAirBuns()
		var c = g:operator#sandwich#object.cursor
		s:RemoveEmptyLine(c.tail[1])
		s:RemoveEmptyLine(c.head[1])
	enddef
	au vimrc User OperatorSandwichDeletePost s:RemoveAirBuns()
	#}}}

	# MRU {{{
	# デフォルトだとファイル名に括弧が含まれていると開けない
	g:MRU_Filename_Format = {
		formatter: 'fnamemodify(v:val, ":t") . " > " . v:val',
		parser: '> \zs.*',
		syntax: '^.\{-}\ze >'
	}
	# 数字キーで開く
	def s:MRUwithNumKey(open_with_tab: bool)
		b:open_with_tab = open_with_tab
		setlocal number
		redraw
		echoh Question
		echo printf('[1]..[9] => open with a %s.', b:open_with_tab ? 'tab' : 'window')
		echoh None
		const key = b:open_with_tab ? 't' : '<CR>'
		for i in range(1, 9)
			execute printf('nmap <buffer> <silent> %d :<C-u>%d<CR>%s', i, i, key)
		endfor
	enddef
	def s:MyMRU()
		Enable b:auto_cursorline_disabled
		setlocal cursorline
		nnoremap <buffer> <silent> w :<C-u>call <SID>MRUwithNumKey(!b:open_with_tab)<CR>
		nnoremap <buffer> R :<C-u>MruRefresh<CR>:normal u<CR>
		s:MRUwithNumKey(s:BufIsSmth())
	enddef
	au vimrc FileType mru s:MyMRU()
	au vimrc ColorScheme * hi link MruFileName Directory
	nnoremap <silent> <F2> :<C-u>MRUToggle<CR>
	#}}}

	# 補完 {{{
	def s:RegisterAsyncompSource(name: string, white: list<string>, black: list<string>)
		# とても長い
		execute printf("asyncomplete#register_source(asyncomplete#sources#%s#get_source_options({ name: '%s', whitelist: %s, blacklist: %s, completor: asyncomplete#sources#%s#completor }))", name, name, white, black, name)
	enddef
	s:RegisterAsyncompSource('omni', ['*'], ['c', 'cpp', 'html'])
	s:RegisterAsyncompSource('buffer', ['*'], ['go'])
	MultiCmd imap,smap <expr> JJ      vsnip#expandable() ? '<Plug>(vsnip-expand)' : 'JJ'
	MultiCmd imap,smap <expr> <C-l>   vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
	MultiCmd imap,smap <expr> <Tab>   vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)' : pumvisible() ? '<C-n>' : '<Tab>'
	MultiCmd imap,smap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : pumvisible() ? '<C-p>' : '<S-Tab>'
	#imap <expr> <CR> pumvisible() ? '<C-y>' : '<CR>'
	Enable g:lexima_accept_pum_with_enter
	#}}}

	# 翻訳 {{{
	def s:AutoTranslate(text: string)
		if matchstr(text, '[^\x00-\x7F]') ==# ''
			execute 'Translate ' .. text
		else
			execute 'Translate! ' .. text
		endif
	enddef
	nnoremap <script> <Space>t :<C-u>call <SID>AutoTranslate(expand('<cword>'))<CR>
	vnoremap <script> <Space>t :<C-u>call <SID>AutoTranslate(<SID>GetVisualSelection())<CR>gv
	#}}}

	# ALE {{{
	Enable  g:ale_set_quickfix
	Enable  g:ale_fix_on_save
	Disable g:ale_lint_on_insert_leave
	Disable g:ale_set_loclist
	g:ale_sign_error = '🐞'
	g:ale_sign_warning = '🐝'
	g:ale_fixers = { typescript: ['deno'] }
	nmap <silent> [a <Plug>(ale_previous_wrap)
	nmap <silent> ]a <Plug>(ale_next_wrap)
	#}}}

	# lightline {{{
	# ヤンクしたやつを表示するやつ
	g:ll_reg = ''
	def s:LLYankPost()
		var reg = substitute(v:event.regcontents[0], '\t', ' ', 'g')
		if len(v:event.regcontents) !=# 1 || len(reg) > 10
			reg = substitute(reg, '^\(.\{0,8\}\).*', '\1..', '')
		endif
		g:ll_reg = '📎[' .. reg .. ']'
	enddef
	au vimrc TextYankPost * s:LLYankPost()

	# 毎時45分から15分間休憩しようね
	g:ll_tea_break = '0:00'
	g:ll_tea_break_opentime = localtime()
	def! g:VimrcTimer60s(timer: any)
		const tick = (localtime() - g:ll_tea_break_opentime) / 60
		const mm = tick % 60
		const tea = mm >= 45 ? '☕🍴🍰' : ''
		g:ll_tea_break = tea .. printf('%d:%02d', tick / 60, mm)
		lightline#update()
	enddef
	timer_stop(get(g:, 'vimrc_timer_60s', 0))
	g:vimrc_timer_60s = timer_start(60000, 'VimrcTimer60s', { repeat: -1 })

	# &ff
	if has('win32')
		def! g:LLFF(): string
			return &ff !=# 'dos' ? &ff : ''
		enddef
	else
		def! g:LLFF(): string
			return &ff ==# 'dos' ? &ff : ''
		enddef
	endif

	# &fenc
	def! g:LLNotUtf8(): string
		return &fenc ==# 'utf-8' ? '' : &fenc
	enddef

	# lightline設定
	g:lightline = {
		colorscheme: 'wombat',
		active: { right: [['teabreak'], ['ff', 'notutf8', 'lineinfo'], ['reg']] },
		component: { teabreak: '%{g:ll_tea_break}', reg: '%{g:ll_reg}' },
		component_function: { ff: 'LLFF', notutf8: 'LLNotUtf8' },
	}

	# tablineはデフォルト
	au vimrc VimEnter * set tabline=
	#}}}

	# skk {{{
	if s:has_deno
		if ! empty($SKK_JISYO_DIR)
			skkeleton#config({
				globalJisyo: expand($SKK_JISYO_DIR .. 'SKK-JISYO.L'),
				userJisyo: expand($SKK_JISYO_DIR .. '.skkeleton'),
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

	# その他 {{{
	Enable  g:rainbow_active
	Enable  g:nerdtree_tabs_autofind
	Enable  g:undotree_SetFocusWhenToggle
	Disable g:undotree_DiffAutoOpen
	g:auto_cursorline_wait_ms = 3000
	nnoremap <silent> <F1> :<C-u>NERDTreeTabsToggle<CR>
	nnoremap <silent> <F3> :<C-u>silent! UndotreeToggle<cr>
	nnoremap <silent> <Space>gv :<C-u>Gvdiffsplit<CR>
	nnoremap <Space>ga :<C-u>Git add %
	nnoremap <Space>gc :<C-u>Git commit -m ''<Left>
	nnoremap <Space>gp :<C-u>Git push
	nnoremap <Space>gl :<C-u>Git pull<CR>
	MultiCmd nmap,vmap <Space>c <Plug>(caw:hatpos:toggle)
	MultiCmd nmap,tmap <silent> <C-w><C-s> <Plug>(shrink-height)<C-w>w
	MultiCmd nmap,tmap <silent> <C-w><C-h> <Plug>(shrink-width)<C-w>w
	#}}}
endif
filetype plugin indent on
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# コピペ寄せ集め色々 {{{
au vimrc InsertLeave * set nopaste
au vimrc BufReadPost *.log* normal! G
vnoremap <silent> * "vy/\V<C-r>=substitute(escape(@v,'\/'),"\n",'\\n','g')<CR><CR>
inoremap kj <Esc>`^
inoremap kk <Esc>`^
inoremap <CR> <CR><C-g>u
# http://deris.hatenablog.jp/entry/2014/05/20/235807
nnoremap gs :<C-u>%s///g<Left><Left><Left>
vnoremap gs :s///g<Left><Left><Left>
xnoremap Y "+y
# https://github.com/astrorobot110/myvimrc/blob/master/vimrc
set matchpairs+=（:）,「:」,『:』,【:】,［:］,＜:＞
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# タブ幅やタブ展開を自動設定 {{{
def s:SetupTabstop()
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
au vimrc BufReadPost * s:SetupTabstop()
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# vimgrep {{{
def s:MyVimgrep(keyword: string, ...targets: list<string>)
	var path = join(targets, ' ')
	# パスを省略した場合は、同じ拡張子のファイルから探す
	if empty(path)
		path = expand('%:e') ==# '' ? '*' : ('*.' .. expand('%:e'))
	endif
	# 適宜タブで開く(ただし明示的に「%」を指定したらカレントで開く)
	const open_with_tab = s:BufIsSmth() && path !=# '%'
	if open_with_tab
		tabnew
	endif
	# lvimgrepしてなんやかんやして終わり
	execute printf('silent! lvimgrep %s %s', keyword, path)
	if ! empty(getloclist(0))
		lwindow
	else
		echoh ErrorMsg
		echomsg 'Not found.: ' .. keyword
		echoh None
		if open_with_tab
			tabnext -
			tabclose +
		endif
	endif
enddef
command! -nargs=+ MyVimgrep s:MyVimgrep(<f-args>)
nnoremap <Space>/ :<C-u>MyVimgrep<Space>

def s:MyQuickFixWindow()
	nnoremap <buffer> <silent> ; <CR>:silent! normal! zv<CR><C-W>w
	nnoremap <buffer> <silent> w <C-W><CR>:silent! normal! zv<CR><C-W>w
	nnoremap <buffer> <silent> t <C-W><CR>:silent! normal! zv<CR><C-W>T
	nnoremap <buffer> <silent> <nowait> q :<C-u>lexpr ''<CR>:q<CR>
	nnoremap <buffer> f <C-f>
	nnoremap <buffer> b <C-b>
	# 様子見中(使わなそうなら削除する)
	execute printf('nnoremap <buffer> T <C-W><CR><C-W>T%dgt', tabpagenr())
enddef
au vimrc FileType qf s:MyQuickFixWindow()
au vimrc WinEnter * if winnr('$') == 1 && &buftype ==# 'quickfix' | q | endif
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# diff {{{
set splitright
set fillchars+=diff:\ # 削除行は空白文字で埋める
command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis
nnoremap <F4> :<C-u>DiffOrig<CR>
# diffモードを自動でoff https://hail2u.net/blog/software/vim-turn-off-diff-mode-automatically.html
au vimrc WinEnter * if (winnr('$') == 1) && !!getbufvar(winbufnr(0), '&diff') | diffoff | endif
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# 日付関係 {{{
inoremap <F5> <C-r>=strftime('%Y/%m/%d')<CR>
cnoremap <F5> <C-r>=strftime('%Y%m%d')<CR>
nnoremap <silent> <F5> :<C-u>call reformatdate#reformat(localtime())<CR>
nnoremap <silent> <C-a> <C-a>:call reformatdate#reformat()<CR>
nnoremap <silent> <C-x> <C-x>:call reformatdate#reformat()<CR>
nnoremap <Space><F5> /\d\{4\}\/\d\d\/\d\d<CR>
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# スマホ用 {{{
# - キーが小さいので押しにくいものはSpaceへマッピング
# - スマホでのコーディングは基本的にバグ取り
nnoremap <Space>zz :<C-u>q!<CR>
# スタックトレースからyankしてソースの該当箇所を探すのを補助
nnoremap <Space>e G?\cErr\\|Exception<CR>
nnoremap <Space>y yiw
nnoremap <expr> <Space>f (@" =~ '^\d\+$' ? ':' : '/').@"."\<CR>"
# ConnectBotの:とFキーが遠い
nmap <Space>, :
for s:i in range(1, 10)
	execute printf('nmap <Space>%d <F%d>', s:i % 10, s:i)
endfor
nmap <Space><Space>1 <F11>
nmap <Space><Space>2 <F12>
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# カーソルを行頭に合わせて移動 {{{
def s:PutHat(): string
	const x = getline('.')->match('\S') + 1
	if x != 0 || !exists('w:my_hat')
		w:my_hat = col('.') == x ? '^' : ''
	endif
	return w:my_hat
enddef
nnoremap <expr> j 'j'.<SID>PutHat()
nnoremap <expr> k 'k'.<SID>PutHat()
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# 折り畳み {{{
# こんなかんじでインデントに合わせて表示📁 {{{
def! g:MyFoldText(): string
	const src = getline(v:foldstart)
	const indent = repeat(' ', indent(v:foldstart))
	const text = &foldmethod ==# 'indent' ? '' : src->substitute(matchstr(&foldmarker, '^[^,]*'), '', '')->trim()
	return indent .. text .. '📁'
enddef
set foldtext=MyFoldText()
set fillchars+=fold:\ # 折り畳み時の「-」は半角空白
au vimrc ColorScheme * hi! link Folded Delimiter
#}}}
# ホールドマーカーの前にスペース、後ろに改行を入れる {{{
def s:Zf()
	if line("'<") != line('.')
		return
	endif
	var firstline = line("'<")
	var lastline = line("'>")
	execute ':' firstline 's/\v(\S)?$/\1 /'
	execute ':' lastline "normal! o\<Esc>i" .. s:IndentStr(firstline)
	cursor([firstline, 1])
	normal! V
	cursor([lastline + 1, 1])
	normal! zf
enddef
vnoremap <silent> zf :call <SID>Zf()<CR>
#}}}
# ホールドマーカーを削除したら行末をトリムする {{{
def s:Zd()
	if foldclosed(line('.')) == -1
		normal! zc
	endif
	const head = foldclosed(line('.'))
	const tail = foldclosedend(line('.'))
	if head == -1
		return
	endif
	const org = getpos('.')
	normal! zd
	s:RemoveEmptyLine(tail)
	s:RemoveEmptyLine(head)
	setpos('.', org)
enddef
nnoremap <silent> zd :Zd()<CR>
#}}}
# その他折りたたみ関係 {{{
set foldmethod=marker
au vimrc FileType markdown,yaml setlocal foldlevelstart=99 | setlocal foldmethod=indent
au vimrc BufReadPost * :silent! normal! zO
nnoremap <expr> h (col('.') == 1 && 0 < foldlevel('.') ? 'zc' : 'h')
nnoremap Z<Tab> :<C-u>set foldmethod=indent<CR>
nnoremap Z{ :<C-u>set foldmethod=marker<CR>
nnoremap Zy :<C-u>set foldmethod=syntax<CR>
#}}}
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# ビジュアルモードあれこれ {{{
# チラつかないようにやるやつ
def s:KeepCursor(expr: string)
	const cur = getcurpos()
	execute expr
	setpos('.', cur)
enddef
vnoremap <Tab> <Cmd>normal! >gv<CR>
vnoremap <S-Tab> <Cmd>normal! <gv<CR>
vnoremap u <Cmd>call <SID>KeepCursor('undo')<CR>
vnoremap <CR> <Cmd>call <SID>KeepCursor('redo')<CR>
#}}}

# ----------------------------------------------------------
# コマンドモードあれこれ {{{
cnoremap <C-h> <Space><BS><Left>
cnoremap <C-l> <Space><BS><Right>
cnoremap <C-r><C-r> <C-r>=trim(@")<CR>
nnoremap q; :q
nnoremap ; :
vnoremap ; :
nnoremap <Space>; ;
cnoreabbrev cs colorscheme

# 「jj」で<CR>、「kk」はキャンセル
# ただし保存は片手で「;jj」でもOK(「;wjj」じゃなくていい)
cnoremap kk <C-c>
cnoremap <expr> jj (empty(getcmdline()) ? 'update<CR>' : '<CR>')
inoremap ;jj <Esc>`^:update<CR>

#}}} -------------------------------------------------------

# ----------------------------------------------------------
# terminalとか {{{
if has('win32')
	command! Powershell :bo terminal ++close pwsh
	nnoremap <silent> SH :<C-u>Powershell<CR>
	nnoremap <silent> <S-F1> :<C-u>silent !start explorer %:p:h<CR>
else
	nnoremap <silent> SH :<C-u>bo terminal<CR>
endif
tnoremap <C-w>; <C-w>:
tnoremap <C-w><C-w> <C-w>w
tnoremap <C-w>q exit
tnoremap <C-w><C-q> <C-w>:quit!<CR>
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# markdownのチェックボックス {{{
def s:ToggleCheckBox()
	const a = getline('.')
	var b = substitute(a, '^\(\s*\)- \[ \]', '\1- [x]', '') # check on
	if a ==# b
		b = substitute(a, '^\(\s*\)- \[x\]', '\1- [ ]', '') # check off
	endif
	if a ==# b
		b = substitute(a, '^\(\s*\)\(- \)*', '\1- [ ] ', '') # a new check box
	endif
	setline('.', b)
	var c = getpos('.')
	c[2] += len(b) - len(a)
	setpos('.', c)
enddef
noremap <silent> <Space>x :call <SID>ToggleCheckBox()<CR>
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# ファイル情報を色付きで表示 {{{
def s:ShowBufInfo()
	if &ft ==# 'qf'
		return
	endif
	redraw
	echoh Title
	echon '"' bufname() '" '
	const e = filereadable(expand('%'))
	if !e
		echoh Tag
		echon '[NEW] '
	endif
	if &readonly
		echoh WarningMsg
		echon '[RO] '
	endif
	const w = wordcount()
	if e || w.bytes != 0
		echoh ModeMsg
		echon (w.bytes == 0 ? 0 : line('$')) 'L, ' w.bytes 'B '
	endif
	echoh MoreMsg
	echon &ff ' ' (empty(&fenc) ? &encoding : &fenc) ' ' &ft
enddef
noremap <silent> <C-g> :<C-u>call <SID>ShowBufInfo()<CR>
au vimrc BufNewFile,BufReadPost * s:ShowBufInfo()
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# 閉じる {{{
def s:Quit(expr: string = '')
	if ! empty(expr)
		if winnr() == winnr(expr)
			return
		endif
		execute 'wincmd ' .. expr
	endif
	if mode() ==# 't'
		quit!
	else
		confirm quit
	endif
enddef
nnoremap <silent> qh :<C-u>call <SID>Quit('h')<CR>
nnoremap <silent> qj :<C-u>call <SID>Quit('j')<CR>
nnoremap <silent> qk :<C-u>call <SID>Quit('k')<CR>
nnoremap <silent> ql :<C-u>call <SID>Quit('l')<CR>
nnoremap <silent> qq :<C-u>call <SID>Quit()<CR>
nnoremap q <Nop>
nnoremap Q q
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# ファイルを移動して保存 {{{
def MoveFile(newname: string)
	const oldpath = expand('%')
	const newpath = expand(newname)
	if ! empty(oldpath) && filereadable(oldpath)
		if filereadable(newpath)
			echoh Error
			echo 'file "' .. newname .. '" already exists.'
			echoh None
			return
		endif
		rename(oldpath, newpath)
	endif
	execute 'saveas! ' .. newpath
	# 開き直してMRUに登録
	edit
enddef
command! -nargs=1 -complete=file MoveFile call <SID>MoveFile(<f-args>)
cnoreabbrev mv MoveFile
#}}}

# ----------------------------------------------------------
# その他細々したの {{{
if has('clipboard')
	au vimrc FocusGained * @" = @+
	au vimrc FocusLost   * @+ = @"
endif
nnoremap <silent> <F11> :<C-u>set number! \| let &cursorline=&number<CR>
nnoremap <silent> <F12> :<C-u>set wrap! wrap?<CR>
nnoremap <expr> g: ":\<C-u>".substitute(getline('.'), '^[\t "#:]\+', '', '')."\<CR>"
vnoremap g: "vy:<C-r>=@v<CR><CR>
nnoremap Y y$
nnoremap <Space>p $p
nnoremap <Space>P ^P
nnoremap <Space><Space>p o<C-r>"<Esc>
nnoremap <Space><Space>P O<C-r>"<Esc>
onoremap <expr> } '<Esc>m`0' .. v:count1 .. v:operator .. '}``'
onoremap <expr> { '<Esc>m`V' .. v:count1 .. '{' .. v:operator .. '``'
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
au vimrc FileType vim if getline(1) ==# 'vim9script' | &commentstring = '#%s' | endif
# 分割キーボードで右手親指が<CR>になったので
nmap <CR> <Space>
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# 様子見中 {{{
# 使わなそうなら削除する
vnoremap <expr> p '"_s<C-R>' .. v:register .. '<ESC>'
vnoremap P p
nnoremap <Space>h ^
nnoremap <Space>l $
nnoremap <Space>a A
nnoremap <Space>d "_d
nnoremap <silent> <Space>nh :<C-u>noh<CR>
nnoremap TE :<C-u>tabe<Space>
nnoremap TN :<C-u>tabnew<CR>
nnoremap TD :<C-u>tabe ./<CR>
nnoremap gS :<C-u>%s/<C-r>=escape(expand('<cword>'), '^$.*?/\[]')<CR>//g<Left><Left>
cnoremap <C-r><C-e> <C-r>=escape(@", '^$.*?/\[]')<CR><Right>

# カーソル位置のハイライトを確認するやつ
nnoremap <expr> <Space>gh ':<C-u>hi ' .. substitute(synIDattr(synID(line('.'), col('.'), 1), 'name'),'^$', 'Normal', '') .. '<CR>'

# どっちも<C-w>w。左手オンリーと右手オンリーのマッピング
nnoremap <Space>w <C-w>w
nnoremap <Space>o <C-w>w

# CSVとかのヘッダを固定表示する。ファンクションキーじゃなくてコマンド定義すればいいかな…
nnoremap <silent> <F10> <ESC>1<C-w>s:1<CR><C-w>w
vnoremap <F10> <ESC>1<C-w>s<C-w>w

# マーク使ってないし
nnoremap ' "
nnoremap <Space>' '

# うーん…
inoremap jj <C-o>
inoremap jjh <C-o>^
inoremap jjl <C-o>$
inoremap jje <C-o>e<C-o>a
inoremap jj; <C-o>$;
inoremap jj, <C-o>$,
inoremap jj{ <C-o>$ {
inoremap jj} <C-o>$ }
inoremap jj<CR> <C-o>$<CR>
inoremap jjk 「」<Left>
inoremap jjx <Cmd>call <SID>ToggleCheckBox()<CR>
# Altキーでもいいかなぁ…
inoremap <M-h> <C-o>^
inoremap <M-l> <C-o>$
inoremap <M-e> <C-o>e<C-o>a
inoremap <M-k> 「」<Left>
# これはちょっと押しにくい
inoremap <M-x> <Cmd>call <SID>ToggleCheckBox()<CR>

# syntax毎に強調する
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
au vimrc Syntax javascript,vim AddMySyntax('SpellRare', '\s[=!]=\s') # 「==#」とかの存在を忘れないように
au vimrc Syntax vim AddMySyntax('SpellRare', '\<normal!\@!') # 基本的には再マッピングさせないように「!」を付ける

#nnoremap <F1> :<C-u>smile<CR>
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# † あともう1回「これ使ってないな…」と思ったときに消す {{{

# インデントが現在行以下の行まで移動 {{{
def s:FindSameIndent(flags: string, inner: number = 0): number
	const size = len(s:IndentStr('.'))
	const pattern = printf('^\s\{0,%d\}\S', size)
	setpos('.', [0, getpos('.')[1], 1, 1])
	return search(pattern, flags) + inner
enddef
noremap <expr> [<Tab> <SID>FindSameIndent('bW').'G'
noremap <expr> ]<Tab> <SID>FindSameIndent('W').'G'
noremap <expr> [<S-Tab> <SID>FindSameIndent('bW', 1).'G'
noremap <expr> ]<S-Tab> <SID>FindSameIndent('W', -1).'G'
#}}}

# https://github.com/justinmk/config/blob/master/.config/nvim/init.vim
# 便利なんだけど忘れてしまう…
inoremap {; {<CR>};<C-o>O
inoremap {, {<CR>},<C-o>O
inoremap [; [<CR>];<C-o>O
inoremap [, [<CR>],<C-o>O

#}}} -------------------------------------------------------

# ----------------------------------------------------------
# デフォルトマッピングデー {{{
if strftime('%d') ==# '01'
	def s:DMD()
		var msg = "✨ Today, Let's enjoy VIM with default key mapping ! ✨"
		var padding = repeat(' ', (winwidth(0) - strdisplaywidth(msg)) / 2)
		echo padding .. msg
		imapclear
		mapclear
	enddef
	au vimrc VimEnter * s:DMD()
endif
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# 色 {{{
set t_Co=256
def s:DefaultColors()
	g:rainbow_conf = {
		guifgs: ['#9999ee', '#99ccee', '#99ee99', '#eeee99', '#ee99cc', '#cc99ee'],
		ctermfgs: ['105', '117', '120', '228', '212', '177']
	}
	g:rcsv_colorpairs = [
		['105', '#9999ee'], ['117', '#99ccee'], ['120', '#99ee99'],
		['228', '#eeee99'], ['212', '#ee99cc'], ['177', '#cc99ee']
	]
enddef
au vimrc ColorSchemePre * s:DefaultColors()
def s:MyMatches()
	if exists('w:my_matches') && !empty(getmatches())
		return
	end
	w:my_matches = 1
	matchadd('SpellBad', '　\|¥\|\s\+$')
	matchadd('String', '「[^」]*」')
	matchadd('Label', '^\s*■.*$')
	matchadd('Delimiter', 'WARN|注意\|注:\|[★※][^\s()（）]*')
	matchadd('Todo', 'TODO')
	matchadd('Error', 'ERROR')
	matchadd('Delimiter', '- \[ \]')
	# 稀によくtypoする単語(気づいたら追加する)
	matchadd('SpellBad', 'stlye')
enddef
au vimrc VimEnter,WinEnter * s:MyMatches()
syntax on
set background=dark
silent! colorscheme girly
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# メモ {{{
# <F1> NERDTree <S-F1>でフォルダを開く(win32)
# <F2> MRU
# <F3> UndoTree(あんまり使わない)
# <F4> DiffOrig(あんまり使わない)
# <F5> 日付関係
# <F6>
# <F7>
# <F8>
# <F9>
# <F10> ヘッダ行を表示(あんまり使わない)
# <F11> 行番号表示切替
# <F12> 折り返し表示切替
#}}} -------------------------------------------------------

if filereadable(expand('~/.vimrc_local'))
	source ~/.vimrc_local
endif

