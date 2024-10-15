vim9script
export def ApplySettings(a: string)
exe $'nunmap {a}'
exe $'xunmap {a}'
g:sandwich = get(g:, 'sandwich', {})
g:sandwich#recipes = deepcopy(get(g:sandwich, 'default_receipes', []))
g:sandwich#recipes += [
{ buns: ["\r", '' ], input: ["\r"], command: ["normal! a\r"] },
{ buns: ['', '' ], input: ['q'] },
{ buns: ['「', '」'], input: ['k'] },
{ buns: ['【', '】'], input: ['K'] },
{ buns: ['{ ', ' }'], input: ['{'] },
{ buns: ['${', '}' ], input: ['${'] },
{ buns: ['%{', '}' ], input: ['%{'] },
{ buns: ['CommentString(0)', 'CommentString(1)'], expr: 1, input: ['c'] },
]
nm Sd <Plug>(operator-sandwich-delete)ab
xm Sd <Plug>(operator-sandwich-delete)
nm Sr <Plug>(operator-sandwich-replace)ab
xm Sr <Plug>(operator-sandwich-replace)
nn S <Plug>(operator-sandwich-add)iw
xn S <Plug>(operator-sandwich-add)
nm <expr> Srr (matchstr(getline('.'), '[''"]', col('.')) ==# '"') ? "Sr'" : 'Sr"'
nm S$ vg_S
au vimrc User OperatorSandwichAddPre g:fix_sandwich_pos = getpos('.')
au vimrc User OperatorSandwichAddPost vimrc#sandwich#FixSandwichPos()
au vimrc User OperatorSandwichDeletePost vimrc#sandwich#RemoveAirBuns()
xn Sm <ScriptCmd>vimrc#sandwich#BigMac()<CR>
nm Sm viwSm
feedkeys(a, 'it')
enddef
def! g:CommentString(a: number): string
return &commentstring->split('%s')->get(a, '')
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
popup_create('🍔', {
col: 'cursor',
line: 'cursor+1',
moved: 'any',
})
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
