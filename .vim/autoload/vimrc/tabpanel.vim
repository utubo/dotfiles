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
export def Calendar(): list<string>
const a = strftime('%Y-%m-%d')
if k.ymd ==# a
return k.lines
endif
const [b, c] = a->split('-')[1 : 2]
var e = ['%#TabPanelFill#']
const f = &tabpanelopt
->matchstr('\(columns:\)\@<=\d\+') ?? '20'
e->add('%#TabPanel#' .. repeat(' ', str2nr(f) / 2 - 1) .. b)
var g = (c->str2nr() - strftime('%w')->str2nr()) % 7
var h = repeat(['  '], g)
for d in range(1, 31)
const i = printf('%02d', d)
if i ==# c
h->add($'%#TabPanelSel#{i}%#TabPanel#')
else
h->add(i)
endif
g = (g + 1) % 7
if !g
e->add('%#TabPanel#' .. h->join(' '))
h = []
endif
endfor
k.ymd = a
k.lines = e
return e
enddef
var l = {}
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
const d = Calendar()
var e = 0
for i in range(1, g:actual_curtabpage - 1)
e += get(l, i, 0)
endfor
const f = &lines - &cmdheight - e - a->len() - d->len()
if 0 <= f
a += repeat(['%#TabPanelFill#'], f)
a += d
endif
else
l[g:actual_curtabpage] = a->len()
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
