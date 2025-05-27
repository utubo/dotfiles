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
	ymd: '', lines: [], opt: ''
}

export def GetCalendar(): list<string>
	const ymd = strftime('%Y-%m-%d')
	if calendar_cache.ymd ==# ymd &&
			calendar_cache.opt ==# &tabpanelopt
		return calendar_cache.lines
	endif
	const [year, month, day] = ymd->split('-')
	const y = year->str2nr()
	const m = month->str2nr()
	const d = day->str2nr()
	var lines = []
	# Month
	# Note: Calender width = 20
	lines->add($'         {month}')
	# Days
	var last_day = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	if y % 4 ==# 0 && y % 100 !=# 0 || y % 400 ==# 0
		last_day[2] = 29
	endif
	var wday = (d - strftime('%w')->str2nr()) % 7
	var days = repeat(['  '], wday)
	for i in range(1, last_day[m])
		const dd = printf('%02d', i)
		days->add(dd ==# day ? $'%#TabPanelSel#{dd}%#TabPanel#' : dd)
		wday = (wday + 1) % 7
		if !wday
			lines->add(days->join(' '))
			days = []
		endif
	endfor
	# Centering
	const width = &tabpanelopt
		->matchstr('\(columns:\)\@<=\d\+') ?? '20'
	const pad_width = width->str2nr() / 2 - 10
	const pad = repeat(' ', pad_width)
	for i in range(0, lines->len() - 1)
		lines[i] = $'%#TabPanel#{pad}{lines[i]}'
	endfor
	lines = ['%#TabPanelFill#'] + lines
	calendar_cache.ymd = ymd
	calendar_cache.opt = &tabpanelopt
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
		const cal = GetCalendar()
		var pad = &lines
		for i in range(1, g:actual_curtabpage - 1)
			pad -= get(label_height, i, 0)
		endfor
		pad -= label->len()
		pad -= cal->len()
		pad -= &cmdheight
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

