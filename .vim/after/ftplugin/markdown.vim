vim9script noclear
if exists("b:did_my_after_ftplugin")
finish
endif
b:did_my_after_ftplugin = 1
aug after_ftplugin_md
au!
aug END
def A()
for l in g:VRange()
const a = getline(l)
var b = substitute(a, '^\(\s*\)- \[ \]', '\1- [x]', '')
if a ==# b
b = substitute(a, '^\(\s*\)- \[x\]', '\1- [ ]', '')
endif
if a ==# b
b = substitute(a, '^\(\s*\)\(- \)*', '\1- [ ] ', '')
endif
setline(l, b)
if l ==# line('.')
var c = getpos('.')
c[2] += len(b) - len(a)
setpos('.', c)
endif
endfor
enddef
no <buffer> ;o <ScriptCmd>A()<CR>
ino <buffer> ;o <ScriptCmd>A()<CR>
def B()
for l in g:VRange()
const a = getline(l)
var b = substitute(a, '^\(\s*\)-\( \[[x ]\]\)\? ', '\1', '')
if a ==# b
b = substitute(a, '^\(\s*\)', '\1- ', '')
endif
setline(l, b)
if l ==# line('.')
var c = getpos('.')
c[2] += len(b) - len(a)
setpos('.', c)
endif
endfor
enddef
nn <buffer> <Space>- <ScriptCmd>B()<CR>
ino <buffer> ;- <ScriptCmd>B()<CR>
def C(): string
var [a, b] = [line('.'), line('v')]->sort('n')
if mode() ==? 'V'
elseif &ft !=# 'markdown'
return ''
else
const c = indent(a)
for l in range(a + 1, line('$'))
if indent(l) <= c
break
endif
b = l
endfor
endif
const d = 99 - 1
var e = ''
if a + d < b
e = '+'
b = a + d
endif
var f = 0
var g = 0
for l in range(a, b)
const i = getline(l)
if i->match('^\s*- \[x\]') !=# -1
f += 1
elseif i->match('^\s*- \[ \]') !=# -1
g += 1
endif
endfor
if f ==# 0 && g ==# 0
return ''
else
var h = g ==# 0 ? 'ChkCountIconOk' : 'ChkCountIcon'
return $'%#{h}#✅%*{f}/{f + g}{e}'
endif
enddef
def D()
if mode()[0] !=# 'n'
return
endif
const a = C()
if a !=# get(w:, 'ruler_mdcb', '')
w:ruler_mdcb = a
sil! cmdheight0#Invalidate()
endif
enddef
const k = 300
var n = 0
var p = 0
def CursorMovedDelayExec(a: any = 0)
n = 0
if p !=# 0
p = 0
D()
endif
enddef
def F()
if n !=# 0
p += 1
return
endif
D()
p = 0
n = timer_start(k, CursorMovedDelayExec)
enddef
au after_ftplugin_md CursorMoved <buffer> F()
def G()
for l in g:VRange()
const a = substitute(getline(l), '^\(\s*\)-\( \[[x ]\]\)\? ', '\1' .. repeat(' ', len('\2')), '')
setline(l, a)
endfor
enddef
ino <buffer> ;m <CR><ScriptCmd>G()<CR>
nn <buffer> ;m <ScriptCmd>G()<CR>
vn <buffer> ;m <ScriptCmd>G()<CR>
