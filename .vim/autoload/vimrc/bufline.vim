vim9script
g:buflist_term_sign = get(g:, 'buflist_term_sign', "\uf489")
var k = ''
var n = ''
var p = ''
def A()
n = ''
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
k = a->join(' ')
n = (!k ? '' : ' ') .. h .. ' '
a = []
else
add(a, h)
endif
endfor
p = a->join(' ')
enddef
export def MyBufline(): string
A()
const o = getwininfo(win_getid(1))[0].textoff
return $'{repeat(' ', o)}{k}%#TabLineSel#{n}%#TabLine#{p}'
enddef
