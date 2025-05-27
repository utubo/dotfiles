vim9script

def BufLabel(b: dict<any>): string
	const current = b.bufnr ==# bufnr('%') ? '>' : ' '
	const mod = !b.changed ? '' : '+'
	const nr = !b.hidden ? '' : $'{b.bufnr}:'
	const name = b.name->fnamemodify(':t') ?? '[No Name]'
	const width = &tabpanelopt
		->matchstr('\(columns:\)\@<=\d\+') ?? '20'
	return $' {current}{mod}{nr}{name}'
		->substitute($'\%{width}v.*', '>', '')
enddef

var calendar_cache = {
	ymd: '', lines: []
}

export def Calendar(): list<string>
	const ymd = strftime('%Y-%m-%d')
	if calendar_cache.ymd ==# ymd
		return calendar_cache.lines
	endif
	var lines = ['%#TabPanelFill#']
	const width = &tabpanelopt
		->matchstr('\(columns:\)\@<=\d\+') ?? '20'
	lines->add('%#TabPanel#' .. repeat(' ', str2nr(width) / 2 - 1) .. ymd[5 : 6])
	var wday = (str2nr(ymd[8 : 9]) - strftime('%w')->str2nr()) % 7
	var days = repeat(['  '], wday)
	for d in range(1, 31)
		const day = printf('%02d', d)
		if day ==# ymd[8 : 9]
			days->add($'%#TabPanelSel#{day}%#TabPanel#')
		else
			days->add(day)
		endif
		wday = (wday + 1) % 7
		if !wday
			lines->add('%#TabPanel#' .. days->join(' '))
			days = []
		endif
	endfor
	calendar_cache.ymd = ymd
	calendar_cache.lines = lines
	return lines
enddef

var label_height = {}

export def TabPanel(): string
	var label = [$'{g:actual_curtabpage}']
	for b in tabpagebuflist(g:actual_curtabpage)
		label->add(b->getbufinfo()[0]->BufLabel())
	endfor

	# Show Hiddens
	if g:actual_curtabpage ==# tabpagenr('$')
		const hiddens = getbufinfo({ buflisted: 1 })
			->filter((_, v) => v.hidden)
		if !!hiddens
			label->add('%#TabPanel#Hidden')
			for h in hiddens
				label->add($'%#TabPanel#{h->BufLabel()}')
			endfor
		endif
	endif

	# Show Calendar
	if g:actual_curtabpage ==# tabpagenr('$')
		const cal = Calendar()
		var before_height = 0
		for i in range(1, g:actual_curtabpage - 1)
			before_height += get(label_height, i, 0)
		endfor
		const pad = &lines - &cmdheight - before_height - label->len() - cal->len()
		if 0 <= pad
			label += repeat(['%#TabPanelFill#'], pad)
			label += cal
		endif
	else
		label_height[g:actual_curtabpage] = label->len()
	endif

	return label->join("\n")
enddef

set tabpanel=%!vimrc#tabpanel#TabPanel()

augroup show_hiddens_in_tabpanel
	autocmd!
	# BufDeleteのタイミングではまだバッファが削除されていない
	# <abuf>に情報はあるが面倒なのでSafeStateを使っちゃう
	autocmd BufDelete * autocmd SafeState * ++once redrawtabp
augroup END

export def Toggle(n: number = 0)
	&showtabpanel = n ?? !&showtabpanel ? 2 : 0
enddef

export def IsVisible(): bool
	return &showtabpanel ==# 2 || &showtabpanel ==# 1 && 1 < tabpagenr('$')
enddef

