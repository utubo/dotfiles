vim9script

# 複数bufを開いている場合、一覧を画面下部に表示する

var visible = false
var left = ''
var select = ''
var right = ''
def RefreshBufList()
	select = ''
	var bufs = []
	for ls in execute('ls')->split("\n")
		const m = ls->matchlist('^ *\([0-9]\+\) \([^"]*\)"\(.*\)" \+line [0-9]\+')
		if !m->empty()
			const nr = m[1]
			const name = m[2][2] =~# '[RF?]' ? '[Term]' : m[3]->pathshorten()
			const current = m[2][0] ==# '%'
			const label = $'{nr}:{name}'
			if current
				left = bufs->join(' ')
				select = (!left ? '' : ' ') .. label .. ' '
				bufs = []
			else
				add(bufs, label)
			endif
		endif
	endfor
	right = bufs->join(' ')
	EchoBufList()
	visible = !!right || !!left
	g:zenmode.preventEcho = visible
enddef

def EchoBufList()
	if !visible
		return
	endif
	if ['ControlP']->index(bufname('%')) !=# -1
		return
	endif
	if mode() ==# 'c'
		return
	endif
	var w = v:echospace
	# 左オフセット
	var o = getwininfo(win_getid(1))[0].textoff
	w -= o
	# 選択バッファ
	const s = select->substitute($'\%{w}v.*', '', '')
	w -= strdisplaywidth(s)
	# 選択より左側
	var l = left->reverse()->substitute($'\%{w}v.*', '', '')->reverse()
	if l !=# left
		l = l->substitute('^.', '<', '')
	endif
	w -= strdisplaywidth(l)
	# 選択より右側
	var r = right->substitute($'\%{w}v.*', '', '')
	if r !=# right
		r = r->substitute('.$', '>', '')
	endif
	# 右パディング
	w -= strdisplaywidth(r)
	w = max([0, w])
	# 表示
	redraw
	echoh TabLineFill
	echon repeat(' ', o)
	echoh TabLine
	echon l
	echoh TabLineSel
	echon s
	echoh TabLine
	echon r
	echoh TabLineFill
	echon repeat(' ', w)
	echoh Normal
enddef

def OnBufDelete()
	RefreshBufList()
	if !visible
		zenmode#RedrawNow()
	endif
enddef

au vimrc BufAdd,BufEnter * au vimrc SafeState * ++once RefreshBufList()
au vimrc BufDelete,BufWipeout * au vimrc SafeState * ++once OnBufDelete()
au vimrc CursorMoved * EchoBufList()

export def Setup()
	# nop
enddef

