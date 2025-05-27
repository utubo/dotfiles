vim9script
def A(b: dict<any>): string
const a = b.bufnr ==# bufnr('%') ? '>' : ' '
const c = !b.changed ? '' : '+'
const d = !b.hidden ? '' : $'{b.bufnr}:'
const e = b.name->fnamemodify(':t') ?? '[No Name]'
const f = &tabpanelopt
->matchstr('\(columns:\)\@<=\d\+') ?? '20'
return $' {a}{c}{d}{e}'
->substitute($'\%{f}v.*', '>', '')
enddef
var k = {
ymd: '', lines: []
}
export def GetCalendar(): list<string>
const a = strftime('%Y-%m-%d')
if k.ymd ==# a
return k.lines
endif
const [b, c, e] = a->split('-')
const y = b->str2nr()
const m = c->str2nr()
const d = e->str2nr()
var f = ['%#TabPanelFill#']
const g = &tabpanelopt
->matchstr('\(columns:\)\@<=\d\+') ?? '20'
f->add('%#TabPanel#' .. repeat(' ', g->str2nr() / 2 - 1) .. c)
var h = (d - strftime('%w')->str2nr()) % 7
var j = repeat(['  '], h)
var l = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
if y % 4 ==# 0 && y % 100 !=# 0 || y % 400 ==# 0
l[2] = 29
endif
for i in range(1, l[m])
const o = printf('%02d', i)
j->add(o ==# e ? $'%#TabPanelSel#{o}%#TabPanel#' : o)
h = (h + 1) % 7
if !h
f->add('%#TabPanel#' .. j->join(' '))
j = []
endif
endfor
k.ymd = a
k.lines = f
return f
enddef
var p = {}
export def TabPanel(): string
var a = [$'{g:actual_curtabpage}']
for b in tabpagebuflist(g:actual_curtabpage)
a->add(b->getbufinfo()[0]->A())
endfor
if g:actual_curtabpage ==# tabpagenr('$')
const c = getbufinfo({ buflisted: 1 })
->filter((_, v) => v.hidden)
if !!c
a->add('%#TabPanel#Hidden')
for h in c
a->add($'%#TabPanel#{h->A()}')
endfor
endif
endif
if g:actual_curtabpage ==# tabpagenr('$')
const d = GetCalendar()
var e = &lines
for i in range(1, g:actual_curtabpage - 1)
e -= get(p, i, 0)
endfor
e -= a->len()
e -= d->len()
e -= &cmdheight
if 0 <= e
a += repeat(['%#TabPanelFill#'], e)
a += d
endif
else
p[g:actual_curtabpage] = a->len()
endif
return a->join("\n")
enddef
set tabpanel=%!vimrc#tabpanel#TabPanel()
aug show_hiddens_in_tabpanel
au!
au BufDelete * autocmd SafeState * ++once redrawtabp
aug END
export def Toggle(n: number = 0)
&showtabpanel = n ?? !&showtabpanel ? 2 : 0
enddef
export def IsVisible(): bool
return &showtabpanel ==# 2 || &showtabpanel ==# 1 && 1 < tabpagenr('$')
enddef
