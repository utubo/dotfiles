vim9script

# 複数bufを開いている場合、一覧を画面下部に表示する

g:buflist_term_sign = get(g:, 'tabline_term_sign', "\uf489") # `>_`みたいなアイコン
g:buflist_max_len = 20

var visible = false
var left = ''
var select = ''
var right = ''
def RefreshBufList()
	select = ''
	var bufs = []
	for ls in execute('ls')->split("\n")
		const m = ls->matchlist('^ *\([0-9]\+\) \([^"]*\)"\(.*\)" [^0-9]\+ [0-9]\+')
		if m->empty()
			continue
		endif
		const nr = m[1]
		var name = m[3]->pathshorten()
		if m[2][2] =~# '[RF?]'
			name = g:buflist_term_sign .. term_getline(str2nr(nr), '.')->trim()->pathshorten()
		endif
		const l = len(name)
		if g:buflist_max_len < l
			name = '<' .. name->strcharpart(l - g:buflist_max_len)
		endif
		const label = $'{nr}:{name}'
		const current = m[2][0] ==# '%'
		if current
			left = bufs->join(' ')
			select = (!left ? '' : ' ') .. label .. ' '
			bufs = []
		else
			add(bufs, label)
		endif
	endfor
	right = bufs->join(' ')
	EchoBufList()
	const v = !!right || !!left
	if v !=# visible
		visible = v
		const ev = v ? 'EchoBufListShow' : 'EchoBufListHide'
		if exists($'#User#{ev}')
			execute 'doautocmd User' ev
		endif
	endif
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
	const o = getwininfo(win_getid(1))[0].textoff
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
	w -= strdisplaywidth(r)
	# 右パディング
	const p = max([0, w])
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
	echon repeat(' ', p)
	echoh Normal
enddef

au vimrc BufAdd,BufEnter,BufDelete,BufWipeout * au vimrc SafeState * ++once RefreshBufList()
au vimrc CursorMoved * EchoBufList()

export def Setup()
	# nop
enddef

