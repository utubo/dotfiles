vim9script
var k = 0
var o = 0
var q = ''
var r = false
var s = false
var t = []
var lk = []
var ll = 0
var lm = {}
var ln = 0
var lo = false
def A()
var a = []
if r
a += ['']
else
popup_hide(o)
endif
var n = 0
if r && q !=# ''
lk = matchfuzzy(t, q, { text_cb: (i) => i.label })
else
lk = t->copy()
endif
for b in lk
n += 1
a += [$'{n}: {b.label->trim()}']
endfor
ll = min([max([1, ll]), lk->len()])
popup_settext(k, a)
win_execute(k, $"normal! :{ll + (r ? 1 : 0)}\<CR>")
if r
const c = $'Filter:{q}{s ? ' ' : ''}'
const p = popup_getpos(k)
const d = max([p.core_width, strdisplaywidth(c)])
popup_move(k, { minwidth: d })
popup_move(o, {
col: p.core_col,
line: p.core_line,
maxwidth: d,
minwidth: d,
zindex: 2,
})
popup_show(o)
popup_settext(o, c)
endif
redraw
enddef
def B(a: number, b: string): bool
if b ==# "\<CursorHold>"
return false
endif
const c = match("\<C-1>\<C-2>\<C-3>\<C-4>\<C-5>\<C-6>\<C-7>\<C-8>\<C-9>", b)
if c !=# -1
ll = c + 1
D()
endif
if b ==# "\<ESC>" || b ==# "\<C-x>"
Close()
return true
elseif b ==# "\<CR>"
D()
return true
elseif b ==# "\<C-n>"
C(1)
return true
elseif b ==# "\<C-p>"
C(-1)
return true
endif
if s
if b ==# "\<Tab>"
s = false
elseif b ==# "\<BS>"
q = q->substitute('.$', '', '')
else
q ..= b
endif
A()
return true
endif
if b ==# 'f' || b ==# "\<Tab>"
r = !r || b ==# "\<Tab>"
s = r
A()
return true
endif
if match('nbt', b) !=# -1
C(1)
elseif match('pBT', b) !=# -1
C(-1)
elseif match('123456789', b) !=# -1
ll = str2nr(b)
D()
elseif b ==# "x"
Close()
return true
else
Close()
return false
endif
return true
enddef
def C(d: number)
ll += d
if ll < 1
ll = lk->len()
elseif lk->len() < ll
ll = 1
endif
E()
A()
enddef
def D()
if ll < 1
return
endif
E()
F()
Close()
enddef
def E()
if ll < 1
return
endif
if !lm->has_key('onselect')
return
endif
lm.onselect(lk[ll - 1])
enddef
def F()
if !lm->has_key('oncomplete')
return
endif
lm.oncomplete(lk[ll - 1])
enddef
export def Popup(a: list<any>, b: any = {})
if a->len() <= 1
return
endif
ll = 1
q = ''
r = false
s = false
lm = {
zindex: 1,
tabpage: -1,
maxheight: 21,
mapping: false,
filter: (id, key) => B(id, key),
}
lm->extend(b)
k = popup_menu([], lm)
t = a->copy()
for i in range(t->len())
if get(t[i], 'selected', false)
ll = i + 1
endif
endfor
win_execute(k, 'syntax match PMenuKind /^\d\+:/')
win_execute(k, 'syntax match PMenuExtra /\t.*$/')
A()
o = popup_create('', {})
set t_ve=
hi link popselectCursor Cursor
aug popselect
au!
au VimLeavePre * G()
aug END
ln = timer_start(500, vimrc#popselect#BlinkCursor, { repeat: -1 })
win_execute(o, 'syntax match popselectCursor / $/')
enddef
export def Close()
G()
timer_stop(ln)
popup_close(k)
popup_close(o)
k = 0
o = 0
enddef
export def BlinkCursor(a: number)
if k ==# 0 || popup_list()->index(k) ==# -1
Close()
return
endif
lo = !lo
if lo
hi clear popselectCursor
else
hi link popselectCursor Cursor
endif
enddef
def G()
set t_ve&
enddef
export def PopupBufList()
var a = []
var b = []
const c = execute('ls')->split("\n")
for d in c
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
const h = $"{fnamemodify(f, ':t')}\<Tab>{bufname(e)->fnamemodify(':p')}"
const i = m[2][0] ==# '%'
add(a, { label: h, selected: i, tag: e })
endfor
Popup(a, {
title: 'Buffers',
onselect: (item) => {
exe $'buffer {item.tag}'
}
})
enddef
export def PopupMRU()
var a = []
for f in v:oldfiles
if filereadable(expand(f))
const b = $"{fnamemodify(f, ':t')}\<Tab>{f->fnamemodify(':p')}"
add(a, { label: b, tag: f })
endif
endfor
Popup(a, {
title: 'MRU',
oncomplete: (item) => {
exe $'edit {item.tag}'
}
})
enddef
export def PopupTabList()
var a = []
const c = tabpagenr()
for d in range(1, tabpagenr('$'))
var e = ''
var f = tabpagebuflist(d)
const g = tabpagewinnr(d) - 1
f = remove(f, g, g) + f
var h = []
var i = -1
for b in f
i += 1
var j = bufname(b)
if !j
j = '[No Name]'
elseif getbufvar(b, '&buftype') ==# 'terminal'
j = 'terminal ' .. term_getline(b, '.')->trim()
else
j = j->pathshorten()
endif
const l = len(j)
if h->index(j) ==# -1
h += [j]
endif
endfor
e ..= h->join(', ')
add(a, { label: e, tag: d, selected: d ==# c })
endfor
Popup(a, {
title: 'Tab pages',
onselect: (item) => {
exe $'tabnext {item.tag}'
}
})
enddef
