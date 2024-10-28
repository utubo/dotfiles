vim9script
var k = []
def A()
k = []
for a in execute('ls')->split("\n")
const m = a->matchlist('^ *\([0-9]\+\) \([^"]*\)"\(.*\)" \+line [0-9]\+')
if !m->empty()
var b = {
nr: m[1],
name: m[2][2] =~# '[RF?]' ? '[Term]' : m[3]->pathshorten(),
current: m[2][0] ==# '%',
}
k += [b]
b.width = strdisplaywidth($' {b.nr}{b.name} ')
endif
endfor
B()
g:zenmode.preventEcho = k->len() > 1
enddef
def B()
if k->len() <= 1
return
endif
if ['ControlP']->index(bufname('%')) !=# -1
return
endif
if mode() ==# 'c'
return
endif
redraw
var s = 0
var e = 0
var w = getwininfo(win_getid(1))[0].textoff
var a = false
var c = false
var d = false
for b in k
w += b.width
if &columns - 5 < w
if d
e -= 1
a = true
break
endif
s += 1
c = true
endif
if b.current
d = true
endif
e += 1
endfor
w = getwininfo(win_getid(1))[0].textoff
echoh TablineFill
echon repeat(' ', w)
if c
echoh Tabline
echon '< '
w += 2
endif
for b in k[s : e]
w += b.width
if b.current
echoh TablineSel
else
echoh Tabline
endif
echon $'{b.nr} {b.name} '
endfor
if a
echoh Tabline
echon '>'
w += 1
endif
const f = &columns - 1 - w
if 0 < f
echoh TablineFill
echon repeat(' ', &columns - 1 - w)
endif
echoh Normal
enddef
def C()
A()
if k->len() <= 1
zenmode#RedrawNow()
endif
enddef
au vimrc BufAdd,BufEnter * au vimrc SafeState * ++once A()
au vimrc BufDelete,BufWipeout * au vimrc SafeState * ++once C()
au vimrc CursorMoved * B()
export def Setup()
enddef
