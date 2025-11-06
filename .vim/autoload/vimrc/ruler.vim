vim9script
var k = 0
var l = 0
var m = ''
au vimrc CursorMoved,CursorMovedI * au SafeState * ++once :redrawtabp
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
export def MyRuler(): string
if !v:vim_did_enter
return ''
endif
const p = getcurpos(k)
const b = getbufinfo(l)
var a = !b ? '' : $'{p[1]}/{b[0].linecount}:{p[2]}{m}'
if exists('g:vim9skkp_status')
a ..= $' {g:vim9skkp_status.mode}'
else
a ..= ' _A'
endif
return $'%#TabPanelFill#{anypanel#align#Center(a)}'
enddef
