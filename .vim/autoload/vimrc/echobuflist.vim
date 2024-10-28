vim9script
var k = false
var n = ''
var p = ''
var q = ''
def A()
p = ''
var a = []
for b in execute('ls')->split("\n")
const m = b->matchlist('^ *\([0-9]\+\) \([^"]*\)"\(.*\)" \+line [0-9]\+')
if !m->empty()
const c = m[1]
const d = m[2][2] =~# '[RF?]' ? '[Term]' : m[3]->pathshorten()
const e = m[2][0] ==# '%'
const f = $'{c}:{d}'
if e
n = a->join(' ')
p = (!n ? '' : ' ') .. f .. ' '
a = []
else
add(a, f)
endif
endif
endfor
q = a->join(' ')
B()
k = !!q || !!n
g:zenmode.preventEcho = k
enddef
def B()
if !k
return
endif
if ['ControlP']->index(bufname('%')) !=# -1
return
endif
if mode() ==# 'c'
return
endif
redraw
var w = v:echospace
var o = getwininfo(win_getid(1))[0].textoff
w -= o
const s = p->substitute($'\%{w}v.*', '', '')
w -= strdisplaywidth(s)
var l = n->reverse()->substitute($'\%{w}v.*', '', '')->reverse()
if l !=# n
l = l->substitute('^.', '<', '')
endif
w -= strdisplaywidth(l)
var r = q->substitute($'\%{w}v.*', '', '')
if r !=# q
r = r->substitute('.$', '>', '')
endif
w -= strdisplaywidth(r)
w = max([0, w])
echoh TabLineFill
echon repeat(' ', o)
echoh TabLine
echon l
echoh TabLineSel
echon s
echoh TabLine
echon r
echoh TabLineFill
echon repeat(' ', w)
echoh Normal
enddef
def C()
A()
if !k
zenmode#RedrawNow()
endif
enddef
au vimrc BufAdd,BufEnter * au vimrc SafeState * ++once A()
au vimrc BufDelete,BufWipeout * au vimrc SafeState * ++once C()
au vimrc CursorMoved * B()
export def Setup()
enddef
