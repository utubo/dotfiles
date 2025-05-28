vim9script
def A(b: dict<any>): string
const a = b.bufnr ==# bufnr('%') ? '>' : ' '
const c = !b.changed ? '' : '+'
const d = b.name->fnamemodify(':t') ?? '[No Name]'
const e = &tabpanelopt
->matchstr('\(columns:\)\@<=\d\+') ?? '20'
return $' {a}{c}{d}'
->substitute($'\%{e}v.*', '>', '')
enddef
export def TabLabel(): string
var a = [$'{g:actual_curtabpage}']
for b in tabpagebuflist(g:actual_curtabpage)
a->add(b->getbufinfo()[0]->A())
endfor
return a->join("\n")
enddef
export def Toggle(n: number = 0)
&showtabpanel = n ?? !&showtabpanel ? 2 : 0
enddef
export def IsVisible(): bool
return &showtabpanel ==# 2 || &showtabpanel ==# 1 && 1 < tabpagenr('$')
enddef
