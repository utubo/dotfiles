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
export def ToggleNumber()
if &number
set nonumber
elseif &relativenumber
set number norelativenumber
else
set relativenumber
endif
enddef
export def Zf()
var [a, b] = g:VFirstLast()
exe ':' a 's/\v(\S)?$/\1 /'
append(b, g:IndentStr(a))
cursor([a, 1])
cursor([b + 1, 1])
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
export def Help(a: string)
var f = globpath(&rtp, $'doc/{a}.txt')
if filereadable(f)
exe 'edit' f
else
echoh ErrorMsg
ec 'Not Found.'
echoh Normal
endif
enddef
