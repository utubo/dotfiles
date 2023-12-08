vim9script
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
