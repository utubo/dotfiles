vim9script

# ------------------------------------------------------
# プラグイン {{{

# zenmode {{{
au vimrc User Vim9skkModeChanged zenmode#Invalidate()
#}}}

# vim9skk {{{
g:vim9skk = {
	keymap: {
		toggle: ['<C-j>', ';j'],
		midasi: [':', 'Q'],
	},
	mode_label_timeout: 500,
}
g:vim9skk_mode = '' # statuslineでエラーにならないように念の為設定しておく
nnoremap ;j i<Plug>(vim9skk-enable)
# インサートモードが終わったらオフにする
au vimrc ModeChanged [ic]:* au SafeState * ++once vim9skk#Disable()
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

# Git {{{
command! -nargs=* GitAdd vimrc#git#GitAdd(<q-args>)
command! -nargs=1 -complete=customlist,vimrc#git#ConventionalCommits GitCommit Git commit -m <q-args>
command! -nargs=1 GitTagPush vimrc#git#GitTagPush(<q-args>)
nnoremap <Space>ga <Cmd>GitAdd -A<CR>
nnoremap <Space>gA :<C-u>Git add %
nnoremap <Space>gc :<C-u>GitCommit<Space><Tab>
nnoremap <Space>gp :<C-u>Git push<End>
nnoremap <Space>gs <Cmd>Git status -sb<CR>
nnoremap <Space>gv <Cmd>Gvdiffsplit<CR>
nnoremap <Space>gd <Cmd>Gdiffsplit<CR>
nnoremap <Space>gl <Cmd>Git pull<CR>
nnoremap <Space>gt :<C-u>GitTagPush<Space>
nnoremap <Space>gC :<C-u>Git checkout %
#}}}

# gh {{{
# ftpluginにすると定義がバラバラになって見通し悪くなるかな
au vimrc FileType gh-repos {
	nnoremap <buffer> i <ScriptCmd>execute 'edit!' ['gh:/', getline('.')->matchstr('\S\+'), 'issues']->join('/')<CR>
}
au vimrc FileType gh-issues {
	nnoremap <buffer> <CR> <ScriptCmd>execute 'new' [expand('%'), getline('.')->matchstr('[0-9]\+'), 'comments']->join('/')<CR>
	nnoremap <buffer> r <ScriptCmd>execute 'edit!' expand('%:h:h') .. '/repos'<CR>
}
au vimrc FileType gh-issue-comments {
	nnoremap <buffer> <CR> <ScriptCmd>execute 'bo vsplit' [expand('%'), getline('.')->matchstr('[0-9]\+')]->join('/')<CR><Cmd>setlocal wrap<CR>
}
nnoremap <Space>gh <Cmd>tabe gh://utubo/repos<CR>
# }}}

# MRU {{{
nnoremap <F2> <Cmd>MRUToggle<CR>
g:MRU_Exclude_Files = has('win32') ? $'{$TEMP}\\.*' : '^/tmp/.*\|^/var/tmp/.*'
# MRUに関してのその他の設定は.vim/after/ftplugin/mru.src.vimで指定している
#}}}

# lexima {{{
# 最初のInsertEnterが動かないなぁ
# au vimrc InsertEnterPre,CmdEnterPre ++once vimrc#lexima#LazyLoad()
vimrc#lexima#LazyLoad()
# }}}

# LSP {{{
var lspOptions = {
	diagSignErrorText: '🐞',
	diagSignHintText: '💡',
	diagSignInfoText: '💠',
	diagSignWarningText: '🐝',
	showDiagWithVirtualText: true,
	diagVirtualTextAlign: 'after',
}
const commandExt = has('win32') ? '.cmd' : ''
var lspServers = [{
	name: 'typescriptlang',
	filetype: ['javascript', 'typescript'],
	path: $'typescript-language-server{commandExt}',
	args: ['--stdio'],
}, {
	name: 'vimlang',
	filetype: ['vim'],
	path: $'vim-language-server{commandExt}',
	args: ['--stdio'],
}, {
	name: 'htmllang',
	filetype: ['html'],
	path: $'html-languageserver{commandExt}',
	args: ['--stdio'],
}, {
	name: 'jsonlang',
	filetype: ['json'],
	path: $'vscode-json-languageserver{commandExt}',
	args: ['--stdio'],
}]
packadd lsp
g:LspOptionsSet(lspOptions)
g:LspAddServer(lspServers)
nnoremap [l <Cmd>LspDiagPrev<CR>
nnoremap ]l <Cmd>LspDiagNext<CR>
#}}}

# Portal {{{
nnoremap <Leader>a <Cmd>PortalAim<CR>
nnoremap <Leader>b <Cmd>PortalAim blue<CR>
nnoremap <Leader>o <Cmd>PortalAim orange<CR>
nnoremap <Leader>r <Cmd>PortalReset<CR>
#}}}

# sandwich {{{
Enable g:sandwich_no_default_key_mappings
Enable g:operator_sandwich_no_default_key_mappings
Each nmap,xmap S <ScriptCmd>vimrc#sandwich#ApplySettings('S')<CR>
#}}}

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
#}}}

# 🐶🍚 {{{
g:skipslash_autocomplete = 1
g:loaded_matchparen = 1
g:loaded_matchit = 1
nnoremap <Space>t <ScriptCmd>tabpopupmenu#popup()<CR>
nnoremap <Space>T <ScriptCmd>tablist#Show()<CR>
Each nnoremap,tnoremap <silent> <C-w><C-s> <Plug>(shrink-height)<C-w>w
Each nnoremap,tnoremap <silent> <C-w><C-h> <Plug>(shrink-width)<C-w>w
noremap <Space>s <Plug>(jumpcursor-jump)
vimrc#hlpairs#LazyLoad()
# }}}

# 遅延読み込みもの {{{
nmap <C-p> <ScriptCmd>vimrc#ctrlp#LazyLoad()<CR><C-p>
nmap s <ScriptCmd>vimrc#easymotion#LazyLoad()<CR>s
command! -nargs=* Fern vimrc#fern#LazyLoad(<q-args>)
nnoremap <expr> <F1> $"\<Cmd>Fern . -reveal=% -opener={!bufname() && !&mod ? 'edit' : 'split'}\<CR>"
# }}}

# その他 {{{
Enable g:rainbow_active
g:auto_cursorline_wait_ms = &updatetime
Each w,b,e,ge nnoremap {0} <Plug>(smartword-{0})
nnoremap [c <Plug>(GitGutterPrevHunk)
nnoremap ]c <Plug>(GitGutterNextHunk)
Each nnoremap,xnoremap <Space>c <Plug>(caw:hatpos:toggle)
#}}}

# 開発用 {{{
g:vimhelpgenerator_version = ''
g:vimhelpgenerator_author = 'Author  : utubo'
g:vimhelpgenerator_defaultlanguage = 'en'
g:vimhelpgenerator_uri = 'https://github.com/utubo/'
#}}}
#}}} -------------------------------------------------------

# ------------------------------------------------------
# コピペ寄せ集め色々 {{{
au vimrc InsertLeave * set nopaste
au vimrc BufReadPost *.log* normal! G
xnoremap * "vy/\V<C-r>=substitute(escape(@v,'\/'),"\n",'\\n','g')<CR><CR>
# https://github.com/astrorobot110/myvimrc/blob/master/vimrc
set matchpairs+=（:）,「:」,『:』,【:】,［:］,＜:＞
# https://github.com/Omochice/dotfiles
Each i,a,A nnoremap <expr> {0} !empty(getline('.')) ? '{0}' : '"_cc'
# すごい
# https://zenn.dev/mattn/articles/83c2d4c7645faa
Each +,-,>,< Each nmap,tmap <C-w>{0} <C-w>{0}<SID>ws
Each +,-,>,< Each nnoremap,tnoremap <script> <SID>ws{0} <C-w>{0}<SID>ws
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

#}}} -------------------------------------------------------

# ------------------------------------------------------
# vimgrep {{{
command! -nargs=+ -complete=dir VimGrep vimrc#myutil#VimGrep(<f-args>)
au vimrc WinEnter * if winnr('$') ==# 1 && &buftype ==# 'quickfix' | q | endif
#}}} -------------------------------------------------------

# ------------------------------------------------------
# diff {{{
set splitright
set fillchars+=diff:\ # 削除行は空白文字で埋める
# diffモードを自動でoff https://hail2u.net/blog/software/vim-turn-off-diff-mode-automatically.html
au vimrc WinEnter * if (winnr('$') ==# 1) && !!getbufvar(winbufnr(0), '&diff') | diffoff | endif
#}}} -------------------------------------------------------

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
def SetupTabstopLazy()
	# filetype indent on が終わってから判定する
	au vimrc SafeState * ++once SetupTabstop()
enddef
# ft ==# ''でも実行したいのでFileTypeではなくBufReadPost
au vimrc BufReadPost * SetupTabstopLazy()
SetupTabstopLazy()
#}}} -------------------------------------------------------

# ------------------------------------------------------
# バッファ操作 {{{
nnoremap gn <Cmd>bnext<CR>
nnoremap gp <Cmd>bprevious<CR>
g:recentBufnr = 0
au vimrc BufLeave * g:recentBufnr = bufnr()
nnoremap <expr> gr $"\<Cmd>b{g:recentBufnr}\<CR>"

# 複数開いているときだけ自作buflineを表示する
var bufitems = []
def RefreshBufList()
	bufitems = []
	for ls in execute('ls')->split("\n")
		const m = ls->matchlist('^ *\([0-9]\+\) \([^"]*\)"\(.*\)" \+line [0-9]\+')
		if !m->empty()
			var b = {
				nr: m[1],
				name: m[2][2] =~# '[RF?]' ? '[Term]' : m[3]->pathshorten(),
				current: m[2][0] ==# '%',
			}
			bufitems += [b]
			b.width = strdisplaywidth($' {b.nr}{b.name} ')
		endif
	endfor
	EchoBufLine()
	g:zenmode.preventEcho = bufitems->len() > 1
enddef
def EchoBufLine()
	if bufitems->len() <= 1
		return
	endif
	if ['ControlP']->index(bufname('%')) !=# -1
		return
	endif
	if mode() ==# 'c'
		return
	endif
	redraw
	var s = 0
	var e = 0
	var w = getwininfo(win_getid(1))[0].textoff
	var hasNext = false
	var hasPrev = false
	var containCurrent = false
	for b in bufitems
		w += b.width
		if &columns - 5 < w
			if containCurrent
				e -= 1
				hasNext = true
				break
			endif
			s += 1
			hasPrev = true
		endif
		if b.current
			containCurrent = true
		endif
		e += 1
	endfor
	w = getwininfo(win_getid(1))[0].textoff
	echohl TablineFill
	echon repeat(' ', w)
	if hasPrev
		echohl Tabline
		echon '< '
		w += 2
	endif
	for b in bufitems[s : e]
		w += b.width
		if b.current
			echohl TablineSel
		else
			echohl Tabline
		endif
		echon $'{b.nr} {b.name} '
	endfor
	if hasNext
		echohl Tabline
		echon '>'
		w += 1
	endif
	const pad = &columns - 1 - w
	if 0 < pad
		echohl TablineFill
		echon repeat(' ', &columns - 1 - w)
	endif
	echohl Normal
enddef
def OnBufDelete()
	RefreshBufList()
	if bufitems->len() <= 1
		zenmode#RedrawNow()
	endif
	au vimrc BufAdd,BufEnter * au vimrc SafeState * ++once RefreshBufList()
enddef
au vimrc BufDelete,BufWipeout * au vimrc SafeState * ++once OnBufDelete()
au vimrc CursorMoved * EchoBufLine()
#}}}

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
# Tabline {{{
set tabline=%!vimrc#tabline#MyTabline()
set guitablabel=%{vimrc#tabline#MyTablabel()}
#}}}

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
#}}} -------------------------------------------------------

# ------------------------------------------------------
# セミコロン {{{
# インサートモードでも使うプレフィックス
# 気づいたらコロンをセミコロンにマッピングしてなかった…
# ;nで決定、;mでキャンセル
cnoremap ;n <CR>
Each nnoremap,inoremap ;n <Cmd>update<CR><Esc>
inoremap ;m <Esc>`^
cnoremap ;m <C-c>
noremap  ;m <Esc>
# その他
inoremap ;v ;<CR>
inoremap ;w <C-o>e<C-o>a
inoremap ;k 「」<C-g>U<Left>
inoremap ;u <Esc>u
nnoremap ;r "
nnoremap ;rr "0p
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
#}}}

# ------------------------------------------------------
# コマンドモードあれこれ {{{
Each nnoremap,xnoremap / <Cmd>noh<CR>/
Each nnoremap,xnoremap ? <Cmd>noh<CR>?
# 考え中
Each nnoremap,xnoremap ;c :
Each nnoremap,xnoremap ;s <Cmd>noh<CR>/
Each nnoremap,xnoremap + :
Each nnoremap,xnoremap , :
Each nnoremap,xnoremap <Space><Space>, ,
# その他の設定
au vimrc CmdlineEnter * ++once vimrc#cmdline#ApplySettings()
#}}}

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

#}}} -------------------------------------------------------

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
Each h,j,k,l nnoremap q{0} <ScriptCmd>g:QuitWin('{0}')<CR>
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
#}}} -------------------------------------------------------

# ------------------------------------------------------
# vimrc、plugin、colorscheme作成用 {{{
# カーソル行を実行するやつ
cnoremap <script> <expr> <SID>(exec_line) $'{getline('.')->substitute('^[ \t"#:]\+', '', '')}<CR>'
nnoremap <script> g: :<C-u><SID>(exec_line)
nnoremap <script> g9 :<C-u>vim9cmd <SID>(exec_line)
xnoremap g: "vy:<C-u><C-r>=@v<CR><CR>
xnoremap g9 "vy:<C-u>vim9cmd <C-r>=@v<CR><CR>
# カーソル位置のハイライトを確認するやつ
nnoremap <expr> <Space>hl $'<Cmd>hi {synID(line('.'), col('.'), 1)->synIDattr('name')->substitute('^$', 'Normal', '')}<CR>'
# 他の定義は.vim/after/ftplugin/vim.vim
#}}}

# ------------------------------------------------------
# その他細々したの {{{
if has('clipboard')
	au vimrc FocusGained * @" = @+
	au vimrc FocusLost   * @+ = @"
endif

# カーソルの形
if has('vim_starting')
	&t_SI = "\e[6 q"
	&t_EI = "\e[2 q"
	&t_SR = "\e[4 q"
endif

nnoremap <F11> <ScriptCmd>vimrc#myutil#ToggleNumber()<CR>
nnoremap <F12> <Cmd>set wrap!<CR>

nnoremap gs :<C-u>%s///g<Left><Left><Left>
nnoremap gS :<C-u>%s/<C-r>=escape(expand('<cword>'), '^$.*?/\[]')<CR>//g<Left><Left>
xnoremap gs :s///g<Left><Left><Left>
xnoremap gS "vy:<C-u>%s/<C-r>=substitute(escape(@v,'^$.*?/\[]'),"\n",'\\n','g')<CR>//g<Left><Left>

nnoremap <CR> j0
nnoremap Y y$
nnoremap <Space>p $p
nnoremap <Space>P ^P
nnoremap <expr> j (getline('.')->match('\S') + 1 ==# col('.')) ? '+' : 'j'
nnoremap <expr> k (getline('.')->match('\S') + 1 ==# col('.')) ? '-' : 'k'

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

command! -nargs=1  -complete=customlist,vimrc#myutil#HelpList Help vimrc#myutil#Help(<q-args>)
#}}} -------------------------------------------------------

# ------------------------------------------------------
# 様子見中 使わなそうなら削除する {{{
au vimrc User InputCR feedkeys("\<C-g>u", 'n')

nnoremap <Space>n <Cmd>nohlsearch<CR>
au vimrc CursorHold * feedkeys(' n') # nohはauで動かない(:help noh)

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
#}}}

# yankした文字をecho {{{
set report=9999
# 他のプラグインと競合するのでタイマーで遅延させる
def g:EchoYankText(t: number)
	vimrc#echoyanktext#EchoYankText()
enddef
au vimrc TextYankPost * timer_start(1, g:EchoYankText)
#
#}}}
# 選択中の文字数をポップアップ {{{
def PopupVisualLength()
	normal! "vygv
	var text = @v->substitute('\n', '', 'g')
	popup_create($'{strlen(text)}chars', {
		pos: 'botleft',
		line: 'cursor-1',
		col: 'cursor+1',
		moved: 'any',
		padding: [1, 1, 1, 1],
	})
enddef
xnoremap <C-g> <ScriptCmd>PopupVisualLength()<CR>
#}}}

# `:%g!/re/d` の結果を新規ウインドウに表示
# (Buffer Regular Expression Print)
command! -nargs=1 Brep vimrc#myutil#Brep(<q-args>, <q-mods>)

# <C-f>と<C-b>、CTRLおしっぱがつらいので…
Each f,b nmap <C-{0}> <C-{0}><SID>(hold-ctrl)
Each f,b nnoremap <script> <SID>(hold-ctrl){0} <C-{0}><SID>(hold-ctrl)
nmap <SID>(hold-ctrl) <Nop>

# 🐶🍚
onoremap A <Plug>(textobj-twochars-a)
onoremap I <Plug>(textobj-twochars-i)

#noremap <F1> <Cmd>smile<CR>
#}}} -------------------------------------------------------

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

#}}} -------------------------------------------------------

# ------------------------------------------------------
# デフォルトマッピングデー {{{
if strftime('%d') ==# '01'
	au vimrc VimEnter * {
		notification#show("✨ Today, Let's enjoy the default key mapping ! ✨")
		mapclear
		imapclear
		xmapclear
		cmapclear
		omapclear
		tmapclear
		# CursorHoldでfeedkyesしているので…
		nnoremap <Space>n <Nop>
	}
endif
#}}} -------------------------------------------------------

export def LazyLoad()
	# nop
enddef

