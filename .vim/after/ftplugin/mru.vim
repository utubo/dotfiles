vim9script noclear
if exists("b:did_my_after_ftplugin")
finish
endif
b:did_my_after_ftplugin = 1
def A(): bool
return &modified || ! empty(bufname())
enddef
g:MRU_Filename_Format = {
formatter: 'fnamemodify(v:val, ":t") . " > " . v:val',
parser: '> \zs.*',
syntax: '^.\{-}\ze >'
}
def B(a: bool)
b:use_tab = a
setl number
redraw
echoh Question
ec $'[1]..[9] => open with a {a ? 'tab' : 'window'}.'
echoh None
const c = a ? 't' : '<CR>'
for i in range(1, 9)
exe $'nmap <buffer> <silent> {i} :<C-u>{i}<CR>{c}'
endfor
enddef
Enable b:auto_cursorline_disabled
setl cursorline
nn <buffer> w <ScriptCmd>B(!b:use_tab)<CR>
nn <buffer> R <Cmd>MruRefresh<CR><Cmd>MRU<CR><Cmd>setlocal number<CR>
nn <buffer> <Esc> <Cmd>q!<CR>
B(A())
hi link MruFileName Directory
au vimrc ColorScheme <buffer> hi link MruFileName Directory
