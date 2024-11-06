vim9script
g:buflist_term_sign = get(g:, 'buflist_term_sign', "\uf489")
var k = false
var n = ''
var q = ''
var t = ''
def A()
q = ''
var a = []
const b = execute('ls')->split("\n")
const c = &columns / (!b ? 1 : len(b))
for d in b
const m = d->matchlist('^ *\([0-9]\+\) \([^"]*\)"\(.*\)" [^0-9]\+ [0-9]\+')
if m->empty()
continue
endif
const e = m[1]
var f = m[3]
if m[2][2] =~# '[RF?]'
f = g:buflist_term_sign ..
term_getline(str2nr(e), '.')
->substitute('\s*[%#>$]\s*$', '', '')
endif
f = f->pathshorten()
const l = len(f)
if c < l
f = '<' .. f->strcharpart(l - c)
endif
const h = $'{e}:{f}'
const i = m[2][0] ==# '%'
if i
n = a->join(' ')
q = (!n ? '' : ' ') .. h .. ' '
a = []
else
add(a, h)
endif
endfor
t = a->join(' ')
B()
const v = !!t || !!n
if v !=# k
k = v
const j = v ? 'EchoBufListShow' : 'EchoBufListHide'
if exists($'#User#{j}')
exe 'doautocmd User' j
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
