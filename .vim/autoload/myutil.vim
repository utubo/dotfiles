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
export def MoveFile(a: string)
const b = expand('%')
const c = expand(a)
if ! empty(b) && filereadable(b)
if filereadable(c)
echoh Error
ec $'file "{a}" already exists.'
echoh None
return
endif
rename(b, c)
endif
exe 'saveas!' c
edit
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
A(b)
A(a)
setpos('.', c)
enddef
export def FixSandwichPos()
var c = g:operator#sandwich#object.cursor
if g:fix_sandwich_pos[1] !=# c.inner_head[1]
c.inner_head[2] = getline(c.inner_head[1])->match('\S') + 1
c.inner_tail[2] = getline(c.inner_tail[1])->match('$') + 1
endif
enddef
def A(a: number)
sil! exe ':' a 's/\s\+$//'
sil! exe ':' a 's/^\s*\n//'
enddef
export def RemoveAirBuns()
const c = g:operator#sandwich#object.cursor
A(c.tail[1])
A(c.head[1])
enddef
var k = []
export def BigMac(a: bool = true)
const c = a ? [] : g:operator#sandwich#object.cursor.inner_head[1 : 2]
if a || k !=# c
k = c
au vimrc User OperatorSandwichAddPost ++once BigMac(false)
if a
feedkeys('S')
else
setpos("'<", g:operator#sandwich#object.cursor.inner_head)
setpos("'>", g:operator#sandwich#object.cursor.inner_tail)
feedkeys('gvS')
endif
endif
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
