vim9script
export def ApplySettings()
tno <C-w>; <C-w>:
tno <C-w><C-w> <C-w>w
tno <C-w><C-q> exit<CR>
au vimrc BufEnter * B()
enddef
export def Tapi_drop(a: number, b: list<string>)
const c = b[0]
var d = 1
var e = 'split'
if b[1] ==# '-t'
e = 'tabe'
d += 1
endif
var f = b[d]
if !isabsolutepath(f)
f = fnamemodify(c, ':p') .. f
endif
if bufwinnr(bufnr(f)) !=# -1
e = 'drop'
endif
exe e fnameescape(f)
enddef
def A(): bool
const a = tabpagenr()->tabpagebuflist()
if a->len() !=# 1
return false
else
return getbufvar(a[0], '&buftype') ==# 'terminal'
endif
enddef
var k = 0
def B()
const b = A()
if !b
if !!k
popup_close(k)
k = 0
endif
else
if !k
k = popup_create('vim teminal', {
col: &columns,
line: 1,
pos: 'topright',
})
endif
endif
enddef
