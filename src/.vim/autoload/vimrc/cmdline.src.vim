vim9script

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

# cnoreabbrevちょっと改良 {{{
def MyAbbrev(): string
	return {
		cs: "\<C-u>colorscheme ",
		sb: "\<C-u>set background=\<Tab>",
		mv: "\<C-u>MoveFile ",
	}->get(getcmdline(), ' ')
enddef
#}}}

# カーソル付近にポップアップ {{{
# NOTE: cmdlineで<C-c>した場合、挙動がおかしくなるが
# cmdlineを抜けるまでポップアップのゴーストが残るのでcallback等では解決できない
var popupwin = 0
var popuptimer = 0
export def Popup()
	popupwin = popup_create('  ', { col: 'cursor-1', line: 'cursor+1', })
	setbufvar(winbufnr(popupwin), '&filetype', 'vim')
	win_execute(popupwin, $'syntax match PMenuKind /^./')
	augroup vimrc_cmdline_popup
		au!
		au ModeChanged c:[^c] ClosePopup()
	augroup END
	popuptimer = timer_start(16, vimrc#cmdline#RedrawPopup, { repeat: -1 })
enddef

def ClosePopup()
	augroup vimrc_cmdline_popup
		au!
	augroup END
	if popuptimer !=# 0
		timer_stop(popuptimer)
		popuptimer = 0
	endif
	if popupwin !=# 0
		popup_close(popupwin)
		popupwin = 0
	endif
enddef

export def RedrawPopup(timer: number)
	if popupwin ==# 0
		return
	endif
	if popup_list()->index(popupwin) ==# -1
		# ここに来るのは<C-c>などで強引にポップアップを閉じられたとき
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
	popup_settext(popupwin, text)
	win_execute(popupwin, $'call clearmatches()')
	const c = getcmdscreenpos()
	win_execute(popupwin, $'echo matchadd("Cursor", "\\%1l\\%{c}v.")')
enddef
# }}}

export def ApplySettings()
	cnoremap jj <CR>
	cnoremap jk <C-c>
	cnoremap <A-h> <Left>
	cnoremap <A-j> <Up>
	cnoremap <A-k> <Down>
	cnoremap <A-l> <Right>
	cnoremap ;r <C-r>
	cnoremap <expr> ;rr trim(@")->substitute('\n', ' \| ', 'g')
	cnoremap <expr> ;re escape(@", '~^$.*?/\[]')->substitute('\n', '\\n', 'g')
	cnoremap <expr> <Space> MyAbbrev()
	command! -nargs=1 -complete=file MoveFile vimrc#cmdline#MoveFile(<f-args>)
enddef

