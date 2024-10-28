vim9script
var k = false
var n = ''
var q = ''
var t = ''
def A()
q = ''
var a = []
for b in execute('ls')->split("\n")
const m = b->matchlist('^ *\([0-9]\+\) \([^"]*\)"\(.*\)" \+line [0-9]\+')
if m->empty()
continue
endif
const c = m[1]
const d = m[2][2] =~# '[RF?]' ? '[Term]' : m[3]->pathshorten()
const e = $'{c}:{d}'
const f = m[2][0] ==# '%'
if f
n = a->join(' ')
q = (!n ? '' : ' ') .. e .. ' '
a = []
else
add(a, e)
endif
endfor
t = a->join(' ')
B()
const v = !!t || !!n
if v !=# k
k = v
const g = v ? 'EchoBufListShow' : 'EchoBufListHide'
if exists($'#User#{g}')
exe 'doautocmd User' g
endif
endif
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
var w = v:echospace
const o = getwininfo(win_getid(1))[0].textoff
w -= o
const s = q->substitute($'\%{w}v.*', '', '')
w -= strdisplaywidth(s)
var l = n->reverse()->substitute($'\%{w}v.*', '', '')->reverse()
if l !=# n
l = l->substitute('^.', '<', '')
endif
w -= strdisplaywidth(l)
var r = t->substitute($'\%{w}v.*', '', '')
if r !=# t
r = r->substitute('.$', '>', '')
endif
w -= strdisplaywidth(r)
const p = max([0, w])
redraw
echoh TabLineFill
echon repeat(' ', o)
echoh TabLine
echon l
echoh TabLineSel
echon s
echoh TabLine
echon r
echoh TabLineFill
echon repeat(' ', p)
echoh Normal
enddef
au vimrc BufAdd,BufEnter,BufDelete,BufWipeout * au vimrc SafeState * ++once A()
au vimrc CursorMoved * B()
export def Setup()
enddef
