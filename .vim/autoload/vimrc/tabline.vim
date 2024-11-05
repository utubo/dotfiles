vim9script
g:tabline_mod_sign = get(g:, 'tabline_mod_sign', "\uf040")
g:tabline_git_sign = get(g:, 'tabline_git_sign', '🐙')
g:tabline_dir_sign = get(g:, 'tabline_dir_sign', '📂')
g:tabline_term_sign = get(g:, 'tabline_term_sign', "\uf489")
g:tabline_labelsep = get(g:, 'tabline_labelsep', '|')
g:tabline_max_len = get(g:, 'tabline_max_len', 20)
export def MyTablabelSign(a: list<number>, c: bool = false): string
var d = ''
var e = ''
for b in a
const f = getbufvar(b, '&buftype')
if f ==# ''
if !d && getbufvar(b, '&modified')
d = g:tabline_mod_sign
endif
if !e
var g = false
sil! g = len(getbufvar(b, 'gitgutter', {'hunks': []}).hunks) !=# 0
if g
e = g:tabline_git_sign
endif
endif
endif
if c
continue
endif
if f ==# 'terminal'
return g:tabline_term_sign
endif
const h = getbufvar(b, '&filetype')
if h ==# 'netrw' || h ==# 'fern'
return g:tabline_dir_sign
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
var h = bufname(b)
if !h
h = '[No Name]'
elseif getbufvar(b, '&buftype') ==# 'terminal'
h = term_getline(b, '.')->trim()
endif
h = h->pathshorten()
const l = len(h)
if g:tabline_max_len < l
h = '<' .. h->strcharpart(l - g:tabline_max_len)
endif
if f->index(h) ==# -1
f += [MyTablabelSign([b]) .. h]
endif
endfor
c ..= f->join(g:tabline_labelsep)
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
