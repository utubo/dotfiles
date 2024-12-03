vim9script

# 複数bufを開いている場合、一覧を画面上部に表示する

# `>_`みたいなアイコン
g:buflist_term_sign = get(g:, 'buflist_term_sign', "\uf489")

var pum = 0
var left = ''
var select = ''
var right = ''
def RefreshBufList()
	select = ''
	var bufs = []
	const ls_result = execute('ls')->split("\n")
	const max_len = &columns / (!ls_result ? 1 : len(ls_result))
	for ls in ls_result
		const m = ls->matchlist('^ *\([0-9]\+\) \([^"]*\)"\(.*\)" [^0-9]\+ [0-9]\+')
		if m->empty()
			continue
		endif
		const nr = m[1]
		var name = m[3]
		if m[2][2] =~# '[RF?]'
			name = g:buflist_term_sign ..
				term_getline(str2nr(nr), '.')
					->substitute('\s*[%#>$]\s*$', '', '')
		endif
		name = name->pathshorten()
		const l = len(name)
		if max_len < l
			name = '<' .. name->strcharpart(l - max_len)
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
enddef

export def Popup()
	if !left && !right
		return
	endif
	var w = &columns
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
	#redraw
	var newpum = popup_create($'{l}{s}{r}', {
		line: 1,
		col: 1,
		fixed: true,
		highlight: 'TabLine',
		padding: [0, p, 0, o],
		moved: 'any',
	})
	#echoh TabLineFill
	#echon repeat(' ', o)
	#echoh TabLine
	#echon l
	#echoh TabLineSel
	#echon s
	#echoh TabLine
	#echon r
	#echoh TabLineFill
	#echon repeat(' ', p)
	#echoh Normal
	if !!pum
		popup_close(pum)
	endif
	pum = newpum
enddef

export def Show()
	RefreshBufList()
	Popup()
enddef

export def Setup()
	# nop
enddef

