vim9script
var k = 0
var l = 0
var m = ''
au vimrc WinEnter,BufEnter * {
k = winnr()
l = winbufnr(k)
m = ''
const n = getbufvar(l, '&ff')
if n ==# 'mac'
m = ' CR'
elseif n ==# 'unix'
if has('win32')
m = ' LF'
endif
elseif !has('win32')
m = ' CRLF'
endif
const o = getbufvar(l, '&fenc')
if o !=# 'utf-8'
m ..= $' {o}'
endif
}
def! g:MyRuler(): string
const p = getcurpos(k)
const b = getbufinfo(l)
var a = !b ? '' : $'{p[1]}/{b[0].linecount}:{p[2]}{m}'
if exists('g:vim9skkp_status')
a ..= $' {g:vim9skkp_status.mode}'
endif
return repeat(' ', 9 - len(a) / 2) .. a
enddef
export def Apply()
set rulerformat=%#MsgArea#%{g:MyRuler()}
enddef
