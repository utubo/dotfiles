vim9script
var k = 0
var o = 0
var q = ''
var r = false
var s = false
var t = false
var lk = []
var ll = []
var lm = 0
var ln = {}
var lo = 0
var lp = false
const lq = "\uf489"
const lr = "\uea7b"
const lt = "💠"
def A(a: any)
enddef
def B()
var a = []
if r
a += ['']
else
popup_hide(o)
endif
if r && q !=# ''
ll = matchfuzzy(lk, q, { text_cb: (i) => i.label })
else
ll = lk->copy()
endif
var n = 0
var b = ll->len() < 10 ? '' : ' '
for c in ll
n += 1
if 10 <= n
b = ''
endif
var d = ''
if t
d = !c.icon ? lr : c.icon
endif
a += [$'{b}{n}:{d}{c.label->trim()}']
endfor
lm = min([max([1, lm]), ll->len()])
popup_settext(k, a)
win_execute(k, $"normal! :{lm + (r ? 1 : 0)}\<CR>")
if r
var e = ''
if s
hi link popselectFilter PMenu
e = ' '
else
hi link popselectFilter PMenuExtra
endif
const f = $'Filter:{q}{e}'
const p = popup_getpos(k)
const g = max([p.core_width, strdisplaywidth(f)])
popup_move(k, { minwidth: g })
popup_move(o, {
col: p.core_col,
line: p.core_line,
maxwidth: g,
minwidth: g,
zindex: 2,
})
popup_show(o)
popup_settext(o, f)
endif
redraw
enddef
def C(a: number, b: string): bool
if b ==# "\<CursorHold>"
return false
endif
if stridx("\<ESC>\<C-x>", b) !=# -1
Close()
return true
elseif b ==# "\<CR>"
F()
return true
elseif b ==# "\<C-n>"
E(1)
return true
elseif b ==# "\<C-p>"
E(-1)
return true
endif
if s
if b ==# "\<Tab>"
s = false
elseif b ==# "\<BS>"
q = q->substitute('.$', '', '')
else
q ..= b
lm = 1
endif
B()
return true
endif
if ln->has_key($'onkey_{b}')
I($'onkey_{b}')
return true
endif
if stridx('qd', b) !=# -1 && ln->has_key('ondelete')
I('ondelete')
D(ll[lm - 1])
return true
endif
if stridx("f\<Tab>", b) !=# -1
r = !r || b ==# "\<Tab>"
s = r
B()
elseif stridx('njbt', b) !=# -1
E(1)
elseif stridx('pkBT', b) !=# -1
E(-1)
elseif stridx('123456789', b) !=# -1
lm = str2nr(b)
F()
elseif b ==# "x"
Close()
else
Close()
return false
endif
return true
enddef
def D(a: any)
lk->remove(
(lk) -> indexof((_, v) => v.label ==# a.label && v.tag ==# a.tag)
)
if lk->len() < 1
Close()
else
B()
G()
endif
enddef
def E(d: number)
lm += d
if lm < 1
lm = ll->len()
elseif ll->len() < lm
lm = 1
endif
G()
B()
enddef
def F()
if lm < 1
return
endif
G()
H()
Close()
enddef
def G()
if lm < 1
return
endif
ln.onselect(ll[lm - 1])
enddef
def H()
ln.oncomplete(ll[lm - 1])
enddef
def I(a: string)
if ln->has_key(a)
funcref(ln[a], [ll[lm - 1]])()
endif
enddef
export def Popup(a: list<any>, b: any = {})
if a->len() <= 1
return
endif
lm = 1
q = ''
r = false
s = false
t = false
ln = {
zindex: 1,
tabpage: -1,
maxheight: &lines - 2,
maxwidth: &columns - 5,
mapping: false,
filter: (id, key) => C(id, key),
onselect: (item) => A(item),
oncomplete: (item) => A(item),
}
ln->extend(b)
k = popup_menu([], ln)
lk = a->copy()
for i in range(lk->len())
if get(lk[i], 'selected', false)
lm = i + 1
endif
t = t || lk[i]->has_key('icon')
endfor
win_execute(k, $'syntax match PMenuKind /^\s*\d\+:{t ? '.' : ''}/')
win_execute(k, 'syntax match PMenuExtra /\t.*$/')
B()
hi link popselectFilter PMenu
hi link popselectCursor Cursor
o = popup_create('', { highlight: 'popselectFilter' })
win_execute(o, 'syntax match popselectCursor / $/')
aug popselect
au!
au VimLeavePre * J()
aug END
set t_ve=
lo = timer_start(500, vimrc#popselect#BlinkCursor, { repeat: -1 })
enddef
export def Close()
J()
timer_stop(lo)
popup_close(k)
popup_close(o)
k = 0
o = 0
aug popselect
au!
aug END
enddef
export def BlinkCursor(a: number)
if k ==# 0 || popup_list()->index(k) ==# -1
Close()
return
endif
lp = !lp
if lp
hi clear popselectCursor
else
hi link popselectCursor Cursor
endif
enddef
def J()
set t_ve&
enddef
def BA(a: string): string
try
packadd nerdfont.vim
return nerdfont#find(expand(a))
catch
endtry
return lt
enddef
export def PopupMRU()
var a = []
for f in v:oldfiles
if filereadable(expand(f))
const b = $"{fnamemodify(f, ':t')}\<Tab>{f->fnamemodify(':p')}"
add(a, { icon: BA(f), label: b, tag: f })
endif
endfor
Popup(a, {
title: 'MRU',
oncomplete: (item) => {
exe $'edit {item.tag}'
},
onkey_t: (item) => {
exe $'tabedit {item.tag}'
vimrc#popselect#Close()
}
})
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
const e = str2nr(m[1])
var f = m[3]
var g = ''
if m[2][2] =~# '[RF?]'
g = lq
f = term_getline(e, '.')
->substitute('\s*[%#>$]\s*$', '', '')
else
const h = bufname(e)->fnamemodify(':p')
g = BA(h)
f = $"{fnamemodify(f, ':t')}\<Tab>{h}"
endif
const i = m[2][0] ==# '%'
add(a, { icon: g, label: f, tag: e, selected: i })
endfor
Popup(a, {
title: 'Buffers',
onselect: (item) => execute($'buffer {item.tag}'),
ondelete: (item) => execute($'bdelete! {item.tag}'),
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
j = lq .. term_getline(b, '.')->trim()
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
onselect: (item) => execute($'tabnext {item.tag}'),
ondelete: (item) => execute($'tabclose! {item.tag}'),
})
enddef
