vim9script

# ------------------------------------------------------
# ルーラー

var curwin = 0
var curbuf = 0
var rulerinfo = ''

au vimrc WinEnter,BufEnter * {
	curwin = winnr()
	curbuf = winbufnr(curwin)
	rulerinfo = ''
	const ff = getbufvar(curbuf, '&ff')
	if ff ==# 'mac'
		rulerinfo = ' CR'
	elseif ff ==# 'unix'
		if has('win32')
			rulerinfo = ' LF'
		endif
	elseif !has('win32')
		rulerinfo = ' CRLF'
	endif
	const fenc = getbufvar(curbuf, '&fenc')
	if fenc !=# 'utf-8'
		rulerinfo ..= $' {fenc}'
	endif
}

def! g:MyRuler(): string
	const p = getcurpos(curwin)
	const b = getbufinfo(curbuf)
	var text = !b ? '' : $'{p[1]}/{b[0].linecount}:{p[2]}{rulerinfo}'
	if exists('g:vim9skkp_status')
		text ..= $' {g:vim9skkp_status.mode}'
	endif
	# tabpanelの下にセンタリングして表示する
	return repeat(' ', 9 - len(text) / 2) .. text
enddef

export def Apply()
	# テスト時などバッファがないとgetbufinfoが空になってしまうのでVimEnterを待ってからセット
	# って感じだったんだけどこのファイルを読むタイミングを変えたので大丈夫
	# au vimrc VimEnter * {
		set rulerformat=%#MsgArea#%{g:MyRuler()}
	# }
enddef
