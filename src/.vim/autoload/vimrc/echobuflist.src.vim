vim9script

# 複数bufを開いている場合、一覧を画面下部に表示する

var buflist = []
def RefreshBufList()
	buflist = []
	for ls in execute('ls')->split("\n")
		const m = ls->matchlist('^ *\([0-9]\+\) \([^"]*\)"\(.*\)" \+line [0-9]\+')
		if !m->empty()
			var b = {
				nr: m[1],
				name: m[2][2] =~# '[RF?]' ? '[Term]' : m[3]->pathshorten(),
				current: m[2][0] ==# '%',
			}
			buflist += [b]
			b.width = strdisplaywidth($' {b.nr}{b.name} ')
		endif
	endfor
	EchoBufList()
	g:zenmode.preventEcho = buflist->len() > 1
enddef

def EchoBufList()
	if buflist->len() <= 1
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
	for b in buflist
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
	for b in buflist[s : e]
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
	if buflist->len() <= 1
		zenmode#RedrawNow()
	endif
enddef

au vimrc BufAdd,BufEnter * au vimrc SafeState * ++once RefreshBufList()
au vimrc BufDelete,BufWipeout * au vimrc SafeState * ++once OnBufDelete()
au vimrc CursorMoved * EchoBufList()

export def Setup()
	# nop
enddef

