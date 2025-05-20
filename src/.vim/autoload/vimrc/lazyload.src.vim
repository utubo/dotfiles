vim9script

# ------------------------------------------------------
# ユーティリティ {{{

# こんな感じ
#   Each nmap,xmap j gj
#   → nmap j gj | xmap j gj
# 先頭以外に差し込んだりネストしたい場合はこう
#   Each j,k Each nmap,xmap {1} {0} g{0}
#   → nmap j gj | xmap j gj | nmap k gk | xmap k gk
# 名前をつけたい場合はこんなかんじ
#   Each X=j,k Each nnoremap X gX
#   Each X,Y=j,+,k,- nnoremap <Space>X Y
# ※これ使うよりべたで書いたほうが起動は速い
g:util_each_nest = 0
def! g:UtilEach(qargs: string)
	var [items, cmd] = qargs->split('^\S*\zs')
	g:util_each_nest += 1
	const kv = items->split('=')
	const keys = len(kv) ==# 1 ? ['{0\?}'] : kv[0]->split(',')
	const values = kv[-1]->split(',')
	const haskey = match(cmd, keys[0]) !=# -1
	var i = 0
	while i < values->len()
		var c = cmd
		var v = values[i]
		if haskey
			# 置き換え文字ありの場合(e.g. `Each val1,val2 cmd {}`)
			for k in keys
				c = c->substitute(k, v, 'g')
				i += 1
			endfor
		else
			# 置き換え文字なしの場合(e.g. `Each cmd1,cmd2 val`)
			c = $'{v} {c}'
			i += 1
		endif
		execute c->substitute($"\{{g:util_each_nest}\}", '{}', 'g')
	endwhile
	g:util_each_nest -= 1
enddef
command! -keepscript -nargs=* Each g:UtilEach(<q-args>)

# その他
command! -nargs=1 -complete=var Enable  <args> = 1
command! -nargs=1 -complete=var Disable <args> = 0

def g:IndentStr(expr: any): string
	return matchstr(getline(expr), '^\s*')
enddef

def g:StayCurPos(expr: string)
	const len = getline('.')->len()
	var cur = getcurpos()
	execute expr
	cur[2] += getline('.')->len() - len
	setpos('.', cur)
enddef

def g:System(cmd: string): string
	if !has('win32')
		return system(cmd)
	endif
	var result = []
	var job = job_start(cmd, {
		out_cb: (j, s) => {
			result = result + [s]
		}
	})
	while job_status(job) ==# 'run'
		sleep 10m
	endwhile
	return join(result, "\n")
enddef

# <Cmd>でdefを実行したときのビジュアルモードの範囲(行)
def! g:VFirstLast(): list<number>
	return [line('.'), line('v')]->sort('n')
enddef

def! g:VRange(): list<number>
	const a = g:VFirstLast()
	return range(a[0], a[1])
enddef
# }}}

# ------------------------------------------------------
# プラグイン {{{

# このスクリプト内で必要となるプラグイン {{{
packadd lsp
packadd vim-reformatdate
packadd vim-textobj-user
packadd vim-headtail
packadd vim-popselect
# }}}

# zenmode {{{
au vimrc User Vim9skkModeChanged zenmode#Invalidate()
# }}}

# vim9skk {{{
g:vim9skk = {
	keymap: {
    	midasi: ['Q', '; '],
		toggle: ['<C-j>', ';j'],
		complete: ['<CR>', ';;'],
	},
}
nnoremap ;j i<Plug>(vim9skk-enable)
# AZIKライクな設定とか
au vimrc User Vim9skkInitPre vimrc#vim9skk#ApplySettings()
# 見出しモードでスタートする
au vimrc User Vim9skkEnter feedkeys('Q')
# インサートモードが終わったらオフにする
au vimrc ModeChanged [ic]:n au SafeState * ++once vim9skk#Disable()
# 見出しの色見出しの色を替たらみやすいかな？
au vimrc User Vim9skkEnter hi! link vim9skkMidasi PMenuSel
# }}}

# headtail {{{
noremap <Leader>ga ga
HeadTailMap g G
Each nmap,xmap g% gi%
Each nmap,xmap G% Gi%
# }}}

# textobj-user {{{
Each X=a,i Each onoremap,xnoremap Xb <Plug>(textobj-multiblock-X)
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
# }}}

# Git {{{
command! -nargs=* GitAdd vimrc#git#Add(<q-args>)
command! -nargs=1 -complete=customlist,vimrc#git#ConventionalCommits GitCommit vimrc#git#Commit(<q-args>)
command! -nargs=1 -complete=customlist,vimrc#git#ConventionalCommits GitAmend vimrc#git#Amend(<q-args>)
command! -nargs=1 GitTagPush vimrc#git#TagPush(<q-args>)
nnoremap <Space>ga <Cmd>GitAdd -A<CR>
nnoremap <Space>gc :<C-u>GitCommit<Space><Tab>
nnoremap <Space>gA :<C-u><Cmd>call setcmdline($'GitAmend {vimrc#git#GetLastCommitMessage()}')<CR>
nnoremap <Space>gP :<C-u>Git push<End>
nnoremap <Space>gs <Cmd>Git status -sb<CR>
nnoremap <Space>gv <Cmd>Gvdiffsplit<CR>
nnoremap <Space>gd <Cmd>Gdiffsplit<CR>
nnoremap <Space>gp <Cmd>Git pull<CR>
nnoremap <Space>gl <Cmd>Git log<CR>
nnoremap <Space>gt :<C-u>GitTagPush<Space>
nnoremap <Space>gC :<C-u>Git checkout %
def PullDotfiles()
	const vimrcpath = has('win32') ? '~/_vimrc' : '~/.vimrc'
	const dotfilespath = vimrcpath->expand()->resolve()->fnamemodify(':h')
	const cwd = getcwd()
	chdir(dotfilespath)
	echo g:System($'git pull')
	chdir(cwd)
	execute $'source {has('win32') ? '~/vimfiles' : '~/.vim'}/autoload/vimrc/ezpack.vim'
	EzpackInstall
enddef
nnoremap <Space>GL <ScriptCmd>PullDotfiles()<CR>
au CmdlineEnter * ++once silent! cunmap <C-r><C-g>
# }}}

# gh {{{
nnoremap <Space>gh <Cmd>e gh://utubo/repos<CR>
au vimrc FileType gh-repos vimrc#gh#ReposKeymap()
au vimrc FileType gh-issues vimrc#gh#IssuesKeymap()
au vimrc FileType gh-issue-comments vimrc#gh#IssueCommentsKeymap()
# }}}

# popselect {{{
nnoremap <F1> <ScriptCmd>popselect#dir#Popup()<CR>
nnoremap <F2> <ScriptCmd>popselect#mru#Popup()<CR>
nnoremap <F3> <ScriptCmd>popselect#buffers#Popup()<CR>
nnoremap <F4> <ScriptCmd>popselect#tabpages#Popup()<CR>
nnoremap <C-p> <ScriptCmd>popselect#projectfiles#PopupWithMRU({ filter_focused: true })<CR>

# タブ移動したときもポップアップする
Each X=t,T nnoremap gX gX<Cmd>call popselect#tabpages#Popup()<CR>

# gnとgpでポップアップしながらバッファ移動
def ShowBuf(a: string)
	const b = bufnr()
	while true
		execute $'b{a}'
		# terminalに移動すると混乱するのでスキップする || 無限ループ防止
		if &buftype !=# 'terminal' || bufnr() ==# b
			break
		endif
	endwhile
	popselect#buffers#Popup({ extra_show: false })
enddef
Each X=n,p nnoremap gX <ScriptCmd>ShowBuf('X')<CR>

# デフォルトのgrは使わないかな…
# Note: 押しにくいのでやめた→nnoremap gb <Cmd>buffer #<CR>
nnoremap gr <Cmd>buffer #<CR>
# }}}

# Portal {{{
nnoremap <Leader>a <Cmd>PortalAim<CR>
nnoremap <Leader>b <Cmd>PortalAim blue<CR>
nnoremap <Leader>o <Cmd>PortalAim orange<CR>
nnoremap <Leader>r <Cmd>PortalReset<CR>
# }}}

# 補完 {{{
export def SkipParen(): string
	const c = matchstr(getline('.'), '.', col('.') - 1)
	# 閉じ括弧の間にTAB文字を入れることはないだろう…
	if !c || stridx(')]}>\''`」', c) ==# -1
		return "\<Tab>"
	else
		return  "\<C-o>a"
	endif
enddef
Each imap,smap <expr> <Tab> vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : pumvisible() ? '<C-n>' : vimrc#lazyload#SkipParen()
Each imap,smap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : pumvisible() ? '<C-p>' : '<S-Tab>'
# Copilotは様子見
#g:copilot_no_tab_map = true
#imap <silent> <script> <expr> ;c copilot#Accept("\<CR>")
#au vimrc VimEnter * Copilot disable
# }}}

# 🐶🍚 {{{
Enable g:skipslash_autocomplete
Each X=s,h Each nnoremap,tnoremap <silent> <C-w><C-X> <Plug>(shrink-height)<C-w>w
# }}}

# 設定が膨らんできたので別ファイルで定義 {{{
vimrc#lexima#LazyLoad()
vimrc#lsp#LazyLoad()
# }}}

# 遅延読み込みもの {{{
Each nmap,xmap S <ScriptCmd>vimrc#sandwich#LazyLoad('S')<CR>
nmap s <ScriptCmd>vimrc#easymotion#LazyLoad()<CR>s
command! -nargs=* Fern vimrc#fern#LazyLoad(<q-args>)
# }}}

# その他 {{{
Enable g:rainbow_active
g:auto_cursorline_wait_ms = &updatetime
Each X=w,b,e,ge nnoremap X <Plug>(smartword-X)
nnoremap [c <Plug>(GitGutterPrevHunk)
nnoremap ]c <Plug>(GitGutterNextHunk)
Each nnoremap,xnoremap <Space>c <Plug>(caw:hatpos:toggle)
# }}}

# 開発用 {{{
g:vimhelpgenerator_version = ''
g:vimhelpgenerator_author = 'Author  : utubo'
g:vimhelpgenerator_defaultlanguage = 'en'
g:vimhelpgenerator_uri = 'https://github.com/utubo/'
# }}}
# }}}

# ------------------------------------------------------
# コピペ寄せ集め色々 {{{
au vimrc InsertLeave * set nopaste
au vimrc FileReadPost *.log* normal! G
# https://github.com/astrorobot110/myvimrc/blob/master/vimrc
set matchpairs+=（:）,「:」,『:』,【:】,［:］,＜:＞
# https://github.com/Omochice/dotfiles
Each X=i,a,A nnoremap <expr> X !empty(getline('.')) ? 'X' : '"_cc'
# すごい
# https://zenn.dev/mattn/articles/83c2d4c7645faa
Each X=+,-,>,< Each nmap,tmap <C-w>X <C-w>X<SID>ws
Each X=+,-,>,< Each nnoremap,tnoremap <script> <SID>wsX <C-w>X<SID>ws
Each nmap,tmap <SID>ws <Nop>
# 感謝
# https://zenn.dev/vim_jp/articles/43d021f461f3a4
nnoremap <A-J> <Cmd>copy.<CR>
nnoremap <A-K> <Cmd>copy-1<CR>
xnoremap <A-J> :copy'<-1<CR>gv
xnoremap <A-K> :copy'>+0<CR>gv
# https://zenn.dev/vim_jp/articles/2024-10-07-vim-insert-uppercase
def ToupperPrevWord(): string
  const col = getpos('.')[2]
  const substring = getline('.')[0 : col - 1]
  const word = matchstr(substring, '\v<(\k(<)@!)*$')
  return toupper(word)
enddef
inoremap <expr> ;l $"<C-w>{ToupperPrevWord()}"

# }}}

# ------------------------------------------------------
# vimgrep {{{
command! -nargs=+ -complete=dir VimGrep vimrc#myutil#VimGrep(<f-args>)
au vimrc WinEnter * if winnr('$') ==# 1 && &buftype ==# 'quickfix' | q | endif
# }}}

# ------------------------------------------------------
# diff {{{
set splitright
set fillchars+=diff:\ # 削除行は空白文字で埋める
# diffモードを自動でoff https://hail2u.net/blog/software/vim-turn-off-diff-mode-automatically.html
au vimrc WinEnter * if (winnr('$') ==# 1) && !!getbufvar(winbufnr(0), '&diff') | diffoff | endif
# }}}

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
# }}}

# ------------------------------------------------------
# タブ幅やタブ展開を自動設定 {{{
def SetupTabstop()
	setlocal shiftwidth=0
	setlocal softtabstop=0
	if &ft ==# 'help'
		return
	endif
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
# filetype indent on が終わってから判定する
def SetupTabstopLazy()
	au vimrc SafeState * ++once SetupTabstop()
enddef
# ft ==# ''でも実行したいのでFileTypeではなくBufReadPost
au vimrc BufReadPost * SetupTabstopLazy()
SetupTabstopLazy()
# }}}

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
	add(msg, [&ff ==# 'unix' ? 'MoreMsg' : 'WarningMsg', &ff])
	add(msg, ['Normal', ' '])
	const enc = &fenc ?? &encoding
	add(msg, [enc ==# 'utf-8' ? 'MoreMsg' : 'WarningMsg', enc])
	add(msg, ['Normal', ' '])
	add(msg, ['MoreMsg', &ft])
	add(msg, ['Normal', ' '])
	const branch = g:System('git branch')->trim()->matchstr('\w\+$')
	add(msg, ['WarningMsg', branch])
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
	popup_create(expand('%:p'), { line: &lines - 1, col: 1, minheight: 1, maxheight: 1, minwidth: &columns, pos: 'botleft', moved: 'any' })
enddef

nnoremap <script> <C-g> <ScriptCmd>ShowBufInfo()<CR><ScriptCmd>PopupCursorPos()<CR>
# }}}

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
# }}}

# ------------------------------------------------------
# ファイル名を勝手につけて保存 {{{
def Sav()
	if !!bufname()
		update
		return
	endif
	const dt = strftime('%Y%m%d')
	var title = getline(1)
		->matchlist('^.\{0,10\}')[0]
		->substitute("[ \t\n*?[{`$\\%#'\"|!<>]", '_', 'g')
	var ext = &ft
	if getline(1) =~# '^vim9script\>.*'
		ext = 'vim'
		title = ''
	elseif &ft ==# 'markdown' || search('^ *- \[.\] ', 'cn')
		title = getline(1)
			->substitute('- \[.\]', '', 'g')
			->substitute('^[ -#]*', '', 'g')
		ext = 'md'
	elseif &ft ==# 'javascript'
		ext = 'js'
	elseif &ft ==# 'python'
		ext = 'py'
	elseif &ft ==# 'ruby'
		ext = 'rb'
	elseif &ft ==# 'typescript'
		ext = 'ts'
	elseif &ft ==# 'text' || &ft ==# 'help' || !&ft
		ext = 'txt'
	endif
	const fname = $'{dt}{!title ? '' : '_'}{title}.{ext}'
	const iname = input($"{getcwd()}\n:sav ", $'{fname}{repeat("\<Left>", len(ext) + 1)}')
	if !!iname
		execute 'sav' iname
	endif
enddef
command! Sav Sav()
# }}}

# ------------------------------------------------------
# セミコロンをプレフィックスに {{{
# ;nで決定、;mでキャンセル(;bにしたいが分割キーボードだと遠い…)
cnoremap ;n <CR>
Each nnoremap,inoremap ;n <Esc><Cmd>Sav<CR>
noremap  ;m <Esc>
inoremap ;m <Esc>`^
# <Esc>はコマンドが実行されちゃうし<C-c>は副作用が大きい
cnoremap ;m <Cmd>call feedkeys("\e", 'nt')<CR>
# その他
inoremap ;v ;<CR>
inoremap ;w <C-o>e<C-o>a
inoremap ;k 「」<C-g>U<Left>
inoremap ;u <Esc>u
nnoremap ;r "
nnoremap ;rr "0p
cnoremap ;r <C-r>
cnoremap <expr> ;rr trim(@")->substitute('\n', ' \| ', 'g')
cnoremap <expr> ;re escape(@", '~^$.*?/\[]')->substitute('\n', '\\n', 'g')
Each nnoremap,inoremap ;<Tab> <ScriptCmd>g:StayCurPos('normal! >>')<CR>
Each nnoremap,inoremap ;<S-Tab> <ScriptCmd>g:StayCurPos('normal! <<')<CR>
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
xnoremap <Tab> <ScriptCmd>g:StayCurPos('normal! >gv')<CR>
xnoremap <S-Tab> <ScriptCmd>g:StayCurPos('normal! <gv')<CR>
const vmode = ['v', 'V', "\<C-v>", "\<ESC>"] # minviml:fixed=vmode
xnoremap <script> <expr> v vmode[vmode->index(mode()) + 1]
# }}}

# ------------------------------------------------------
# コマンドモードあれこれ {{{
# Each nnoremap,xnoremap / <Cmd>noh<CR>/
# Each nnoremap,xnoremap ? <Cmd>noh<CR>?
# 考え中
Each nnoremap,xnoremap ;c :
Each nnoremap,xnoremap ;s <Cmd>noh<CR>/
Each nnoremap,xnoremap + :
Each nnoremap,xnoremap , :
Each nnoremap,xnoremap <Space><Space>, ,
# その他の設定
au vimrc CmdlineEnter * ++once vimrc#cmdmode#ApplySettings()
Each n,v {}noremap : <Cmd>call vimrc#cmdmode#Popup()<CR>:
Each /,? nnoremap {} <Cmd>call vimrc#cmdmode#Popup()<CR><Cmd>noh<CR>{}
# 念のため元の:をバックアップしておく
nnoremap \: :
# }}}

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

# }}}

# ------------------------------------------------------
# 閉じる {{{
def g:QuitWin(expr: string) # TODO: minifyするとばぐる？
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
Each X=h,j,k,l nnoremap qX <ScriptCmd>g:QuitWin('X')<CR>
nnoremap q <Nop>
nnoremap Q q
# 閉じる
nnoremap <expr> qq $"\<Cmd>confirm {winnr('$') ==# 1 && execute('ls')->split("\n")->len() !=# 1 ? 'bd' : 'q'}\<CR>"
# ウィンドウ
nnoremap qa <Cmd>confirm qa<CR>
nnoremap qOw <Cmd>confirm only<CR>
# タブ
nnoremap qt <Cmd>confirm tabclose +<CR>
nnoremap qT <Cmd>confirm tabclose -<CR>
nnoremap q# <Cmd>confirm tabclose #<CR>
nnoremap qOt <Cmd>confirm tabonly<CR>
# バッファ
nnoremap qb <Cmd>confirm bd<CR>
nnoremap qn <Cmd>bn<CR><Cmd>confirm bd<CR>
nnoremap qp <Cmd>bp<CR><Cmd>confirm bd<CR>
nnoremap <expr> qo $"\<Cmd>vim9cmd confirm bd {range(1, last_buffer_nr())->filter((i, b) => b !=# bufnr() && buflisted(b))->join()}\<CR>"
# デフォルト動作を保持
nnoremap q: q:
nnoremap q/ q/
nnoremap q? q?
# 開きなおす
nnoremap qQ <Cmd>e #<1<CR>
# }}}

# ------------------------------------------------------
# vimrc、plugin、colorscheme作成用 {{{
# カーソル行を実行するやつ
cnoremap <script> <expr> <SID>(exec_line) $'{getline('.')->substitute('^[ \t"#:]\+', '', '')}<CR>'
nnoremap <script> g: :<C-u><SID>(exec_line)
nnoremap <script> g9 :<C-u>vim9cmd <SID>(exec_line)
xnoremap g: :<C-u><Cmd>call getregion(getpos('v'), getpos('.'))->setcmdline()<CR><CR>
xnoremap g9 :<C-u>vim9cmd <Cmd>call getregion(getpos('v'), getpos('.'))->setcmdline()<CR><CR>
# カーソル位置のハイライトを確認するやつ
nnoremap <expr> <Space>hl $'<Cmd>hi {synID(line('.'), col('.'), 1)->synIDattr('name')->substitute('^$', 'Normal', '')}<CR>'
# 他の定義は.vim/after/ftplugin/vim.vim
# }}}

# ------------------------------------------------------
# その他細々したの {{{
if has('clipboard')
	au vimrc FocusGained * @" = @+
	au vimrc FocusLost   * @+ = @"
endif

nnoremap <F11> <ScriptCmd>vimrc#myutil#ToggleNumber()<CR>
nnoremap <F12> <Cmd>set wrap!<CR>

nmap gs :<C-u>%s///g<Left><Left><Left>
nmap gS :<C-u><Cmd>call setcmdline($'%s/{expand('<cword>')->escape('^$.*?/\[]')}//g')<CR><Left><Left>
xmap gs :s///g<Left><Left><Left>
xnoremap <SID>(setup-region-to-search) <Cmd>let @/ = $'\V{getregion(getpos('v'), getpos('.'))->join("\n")->escape('\')->substitute("\n", '\n', 'g')}'<CR>
xmap gS <SID>(setup-region-to-search)<Esc>:<C-u><Cmd>call setcmdline($'%s/{@/}//g')<CR><Left><Left>
xmap * <SID>(setup-region-to-search)<Esc>/<CR>

nnoremap <CR> j0
nnoremap Y y$
nnoremap <Space>p $p
nnoremap <Space>P ^P
Each A,B=j,+,k,- nnoremap <expr> A ((getline('.')->match('\S') + 1 ==# col('.')) ? 'B' : 'A') .. '<Cmd>noh<CR>'

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
xnoremap p P
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
# }}}

# ------------------------------------------------------
# 様子見中 使わなそうなら削除する {{{

# CSVとかのヘッダを固定表示する。ファンクションキーじゃなくてコマンド定義すればいいかな…
nnoremap <silent> <F10> <ESC>1<C-w>s:1<CR><C-w>w
xnoremap <F10> <ESC>1<C-w>s<C-w>w

# ここまで読(y)んだ
nnoremap <F9> my
nnoremap <Space><F9> 'y

# syntax固有の追加強調 {{{
def ClearMySyntax()
	for id in get(w:, 'my_syntax', [])
		silent! matchdelete(id)
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
# }}}

# yankした文字をecho {{{
set report=9999
# 他のプラグインと競合するのでタイマーで遅延させる
def g:EchoYankText(t: number)
	vimrc#echoyanktext#EchoYankText()
enddef
au vimrc TextYankPost * timer_start(1, g:EchoYankText)
#
# }}}
# 選択中の文字数をポップアップ {{{
def PopupVisualLength()
	var text = getregion(getpos('v'), getpos('.'))->join('')
	popup_create($'{strlen(text)}chars', {
		pos: 'botleft',
		line: 'cursor-1',
		col: 'cursor+1',
		fixed: true,
		moved: 'any',
		padding: [1, 1, 1, 1],
	})
enddef
xnoremap <C-g> <ScriptCmd>PopupVisualLength()<CR>
# }}}
#
# カーソル位置をポップアップ {{{
def PopupCursorPos()
	var p = getcurpos()
	popup_create($'{p[1]}:{p[2]}', {
		pos: 'botleft',
		line: 'cursor-1',
		col: 'cursor+1',
		moved: 'any',
		padding: [1, 1, 1, 1],
	})
enddef
#nnoremap <C-g> <ScriptCmd>PopupCursorPos()<CR>
# }}}

# `:%g!/re/d` の結果を新規ウインドウに表示
# (Buffer Regular Expression Print)
command! -nargs=1 Brep vimrc#myutil#Brep(<q-args>, <q-mods>)

# <C-f>と<C-b>、CTRLおしっぱがつらいので…
Each $=f,b nmap <C-$> <C-$><SID>(hold-ctrl)
Each $=f,b nnoremap <script> <SID>(hold-ctrl)$ <C-$><SID>(hold-ctrl)
nmap <SID>(hold-ctrl) <Nop>

command! -nargs=1 -complete=packadd HelpPlugins vimrc#myutil#HelpPlugins(<q-args>)

# 🐶🍚
onoremap A <Plug>(textobj-twochars-a)
onoremap I <Plug>(textobj-twochars-i)

# # BでCtrlpBuffer
# command! CtrlPBuffer delc CtrlPBuffer|vimrc#ctrlp#LazyLoad()|CtrlPBuffer
# nnoremap B <ScriptCmd>CtrlPBuffer<CR>

# noremap <F1> <Cmd>smile<CR>
# }}}

# ------------------------------------------------------
# † あともう1回「これ使ってないな…」と思ったときに消す {{{

# どっちも<C-w>w。左手オンリーと右手オンリーのマッピング
nnoremap <Space>w <C-w>w
nnoremap <Space>o <C-w>w
nnoremap <Space>d "_d

# <Tab>でtsvとかcsvとかhtmlの次の項目に移動
nnoremap <Tab> <Cmd>call search('\(^\\|\t\\|, *\)\S\?', 'e')<CR>
nnoremap <S-Tab> <Cmd>call search('\(^\\|\t\\|, *\)\S\?', 'be')<CR>
au vimrc FileType html,xml,svg {
	nnoremap <buffer> <silent> <Tab> <Cmd>call search('>')<CR><Cmd>call search('\S')<CR>
	nnoremap <buffer> <silent> <S-Tab> <Cmd>call search('>', 'b')<CR><Cmd>call search('>', 'b')<CR><Cmd>call search('\S')<CR>
}

# タブは卒業！
nnoremap <Space><Tab>u <Cmd>call vimrc#recentlytabs#ReopenRecentlyTab()<CR>
nnoremap <Space><Tab>l <Cmd>call vimrc#recentlytabs#ShowMostRecentlyClosedTabs()<CR>

# }}}

# ------------------------------------------------------
# デフォルトマッピングデー {{{
if strftime('%d') ==# '01'
	au vimrc VimEnter * {
		echow "✨ Today, Let's enjoy the default key mapping ! ✨"
		mapclear
		imapclear
		xmapclear
		cmapclear
		omapclear
		tmapclear
	}
endif
# }}}

# ------------------------------------------------------
# メモ {{{
# <F1> カレントディレクトリ
# <F2> MRU
# <F3> BufferList
# <F4> TabList
# <F5> 日付関係
# <F6>
# <F7>
# <F8>
# <F9> ここまでよんだ
# <F10> ヘッダ行を表示(あんまり使わない)
# <F11> 行番号表示切替
# <F12> 折り返し表示切替
# }}}

export def LazyLoad()
	# nop
enddef
