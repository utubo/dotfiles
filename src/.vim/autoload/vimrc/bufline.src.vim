vim9script

# 複数bufを開いている場合、一覧を画面上部に表示する

# `>_`みたいなアイコン
g:buflist_term_sign = get(g:, 'buflist_term_sign', "\uf489")

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

export def MyBufline(): string
	RefreshBufList()
	const o = getwininfo(win_getid(1))[0].textoff
	return $'%#TabLine#{repeat(' ', o)}{left}%#TabLineSel#{select}%#TabLine#{right}'
enddef

