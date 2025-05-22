vim9script

# cnoreabbrevちょっと改良 {{{
def MyAbbrev(): string
	return {
		cs: "\<C-u>colorscheme ",
		sb: "\<C-u>set background=\<Tab>",
		mv: "\<C-u>MoveFile ",
		pd: "\<C-u>PopSelectDir ",
		tb: "\<C-u>tab help ",
	}->get(getcmdline(), ' ')
enddef
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
#}}}

# カーソル付近にポップアップ(like cmdline.vim) {{{
# NOTE: colorschme defualtで微妙だけど知らない！
# NOTE: cmdlineで<C-c>した場合、挙動がおかしくなるが
#       cmdlineを抜けるまでポップアップのゴーストが残るので
#       callback等では解決できない
# TODO: wildmenumode=fuzzyを使いたいけどgetcmdline()に反映されない
var popup = {
	win: 0,
	timer: 0,
	blink: false,
	blinktimer: 0,
	curpos: 0,
	curhl: [],
	msghl: [],
}
export def Popup()
	if popup.win !=# 0
		echoerr 'cmdlineのポップアップが変なタイミングで実行された多分設定がおかしい'
		return
	endif
	# cmdlineを隠す
	popup.msghl = 'MsgArea'->hlget()
	const norhl = 'Normal'->hlget()[0]
	var msghl = popup.msghl[0]->copy()->extend({
		ctermfg: get(popup.msghl[0], 'ctermbg', get(norhl, 'ctermbg', 'NONE')),
		guifg: get(popup.msghl[0], 'guibg', get(norhl, 'guibg', 'NONE')),
		cleared: false,
	})
	[msghl]->hlset()
	# cmdline
	popup.win = popup_create('  ', { col: 'cursor-1', line: 'cursor+1', zindex: 2 })
	setbufvar(winbufnr(popup.win), '&filetype', 'vim')
	win_execute(popup.win, $'syntax match PMenuKind /^./')
	# カーソル関係
	set t_ve=
	popup.curhl = 'Cursor'->hlget()
	[popup.curhl[0]->copy()->extend({ name: 'vimrcCmdlineCursor' })]->hlset()
	hi Cursor NONE
	# イベント等
	augroup vimrc_cmdline_popup
		au!
		au ModeChanged c:[^c] ClosePopup()
		au VimLeavePre * RestoreCursor()
	augroup END
	popup.blinktimer = timer_start(500, vimrc#cmdmode#BlinkPopupCursor, { repeat: -1 })
	popup.updatetimer = timer_start(16, vimrc#cmdmode#UpdatePopup, { repeat: -1 })
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
	popup.msghl->hlset()
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
		redraw
		return
	endif
	popup_settext(popup.win, text)
	ShowPopupCursor()
enddef

def ShowPopupCursor()
	win_execute(popup.win, 'call clearmatches()')
	var c = getcmdscreenpos()
	if c !=# popup.curpos
		popup.blink = true
		popup.curpos = c
	endif
	if popup.blink
		win_execute(popup.win, $'echo matchadd("vimrcCmdlineCursor", "\\%1l\\%{c}v.")')
	endif
enddef

export def BlinkPopupCursor(timer: number)
	popup.blink = !popup.blink
enddef

def RestoreCursor()
	hlset(popup.curhl)
	set t_ve&
enddef
# }}}

# vim9skkとの連携 {{{
export def ForVim9skk(popup_pos: any): any
	if popup.win !=# 0
		var c = popup_getpos(popup.win)
		popup_pos.col += c.col - 1
		popup_pos.line += c.line - &lines
	endif
	return popup_pos
enddef
g:vim9skk.change_popuppos = vimrc#cmdmode#ForVim9skk
# }}}

export def ApplySettings()
	cnoremap <expr> <Space> MyAbbrev()
	command! -nargs=1 -complete=file MoveFile vimrc#cmdmode#MoveFile(<f-args>)
	command! -nargs=1 -complete=dir PopSelectDir popselect#dir#Popup(<f-args>)
	# <LocalLeader>系
	# Note: <Esc>だとコマンドが実行されちゃうし<C-c>は副作用が大きい
	cnoremap <LocalLeader>(cancel) <Cmd>call feedkeys("\e", 'nt')<CR>
	cnoremap <LocalLeader>(ok) <CR>
	cnoremap <LocalLeader>r <C-r>
	RLK cmap <LocalLeader> k <C-p>
	RLK cmap <LocalLeader> K <C-n>
	cnoremap <expr> <LocalLeader>rr trim()->substitute('\n', ' \| ', 'g')
	cnoremap <expr> <LocalLeader>re escape(@", '~^$.*?/\[]')->substitute('\n', '\\n', 'g')
enddef
