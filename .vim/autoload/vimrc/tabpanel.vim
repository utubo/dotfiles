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
