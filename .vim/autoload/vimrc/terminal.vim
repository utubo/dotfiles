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
var k = 0
aug vimrc_notify_only_term_window
aug END
def A(): number
const [a, b] = win_getid()->win_screenpos()
const c = winwidth(0)
return b + c - 1
enddef
def B()
const a = tabpagenr()->tabpagebuflist()
if a->len() ==# 1 && a[0]->getbufvar('&buftype') ==# 'terminal'
if !k
k = popup_create(
'vim teminal',
{
line: &lines,
col: A(),
pos: 'topright',
},
)
au vimrc_notify_only_term_window WinResized * {
popup_move(k, { line: &lines, col: A() })
}
endif
else
if !!k
popup_close(k)
k = 0
au! vimrc_notify_only_term_window
endif
endif
enddef
