vim9script
var k = 0
var l = 0
var m = ''
au vimrc WinEnter * {
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
return repeat(' ', 9 - len(a) / 2) .. a
enddef
export def Apply()
set rulerformat=%{g:MyRuler()}
set ru
enddef
