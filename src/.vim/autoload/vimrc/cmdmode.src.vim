vim9script

# cnoreabbrevちょっと改良 {{{
def MyAbbrev(): string
	return {
		cs: "\<C-u>colorscheme ",
		sb: "\<C-u>set background=\<Tab>\<Tab>",
		mv: "\<C-u>MoveFile ",
		vg: "\<C-u>VimGrep ",
		pd: "\<C-u>PopSelectDir ",
		th: "\<C-u>tab help ",
		'9': "\<C-u>vim9cmd ",
	}->get(getcmdline(), ' ')
enddef
cnoremap <expr> <Space> MyAbbrev()
#}}}

# ファイルを移動して保存 {{{
export def MoveFile(newname: string)
	const oldpath = expand('%')
	const newpath = expand(newname)
	if ! empty(oldpath) && filereadable(oldpath)
		if filereadable(newpath)
			echoh Error
			echo $'file "{newname}" already exists.'
			echoh None
			return
		endif
		rename(oldpath, newpath)
	endif
	execute 'saveas!' newpath
	# 開き直してMRUに登録
	edit
enddef
command! -nargs=1 -complete=file MoveFile vimrc#cmdmode#MoveFile(<f-args>)
#}}}

# ちょっと楽なgrep {{{
command! -nargs=+ -complete=dir VimGrep vimrc#myutil#VimGrep(<f-args>)
# }}}

# 式の左辺と右辺を交換 {{{
def ReplaceVisualSelection(
		pat: string, sub: string, flags: string = '')
	normal! gv
	for p in getregionpos(getpos('v'), getpos('.'))
		const buf = p[0][0]
		const line = p[0][1]
		const src = getbufline(buf, line)[0]
		const f = charidx(src, p[0][2] - 1)
		const t = charidx(src, p[1][2] - 1)
		const rep = src[f : t]->substitute(pat, sub, flags)
		setbufline(buf, line, src[0 : f - 1] .. rep .. src[t + 1 :])
	endfor
enddef
def SwapExpr(dlm: string = '[=<>!~#]\+')
	ReplaceVisualSelection(
		$'\(.*\S\)\(\s*{dlm}\s*\)\(\S.*\)',
		'\3\2\1'
	)
enddef
command! -range=% -nargs=? SwapExpr SwapExpr(<f-args>)
# }}}

# カーソル付近にポップアップ(like cmdline.vim) {{{
# NOTE: colorschme defualtで微妙だけど知らない！
# NOTE: cmdlineで<C-c>した場合、挙動がおかしくなるが
#       cmdlineを抜けるまでポップアップのゴーストが残るので
#       callback等では解決できない
# NOTE: cmdline.vimと違うところ
#       (これらが解決すればcmdline.vimに戻れるかも)
#   - [ ] プロンプトの右側にパディング無し
#     →58db2ef時点の124行目でハードコーディングされているので要相談かな？
#   - [x] カーソルが点滅する
#     →CmdlineCursorをタイマーで切り替えればできそう
#   - [x] ポップアップの状態を取得できる
#     →cmdline#_get().idを見ればよさそう
var popup = {
	win: 0,
	timer: 0,
	blink: false,
	blinktimer: 0,
	curpos: 0,
	gcr: '',
	msghl: [],
	offset: 0,
	# shade: 0,
}
export def Popup()
	if popup.win !=# 0
		echoerr 'cmdlineのポップアップが変なタイミングで実行された多分設定がおかしい'
		return
	endif
	# cmdlineを隠す
	popup.msghl = 'MsgArea'->hlget()
	const norhl = 'Normal'->hlget(true)[0]
	var msghl = 'MsgArea'->hlget(true)[0]
	msghl = msghl->copy()->extend({
		ctermfg: get(msghl, 'ctermbg', get(norhl, 'ctermbg', 'NONE')),
		guifg: get(msghl, 'guibg', get(norhl, 'guibg', 'NONE')),
		cleared: false,
	})
	[msghl]->hlset()
	# cmdline
	popup.win = popup_create('  ', { col: 'cursor-1', line: 'cursor+1', zindex: 2 })
	setbufvar(winbufnr(popup.win), '&filetype', 'vim')
	win_execute(popup.win, $'syntax match PMenuKind /^./')
	# カーソル関係
	set t_ve=
	if !popup.gcr
		popup.gcr = &guicursor
	endif
	set guicursor=c:CursorTransparent
	['Cursor'->hlget()[0]->copy()->extend({ name: 'vimrcCmdlineCursor' })]->hlset()
	# イベント等
	augroup vimrc_cmdline_popup
		au!
		au ModeChanged c:[^c] ClosePopup()
		au VimLeavePre * RestoreCursor()
	augroup END
	MapTab2OpenPum()
	popup.blinktimer = timer_start(500, vimrc#cmdmode#BlinkPopupCursor, { repeat: -1 })
	popup.updatetimer = timer_start(16, vimrc#cmdmode#UpdatePopup, { repeat: -1 })
	# これやっちゃうとビジュアルモードの選択範囲とかhlsearchがわかんなくなる
	# popup.shade = matchadd('NonText', '.')
enddef

def ClosePopup()
	augroup vimrc_cmdline_popup
		au!
	augroup END
	RestoreCursor()
	timer_stop(popup.updatetimer)
	popup.updatetimer = 0
	timer_stop(popup.blinktimer)
	popup.blinktimer = 0
	popup_close(popup.win)
	popup.win = 0
	ClosePum()
	hi MsgArea None
	popup.msghl->hlset()
	silent! cunmap <Tab>
	redraw
enddef

export def UpdatePopup(timer: number)
	if popup.win ==# 0 || mode() !=# 'c' || popup_list()->index(popup.win) ==# -1
		# ここに来るのはポップアップが意図せず残留したとき
		# または<C-c>などで強引にポップアップを閉じられたとき
		# まずは内部的な変数をリセットする
		ClosePopup()
		# <Esc>でcmdlineを抜けちゃう。副作用は知らない！出たらその時考える！
		if mode() ==# 'c'
			feedkeys("\<Esc>", 'nt')
		endif
		return
	endif
	const text = getcmdtype() .. getcmdline() .. getcmdprompt() .. ' '
	if &columns < strdisplaywidth(text)
		ClosePopup()
	else
		popup_settext(popup.win, text)
		ShowPopupCursor()
	endif
	redraw
enddef

def ShowPopupCursor()
	win_execute(popup.win, 'call clearmatches()')

	if !getcmdline()
		popup.offset = getcmdpos() - getcmdscreenpos() + 1
	endif

	var c = getcmdscreenpos() + popup.offset
	if c !=# popup.curpos
		popup.blink = true
		popup.curpos = c
	endif
	if popup.blink
		win_execute(popup.win, $'call matchadd("vimrcCmdlineCursor", "\\%1l\\%{c}v.")')
	endif
enddef

export def BlinkPopupCursor(timer: number)
	popup.blink = !popup.blink
enddef

def RestoreCursor()
	if !!popup.gcr
		&guicursor = popup.gcr
		popup.gcr = ''
	endif
	set t_ve&
enddef

var pumid = 0
var pumpat = ''

def MapTab2OpenPum()
	cnoremap <Tab> <ScriptCmd>vimrc#cmdmode#PopupPum()<CR>
enddef

export def PumKeyDown(id: number, k: string): bool
	const i = getwininfo(pumid)[0]
	const l = getcurpos(pumid)[1]
	if k ==# "\<Tab>" || k ==# "\<C-n>"
		const lc = i.bufnr->getbufinfo()[0].linecount
		noautocmd win_execute(pumid, $'normal! { l < lc ? 'j' : 'gg' }')
	elseif k ==# "\<S-Tab>" || k ==# "\<C-p>"
		noautocmd win_execute(pumid, $'normal! { l <= 1 ? 'G' : 'k' }')
	else
		ClosePum()
		MapTab2OpenPum()
		return false
	endif
	setcmdline(pumpat .. i.bufnr->getbufline(getcurpos(pumid)[1])[0])
	redraw
	return true
enddef

export def PopupPum()
	cunmap <Tab>
	ClosePum()
	pumpat = getcmdline()
	const c = getcompletion(pumpat, 'cmdline')
	if !c
		return
	endif
	pumpat = pumpat->substitute('\S*$', '', '')
	var p = screenpos(0, line('.'), col('.'))
	var maxheight = &lines
	var pos = 'topleft'
	if p.row < &lines / 2
		p.row += 2
		maxheight -= p.row
	else
		p.row
		maxheight = p.row
		pos = 'botleft'
	endif
	pumid = popup_create(c, {
		zindex: 3,
		wrap: 0,
		cursorline: 1,
		padding: [0, 1, 0, 1],
		mapping: 1,
		filter: 'vimrc#cmdmode#PumKeyDown',
		col: max([2, p.col]) + strdisplaywidth(pumpat) - 1,
		line: p.row,
		maxheight: maxheight,
		pos: pos,
	})
	setcmdline(pumpat .. getbufline(winbufnr(pumid), 1)[0])
enddef

def ClosePum()
	if  !!pumid
		popup_close(pumid)
		pumid = 0
	endif
enddef
# }}}

# vim9skkpとの連携 {{{
export def ForVim9skk(popup_pos: any): any
	if popup.win !=# 0
		var c = popup_getpos(popup.win)
		popup_pos.col = c.col + getcmdscreenpos() - 1 + popup.offset
		popup_pos.line = c.line
	endif
	return popup_pos
enddef
g:vim9skkp.getcurpos = vimrc#cmdmode#ForVim9skk
# }}}

# コマンドモードのマッピングとか {{{
export def ApplySettings()
	command! -nargs=1 -complete=dir PopSelectDir expand(<f-args>)->fnamemodify(':p')->popselect#dir#Popup()
	# <LocalLeader>系
	# Note: <Esc>だとコマンドが実行されちゃうし<C-c>は副作用が大きい
	cnoremap <LocalLeader>(cancel) <Cmd>call feedkeys("\e", 'nt')<CR>
	cnoremap <LocalLeader>(ok) <CR>
	RLK cmap <LocalLeader> k <C-p>
	RLK cmap <LocalLeader> K <C-n>
	cnoremap <LocalLeader>r <C-r>
	cnoremap <expr> <LocalLeader>rr trim()->substitute('\n', ' \| ', 'g')
	cnoremap <expr> <LocalLeader>re escape(@", '~^$.*?/\[]')->substitute('\n', '\\n', 'g')
enddef
# }}}
