vim9script

# ------------------------------------------------------
# ルーラー(タブパネルに表示)

var curwin = 0
var curbuf = 0
var rulerinfo = ''

au vimrc CursorMoved,CursorMovedI * au SafeState * ++once :redrawtabp

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

export def MyRuler(): string
	if !v:vim_did_enter
		return ''
	endif
	const p = getcurpos(curwin)
	const b = getbufinfo(curbuf)
	var text = !b ? '' : $'{p[1]}/{b[0].linecount}:{p[2]}{rulerinfo}'
	if exists('g:vim9skkp_status')
		text ..= $' {g:vim9skkp_status.mode}'
	else
		text ..= ' _A'
	endif
	return $'%#TabPanelFill#{anypanel#align#Center(text)}'
enddef
