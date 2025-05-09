vim9script
sil! packadd nerdfont.vim
var o = 0
var q = 0
var r = ''
var t = false
var lk = false
var ll = false
var lm = []
var ln = []
var lo = {}
var lp = 0
var lq = false
var lr = []
var lt = []
var mk = {
maxwidth: 60,
maxheight: 9,
colwidth: 18,
tabstop: 2,
icon: {
term: "\uf489",
unknown: "\uea7b",
diropen: "\ue5fe",
dirgit: "\ue5fb",
dirup: "\uf062",
}
}
g:popselect = mk->extend(get(g:, 'popselect', {}))
def A(a: any)
enddef
def B(): number
return win_execute(o, 'echon getcurpos()[1]')->str2nr()
enddef
def C(): any
return ln[B() - 1]
enddef
def D()
var a = []
if t && r !=# ''
ln = matchfuzzy(lm, r, { text_cb: (i) => i.label })
else
ln = lm->copy()
endif
var n = 0
var b = ln->len() < 10 ? '' : ' '
for c in ln
n += 1
if 10 <= n
b = ''
endif
var d = ''
if ll
d = !c.icon ? g:popselect.icon.unknown : c.icon
endif
var e = c.label->trim()
if e->strdisplaywidth() < g:popselect.colwidth
e = (e .. repeat(' ', g:popselect.colwidth))
->matchstr($'.*\%{g:popselect.colwidth}v')
endif
var f = get(c, 'extra', '')->trim()
a += [$'{b}{n} {d}{[e, f]->join("\<Tab>")}']
endfor
popup_settext(o, a)
if t
popup_setoptions(o, {
padding: [!a ? 0 : 1, 1, 0, 1],
cursorline: !!ln,
})
var h = ''
if lk
hi link popselectFilter PMenu
h = ' '
else
hi link popselectFilter PMenuExtra
endif
const j = $'Filter:{r}{h}'
const p = popup_getpos(o)
const ml = max([p.core_width, strdisplaywidth(j)])
popup_move(o, { minwidth: ml })
popup_move(q, {
col: p.core_col,
line: p.core_line - (!a ? 0 : 1),
maxwidth: ml,
minwidth: ml,
zindex: 2,
})
popup_show(q)
popup_settext(q, j)
else
popup_setoptions(o, { padding: [0, 1, 0, 1] })
popup_hide(q)
endif
enddef
def E(a: number, b: string): bool
if b ==# "\<CursorHold>"
return true
endif
if stridx("\<ESC>\<C-x>", b) !=# -1
Close()
return true
elseif b ==# "\<CR>"
I()
return true
elseif stridx("\<C-n>\<C-p>\<C-f>\<C-b>", b) !=# -1
H(b)
return true
endif
if lk
if b ==# "\<Tab>"
lk = false
elseif b ==# "\<BS>"
r = r->substitute('.$', '', '')
elseif match(b, '^\p$') ==# -1
Close()
return true
else
r ..= b
G(1)
endif
D()
return true
endif
if lo->has_key($'onkey_{b}')
BA($'onkey_{b}')
return true
endif
if stridx('qd', b) !=# -1 && lo->has_key('ondelete')
BA('ondelete')
F(C())
return true
endif
if stridx("f\<Tab>", b) !=# -1
t = !t || b ==# "\<Tab>"
lk = t
D()
elseif stridx('njbtpkBTgG', b) !=# -1
H(b)
elseif stridx('0123456789', b) !=# -1
var c = str2nr(b)
const s = popup_getpos(o).firstline
while c < s
c += 10
endwhile
G(c)
I()
else
Close()
endif
return true
enddef
def F(a: any)
lm->remove(
(lm) -> indexof((_, v) => v.label ==# a.label && v.tag ==# a.tag)
)
for i in range(lm->len())
lm[i].index = i + 1
endfor
if lm->len() < 1
Close()
else
D()
J()
endif
enddef
def G(a: number)
win_execute(o, $':{a}')
J()
enddef
def H(a: any)
var k = a
if stridx('\<C-p>pBT', k) !=# -1
k = 'k'
elseif stridx("\<C-n>nbt", k) !=# -1
k = 'j'
endif
var p = B()
if k ==# 'k' && p <= 1
k = 'G'
elseif k ==# 'g' || k ==# 'j' && ln->len() <= p
k = 'gg'
endif
win_execute(o, $'normal! {k}')
J()
enddef
def I()
if ln->len() < 1
return
endif
const a = C()
Close()
lo.oncomplete(a)
enddef
def J()
if ln->len() < 1
return
endif
lo.onselect(C())
enddef
def BA(a: string)
if lo->has_key(a)
funcref(lo[a], [C()])()
endif
enddef
export def Popup(a: list<any>, b: any = {})
if a->len() < 1
return
endif
lo = {
zindex: 1,
tabpage: -1,
maxheight: min([g:popselect.maxheight, &lines - 2]),
maxwidth: min([g:popselect.maxwidth, &columns - 5]),
mapping: false,
filter: (id, key) => E(id, key),
focusfilter: false,
onselect: (d) => A(d),
oncomplete: (d) => A(d),
}
lo->extend(b)
var c = 1
ll = false
lm = a->copy()
for i in range(lm->len())
var d = lm[i]
if type(d) ==# type('')
d = { label: d }
lm[i] = d
endif
if get(d, 'selected', false)
c = i + 1
endif
d.index = i + 1
ll = ll || d->has_key('icon')
endfor
o = popup_menu([], lo)
win_execute(o, $'syntax match PMenuKind /^\s*\d\+ {ll ? '.' : ''}/')
win_execute(o, 'syntax match PMenuExtra /\t.*$/')
win_execute(o, $'setlocal tabstop={g:popselect.tabstop}')
r = ''
t = lo.focusfilter
lk = lo.focusfilter
hi link popselectFilter PMenu
q = popup_create('', { highlight: 'popselectFilter' })
aug popselect
au!
au VimLeavePre * BB()
aug END
set t_ve=
lr = hlget('Cursor')
lt = [lr[0]->copy()->extend({ name: 'popselectCursor' })]
hlset(lt)
hi clear Cursor
win_execute(q, 'syntax match popselectCursor / $/')
lp = timer_start(500, vimrc#popselect#BlinkCursor, { repeat: -1 })
D()
win_gotoid(o)
G(c)
enddef
export def Close()
BB()
timer_stop(lp)
popup_close(o)
popup_close(q)
o = 0
q = 0
aug popselect
au!
aug END
enddef
export def BlinkCursor(a: number)
if o ==# 0 || popup_list()->index(o) ==# -1
Close()
return
endif
lq = !lq
if lq
hi clear popselectCursor
else
hlset(lt)
endif
enddef
def BB()
set t_ve&
hlset(lr)
enddef
def BC(a: string, b: bool = false): string
if b
if a ==# '..'
return g:popselect.icon.dirup
elseif a->fnamemodify(':t') ==# '.git'
return g:popselect.icon.dirgit
else
return g:popselect.icon.diropen
endif
endif
try
const c = nerdfont#find(expand(a))
if c !=# ''
return c
endif
catch
endtry
return g:popselect.icon.unknown
enddef
export def PopupMRU()
var a = []
for f in v:oldfiles
if filereadable(expand(f))
add(a, {
icon: BC(f),
label: fnamemodify(f, ':t'),
extra: f->fnamemodify(':p'),
tag: f
})
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
var h = ''
var i = ''
if m[2][2] =~# '[RF?]'
i = g:popselect.icon.term
f = term_getline(e, '.')
->substitute('\s*[%#>$]\s*$', '', '')
else
h = bufname(e)->fnamemodify(':p')
i = BC(h)
f = fnamemodify(f, ':t')
endif
const j = m[2][0] ==# '%'
add(a, { icon: i, label: f, extra: h, tag: e, selected: j })
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
const h = tabpagewinnr(d) - 1
f = remove(f, h, h) + f
var j = []
var i = -1
for b in f
i += 1
var ml = bufname(b)
if !ml
ml = '[No Name]'
elseif getbufvar(b, '&buftype') ==# 'terminal'
ml = g:popselect.icon.term .. term_getline(b, '.')->trim()
else
ml = ml->pathshorten()
endif
const l = len(ml)
if j->index(ml) ==# -1
j += [ml]
endif
endfor
e ..= j->join(', ')
add(a, { label: e, tag: d, selected: d ==# c })
endfor
Popup(a, {
title: 'Tab pages',
onselect: (item) => execute($'tabnext {item.index}'),
ondelete: (item) => execute($'tabclose! {item.index}'),
})
enddef
export def PopupDir(a: string = '')
var b = []
const c = a ==# '' ? expand('%:p:h') : a
if c->fnamemodify(':h') !=# c
add(b, {
icon: BC('..', true),
label: '..',
tag: c->fnamemodify(':h'),
isdir: true,
})
endif
const d = readdirex(c, '1', { sort: 'collate' })
for f in d
const e = f.type ==# 'dir' || f.type ==# 'linkd'
add(b, {
icon: BC(f.name, e),
label: f.name,
tag: $'{c}/{f.name}',
isdir: e,
})
endfor
Popup(b, {
title: BC(c, true) .. fnamemodify(c, ':t:r'),
oncomplete: (item) => {
if item.isdir
PopupDir(item.tag)
else
exe $'edit {item.tag}'
endif
},
onkey_t: (item) => {
exe $'tabedit {item.tag}'
vimrc#popselect#Close()
}
})
enddef
