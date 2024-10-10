vim9script
const k = "\uf040"
const l = '🐙'
const m = '📂'
const n = "\uf489"
const o = '|'
const p = 20
export def MyTablabelSign(a: list<number>, c: bool = false): string
var d = ''
var e = ''
for b in a
const f = getbufvar(b, '&buftype')
if f ==# ''
if !d && getbufvar(b, '&modified')
d = k
endif
if !e
var g = false
sil! g = len(getbufvar(b, 'gitgutter', {'hunks': []}).hunks) !=# 0
if g
e = l
endif
endif
endif
if c
continue
endif
if f ==# 'terminal'
return n
endif
const h = getbufvar(b, '&filetype')
if h ==# 'netrw' || h ==# 'fern'
return m
endif
endfor
return d .. e
enddef
export def MyTablabel(a: number = 0): string
var c = ''
var d = tabpagebuflist(a)
const e = tabpagewinnr(a) - 1
d = remove(d, e, e) + d
var f = []
var i = -1
for b in d
i += 1
if len(f) ==# 2
f += [(MyTablabelSign(d[i : ], true) .. '>')]
break
endif
var g = bufname(b)
if !g
g = '[No Name]'
elseif getbufvar(b, '&buftype') ==# 'terminal'
g = term_getline(b, '.')->trim()
endif
g = g->pathshorten()
if p < len(g)
g = '<' .. g->matchstr(repeat('.', p - 1) .. '$')
endif
if f->index(g) ==# -1
f += [MyTablabelSign([b]) .. g]
endif
endfor
c ..= f->join(o)
return c
enddef
export def MyTabline(): string
var a = '%#TabLineFill#'
a ..= repeat(' ', getwininfo(win_getid(1))[0].textoff)
const b = tabpagenr()
for c in range(1, tabpagenr('$'))
a ..= c ==# b ? '%#TabLineSel#' : '%#TabLine#'
a ..= ' '
a ..= MyTablabel(c)
a ..= ' '
endfor
a ..= '%#TabLineFill#%T'
return a
enddef
