vim9script
g:buflist_term_sign = get(g:, 'tabline_term_sign', "\uf489")
g:buflist_max_len = 20
var k = false
var n = ''
var q = ''
var t = ''
def A()
q = ''
var a = []
for b in execute('ls')->split("\n")
const m = b->matchlist('^ *\([0-9]\+\) \([^"]*\)"\(.*\)" [^0-9]\+ [0-9]\+')
if m->empty()
continue
endif
const c = m[1]
var d = m[3]->pathshorten()
if m[2][2] =~# '[RF?]'
d = g:buflist_term_sign .. term_getline(str2nr(c), '.')->trim()->pathshorten()
endif
const l = len(d)
if g:buflist_max_len < l
d = '<' .. d->strcharpart(l - g:buflist_max_len)
endif
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
const h = v ? 'EchoBufListShow' : 'EchoBufListHide'
if exists($'#User#{h}')
exe 'doautocmd User' h
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
