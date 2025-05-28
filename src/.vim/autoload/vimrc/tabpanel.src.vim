vim9script

def BufLabel(b: dict<any>): string
	const current = b.bufnr ==# bufnr('%') ? '>' : ' '
	const mod = !b.changed ? '' : '+'
	const name = b.name->fnamemodify(':t') ?? '[No Name]'
	const width = &tabpanelopt
		->matchstr('\(columns:\)\@<=\d\+') ?? '20'
	return $' {current}{mod}{name}'
		->substitute($'\%{width}v.*', '>', '')
enddef

export def TabLabel(): string
	var label = [$'{g:actual_curtabpage}']
	for b in tabpagebuflist(g:actual_curtabpage)
		label->add(b->getbufinfo()[0]->BufLabel())
	endfor
	return label->join("\n")
enddef

export def Toggle(n: number = 0)
	&showtabpanel = n ?? !&showtabpanel ? 2 : 0
enddef

export def IsVisible(): bool
	return &showtabpanel ==# 2 || &showtabpanel ==# 1 && 1 < tabpagenr('$')
enddef
