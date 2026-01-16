vim9script

export def SetDiffLoc()
	if !&diff || !exists('w:diffinfo')
		return
	endif
	var ln = line('.')
	var idx = w:diffinfo->indexof((_, v) => v[0] <= ln && ln <= v[1]) + 1
	w:diffloc = $'{!idx ? '-' : idx}/{len(w:diffinfo)}'
enddef

export def SetDiffInfo()
	w:diffinfo = []
	var start = 0
	var name_bk = ''
	var added = 0
	var changed = 0
	for lnum in range(1, line('$'))
		const name = diff_hlID(lnum, 1)->synIDattr('name')
		if name ==# 'DiffAdd'
			added += 1
		elseif name ==# 'DiffChange'
			changed += 1
		endif
		if name_bk ==# name
			continue
		endif
		name_bk = name
		if !!start
			w:diffinfo->add([start, lnum - 1])
		endif
		start = name ==# 'DiffAdd' || name ==# 'DiffChange' ? lnum : 0
	endfor
	if !!start
		w:diffinfo->add([start, line('$')])
	endif
	w:difflines = $'Added:{added},Changed:{changed}'
enddef

export def EchoDiffInfo(winid: number, winnr: number, width: number)
	var diffinfo = getwinvar(winnr, 'diffinfo', 0)
	if !diffinfo
		win_execute(winid, 'call vimrc#diffinfo#SetDiffInfo()')
		win_execute(winid, 'call vimrc#diffinfo#SetDiffLoc()')
	endif
	const difflines = getwinvar(winnr, 'difflines', '')
	const diffloc = getwinvar(winnr, 'diffloc', '')
	if win_getid() ==# winid
		echoh StatusLine
	else
		echoh StatusLineNC
	endif
	echon $' {difflines} {diffloc} {repeat(' ', width)}'[0 : width - 1]
enddef

augroup vimrc_diffinfo
	au!
	au WinEnter,TextChanged,InsertLeave,BufWritePost * silent! unlet w:diffinfo
	au CursorMoved * SetDiffLoc()
augroup END

