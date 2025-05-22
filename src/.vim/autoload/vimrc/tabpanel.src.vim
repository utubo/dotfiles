vim9script

def BufLabel(b: dict<any>): string
	const current = b.bufnr ==# bufnr('%') ? '>' : ' '
	const mod = !b.changed ? '' : '+'
	const nr = !b.hidden ? '' : $'{b.bufnr}:'
	const name = b.name->fnamemodify(':t') ?? '[No Name]'
	return $' {current}{mod}{nr}{name}'
enddef

def! g:TabPanel(): string
	var label = [$'{g:actual_curtabpage}']
	for b in tabpagebuflist(g:actual_curtabpage)
		label->add(BufLabel(b->getbufinfo()[0]))
	endfor

	# Show Hiddens
	if g:actual_curtabpage ==# tabpagenr('$')
		const hiddens = getbufinfo({ buflisted: 1 })
			->filter((i, v) => v.hidden)
		if !!hiddens
			label->add('%#TabPanel#Hidden')
			for h in hiddens
				label->add($'%#TabPanel#{BufLabel(h)}')
			endfor
		endif
	endif

	return label->join("\n")
enddef

set tabpanel=%!g:TabPanel()

export def Toggle()
	&showtabpanel = !&showtabpanel ? 2 : 0
enddef

export def IsVisible(): bool
	return &showtabpanel ==# 2 || &showtabpanel ==# 1 && 1 < tabpagenr('$')
enddef

