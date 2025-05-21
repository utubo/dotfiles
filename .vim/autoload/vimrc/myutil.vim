vim9script
export def VimGrep(a: string, ...b: list<string>)
var c = join(b, ' ')
if empty(c)
c = expand('%:e') ==# '' ? '*' : ($'*.{expand('%:e')}')
endif
const d = (&modified || !empty(bufname())) && c !=# '%'
if d
tabnew
endif
exe $'silent! lvimgrep {a} {c}'
if ! empty(getloclist(0))
lwindow
else
echoh ErrorMsg
echom $'Not found.: {a}'
echoh None
if d
tabn -
tabc +
endif
endif
enddef
export def Zf()
const a = getregionpos(getpos('v'), getpos('.'))
const b = a[0][0][1]
const c = a[-1][-1][1]
exe $':{b}s/\v(\S)?$/\1 /'
const d = getline(b)->matchstr('^\s*')
append(c, d)
cursor([b, 1])
cursor([c + 1, 1])
normal! zf
enddef
export def Zd()
if foldclosed(line('.')) ==# -1
normal! zc
endif
const a = foldclosed(line('.'))
const b = foldclosedend(line('.'))
if a ==# -1
return
endif
const c = getpos('.')
normal! zd
RemoveEmptyLine(b)
RemoveEmptyLine(a)
setpos('.', c)
enddef
export def Brep(a: string, b: string)
var c = []
for l in getline(1, '$')
if l =~# a
c += [l]
endif
endfor
if empty(c)
echoh ErrorMsg
ec 'Pattern not found: ' .. a
echoh Normal
return
endif
exe $'{b} new'
append(0, c)
setl nomodified
enddef
export def HelpPlugins(b: string)
const c = globpath(&rtp, $'**/{b}/doc/*.txt')
g:a = c
if c !=# ''
exe 'edit' c
endif
const d = globpath(&rtp, $'**/{b}/README.md')
if d !=# ''
exe 'edit' d
endif
enddef
export def ShowBufInfo(a: string = '')
if &ft ==# 'qf'
return
endif
var b = a ==# 'BufReadPost'
if b && !filereadable(expand('%'))
return
endif
const c = $' {line(".")}:{col(".")}'
var e = []
add(e, ['Title', $'"{bufname()}"'])
add(e, ['Normal', ' '])
if &modified
add(e, ['Delimiter', '[+]'])
add(e, ['Normal', ' '])
endif
if !b && !filereadable(expand('%'))
add(e, ['Tag', '[New]'])
add(e, ['Normal', ' '])
endif
if &readonly
add(e, ['WarningMsg', '[RO]'])
add(e, ['Normal', ' '])
endif
const w = wordcount()
if b || w.bytes !=# 0
add(e, ['Constant', printf('%dL, %dB', w.bytes ==# 0 ? 0 : line('$'), w.bytes)])
add(e, ['Normal', ' '])
endif
add(e, [&ff ==# 'unix' ? 'MoreMsg' : 'WarningMsg', &ff])
add(e, ['Normal', ' '])
const f = &fenc ?? &enc
add(e, [f ==# 'utf-8' ? 'MoreMsg' : 'WarningMsg', f])
add(e, ['Normal', ' '])
add(e, ['MoreMsg', &ft])
add(e, ['Normal', ' '])
const h = g:System('git branch')->trim()->matchstr('\w\+$')
add(e, ['WarningMsg', h])
var j = 0
const k = &columns - len(c) - 2
for i in reverse(range(0, len(e) - 1))
var s = e[i][1]
var d = strdisplaywidth(s)
j += d
if k < j
const l = k - j + d
while !empty(s) && l < strdisplaywidth(s)
s = s[1 :]
endwhile
e[i][1] = s
e = e[i : ]
insert(e, ['SpecialKey', '<'], 0)
break
endif
endfor
add(e, ['Normal', repeat(' ', k - j) .. c])
redraw
ec ''
for m in e
exe 'echohl' m[0]
echon m[1]
endfor
echoh Normal
popup_create(expand('%:p'), { line: &lines - 1, col: 1, minheight: 1, maxheight: 1, minwidth: &columns, pos: 'botleft', moved: 'any' })
enddef
export def PopupCursorPos()
const p = getcurpos()
const a = synID(line('.'), col('.'), 1)->synIDattr('name')->substitute('^$', 'Normal', '')
popup_create([$'{p[1]}:{p[2]}', a], {
pos: 'botleft',
line: 'cursor-1',
col: 'cursor+1',
moved: 'any',
padding: [1, 1, 1, 1],
})
enddef
export def PopupVisualLength()
var a = getregion(getpos('v'), getpos('.'))->join('')
popup_create($'{strlen(a)}chars', {
pos: 'botleft',
line: 'cursor-1',
col: 'cursor+1',
fixed: true,
moved: 'any',
padding: [1, 1, 1, 1],
})
enddef
