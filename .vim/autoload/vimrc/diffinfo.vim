vim9script
export def SetDiffLoc()
if !&diff || !exists('w:diffinfo')
return
endif
var a = line('.')
var b = w:diffinfo->indexof((_, v) => v[0] <= a && a <= v[1]) + 1
w:diffloc = $'{!b ? '-' : b}/{len(w:diffinfo)}'
enddef
export def SetDiffInfo()
w:diffinfo = []
var a = 0
var b = ''
var c = 0
var d = 0
for e in range(1, line('$'))
const f = diff_hlID(e, 1)->synIDattr('name')
if f ==# 'DiffAdd'
c += 1
elseif f ==# 'DiffChange'
d += 1
endif
if b ==# f
continue
endif
b = f
if !!a
w:diffinfo->add([a, e - 1])
endif
a = f ==# 'DiffAdd' || f ==# 'DiffChange' ? e : 0
endfor
if !!a
w:diffinfo->add([a, line('$')])
endif
w:difflines = $'Added:{c},Changed:{d}'
enddef
export def EchoDiffInfo(a: number, b: number, c: number)
var d = getwinvar(b, 'diffinfo', 0)
if !d
win_execute(a, 'call vimrc#diffinfo#SetDiffInfo()')
win_execute(a, 'call vimrc#diffinfo#SetDiffLoc()')
endif
const e = getwinvar(b, 'difflines', '')
const f = getwinvar(b, 'diffloc', '')
if win_getid() ==# a
echoh StatusLine
else
echoh StatusLineNC
endif
echon $' {e} {f} {repeat(' ', c)}'[0 : c - 1]
enddef
aug vimrc_diffinfo
au!
au WinEnter,TextChanged,InsertLeave,BufWritePost * silent! unlet w:diffinfo
au CursorMoved * SetDiffLoc()
aug END
