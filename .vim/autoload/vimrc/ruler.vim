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
g:vim9skkp_status = get(g:, 'vim9skkp_status', { mode_label: '_A' })
export def MyRuler(): string
if !v:vim_did_enter
return ''
endif
const b = getbufinfo(l)
if !b
return ''
endif
const p = getcurpos(k)
const a = $'{p[1]}/{b[0].linecount}:{p[2]}{m} {g:vim9skkp_status.mode_label}'
return $'%#TabPanelFill#{anypanel#align#Center(a)}'
enddef
