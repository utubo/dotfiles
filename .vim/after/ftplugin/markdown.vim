vim9script noclear
if exists("b:did_my_after_ftplugin")
finish
endif
b:did_my_after_ftplugin = 1
aug after_ftplugin_md
au!
aug END
def A(): list<number>
return getregionpos(getpos('v'), getpos('.'))->map((_, v) => v[0][1])
enddef
def B(x: string)
for l in A()
const a = getline(l)
var b = substitute(a, '^\(\s*\)- \[ \]', $'\1- [{x}]', '')
if a ==# b
b = substitute(a, '^\(\s*\)- \[[-x*]\]', '\1- [ ]', '')
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
no <buffer> <LocalLeader>o <ScriptCmd>B('x')<CR>
ino <buffer> <LocalLeader>o <ScriptCmd>B('x')<CR>
no <buffer> <LocalLeader>- <ScriptCmd>B('-')<CR>
def C()
for l in A()
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
nn <buffer> <Space>- <ScriptCmd>C()<CR>
ino <buffer> <LocalLeader>- <ScriptCmd>C()<CR>
xn <buffer> <Space>- <ScriptCmd>C()<CR>
def D(): string
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
def E()
if mode()[0] !=# 'n'
return
endif
const a = D()
if a !=# get(w:, 'ruler_mdcb', '')
w:ruler_mdcb = a
sil! cmdheight0#Invalidate()
endif
enddef
const k = 300
var m = 0
var n = 0
def CursorMovedDelayExec(a: any = 0)
m = 0
if n !=# 0
n = 0
E()
endif
enddef
def G()
if m !=# 0
n += 1
return
endif
E()
n = 0
m = timer_start(k, CursorMovedDelayExec)
enddef
au after_ftplugin_md CursorMoved <buffer> G()
def H()
for l in A()
const a = substitute(getline(l), '^\(\s*\)-\( \[[x ]\]\)\? ', '\1' .. repeat(' ', len('\2')), '')
setline(l, a)
endfor
enddef
ino <buffer> <LocalLeader>r <CR><ScriptCmd>H()<CR>
nn <buffer> <LocalLeader>r <ScriptCmd>H()<CR>
xn <buffer> <LocalLeader>r <ScriptCmd>H()<CR>
g:vim_markdown_new_list_item_indent = 2
