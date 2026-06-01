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
const d = '^\(\s*\)\(- \)\?'
var b = substitute(a, $'{d}\[[^{x}]\]', $'\1- [{x}]', '')
if a ==# b
b = substitute(a, $'{d}\[{x}\]', '\1- [ ]', '')
endif
if a ==# b
b = substitute(a, d, '\1- [ ] ', '')
endif
setline(l, b)
if l ==# line('.')
var c = getpos('.')
c[2] += len(b) - len(a)
setpos('.', c)
endif
endfor
enddef
def! g:ToggleCheckBoxX(a: any)
B('x')
enddef
def! g:ToggleCheckBoxSuspend(a: any)
B('-')
enddef
map <buffer> <LocalLeader>o <ScriptCmd>set opfunc=ToggleCheckBoxX<CR>g@0
map <buffer> <LocalLeader><LocalLeader>o <ScriptCmd>set opfunc=ToggleCheckBoxSuspend<CR>g@0
xn <buffer> <LocalLeader>o <ScriptCmd>B('x')<CR>
ino <buffer> <LocalLeader>o <ScriptCmd>B('x')<CR>
def! g:ToggleListMark(...d: list<any>)
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
nm <buffer> <LocalLeader>- <ScriptCmd>set opfunc=ToggleListMark<CR>g@0
ino <buffer> <LocalLeader>- <ScriptCmd>g:ToggleListMark()<CR>
xn <buffer> <LocalLeader>- <ScriptCmd>g:ToggleListMark()<CR>
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
const N = 99 - 1
var e = ''
if a + N < b
e = '+'
b = a + N
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
const K = 300
var m = 0
var n = 0
def CursorMovedDelayExec(a: any = 0)
m = 0
if n !=# 0
n = 0
D()
endif
enddef
def E()
if m !=# 0
n += 1
return
endif
D()
n = 0
m = timer_start(K, CursorMovedDelayExec)
enddef
au after_ftplugin_md CursorMoved <buffer> E()
def F()
for l in A()
const a = substitute(getline(l), '^\(\s*\)-\( \[[x ]\]\)\? ', '\1' .. repeat(' ', len('\2')), '')
setline(l, a)
endfor
enddef
ino <buffer> <LocalLeader>r <CR><ScriptCmd>F()<CR>
nn <buffer> <LocalLeader>r <ScriptCmd>F()<CR>
xn <buffer> <LocalLeader>r <ScriptCmd>F()<CR>
g:vim_markdown_new_list_item_prefix = 2
set lcs=tab:\|\ ,trail:-,extends:>,precedes:<,nbsp:%
