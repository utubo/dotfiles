vim9script

var winid = 0
var filterwinid = 0
var filter = ''
var filter_visible = false
var filter_focused = false
var items = []
var filtered = []
var currow = 0
var opts = {}
var blinktimer = 0
var blink = false

def Update()
	var text = []
	if filter_visible
		text += ['']
	else
		popup_hide(filterwinid)
	endif
	var n = 0
	if filter_visible && filter !=# ''
		filtered = matchfuzzy(items, filter, { text_cb: (i) => i.label })
	else
		filtered = items->copy()
	endif
	for item in filtered
		n += 1
		text += [$'{n}: {item.label->trim()}']
	endfor
	currow = min([max([1, currow]), filtered->len()])
	popup_settext(winid, text)
	win_execute(winid, $"normal! :{currow + (filter_visible ? 1 : 0)}\<CR>")
	if filter_visible
		const filtertext = $'Filter:{filter}{filter_focused ? ' ' : ''}'
		const p = popup_getpos(winid)
		const width = max([p.core_width, strdisplaywidth(filtertext)])
		popup_move(winid, { minwidth: width })
		popup_move(filterwinid, {
		   col: p.core_col,
		   line: p.core_line,
		   maxwidth: width,
		   minwidth: width,
			zindex: 2,
		})
		popup_show(filterwinid)
		popup_settext(filterwinid, filtertext)
	endif
	redraw
enddef

def Filter(id: number, key: string): bool
	if key ==# "\<CursorHold>"
		return false
	endif
	const ctrlN = match("\<C-1>\<C-2>\<C-3>\<C-4>\<C-5>\<C-6>\<C-7>\<C-8>\<C-9>", key)
	if ctrlN !=# -1
		currow = ctrlN + 1
		Complete()
	endif
	if key ==# "\<ESC>" || key ==# "\<C-x>"
		Close()
		return true
	elseif key ==# "\<CR>"
		Complete()
		return true
	elseif key ==# "\<C-n>"
		Move(1)
		return true
	elseif key ==# "\<C-p>"
		Move(-1)
		return true
	endif
	if filter_focused
		if key ==# "\<Tab>"
			filter_focused = false
		elseif key ==# "\<BS>"
			filter = filter->substitute('.$', '', '')
		else
			filter ..= key
		endif
		Update()
		return true
	endif
	if key ==# 'f' || key ==# "\<Tab>"
		filter_visible = !filter_visible || key ==# "\<Tab>"
		filter_focused = filter_visible
		Update()
		return true
	endif
	if match('nbt', key) !=# -1
		Move(1)
	elseif match('pBT', key) !=# -1
		Move(-1)
	elseif match('123456789', key) !=# -1
		currow = str2nr(key)
		Complete()
	elseif key ==# "x"
		Close()
		return true
	else
		Close()
		return false
	endif
	return true
enddef

def Move(d: number)
	currow += d
	if currow < 1
		currow = filtered->len()
	elseif filtered->len() < currow
		currow = 1
	endif
	OnSelect()
	Update()
enddef

def Complete()
	if currow < 1
		return
	endif
	OnSelect()
	OnComplete()
	Close()
enddef

def OnSelect()
	if currow < 1
		return
	endif
	if !opts->has_key('onselect')
		return
	endif
	opts.onselect(filtered[currow - 1])
enddef

def OnComplete()
	if !opts->has_key('oncomplete')
		return
	endif
	opts.oncomplete(filtered[currow - 1])
enddef

export def Popup(what: list<any>, options: any = {})
	if what->len() <= 1
		return
	endif
	currow = 1
	filter = ''
	filter_visible = false
	filter_focused = false
	opts = {
		zindex: 1,
		tabpage: -1,
		maxheight: &lines - 2,
		maxwidth: &columns - 5,
		mapping: false,
		filter: (id, key) => Filter(id, key),
	}
	opts->extend(options)
	winid = popup_menu([], opts)
	items = what->copy()
	for i in range(items->len())
		if get(items[i], 'selected', false)
			currow = i + 1
		endif
	endfor
	win_execute(winid, 'syntax match PMenuKind /^\d\+:/')
	win_execute(winid, 'syntax match PMenuExtra /\t.*$/')
	Update()
	# Filter input box
	filterwinid = popup_create('', {})
	set t_ve=
	hi link popselectCursor Cursor
	augroup popselect
		au!
		au VimLeavePre * RestoreCursor()
	augroup END
	blinktimer = timer_start(500, vimrc#popselect#BlinkCursor, { repeat: -1 })
	win_execute(filterwinid, 'syntax match popselectCursor / $/')
enddef

export def Close()
	RestoreCursor()
	timer_stop(blinktimer)
	popup_close(winid)
	popup_close(filterwinid)
	winid = 0
	filterwinid = 0
	augroup popselect
		au!
	augroup END
enddef

export def BlinkCursor(timer: number)
	if winid ==# 0 || popup_list()->index(winid) ==# -1
		# ここに来るのはポップアップが意図せず残留したとき
		# または<C-c>などで強引にポップアップを閉じられたとき
		Close()
		return
	endif
	blink = !blink
	if blink
		hi clear popselectCursor
	else
		hi link popselectCursor Cursor
	endif
enddef

def RestoreCursor()
	set t_ve&
enddef

export def PopupBufList()
	var bufs = []
	var labels = []
	const ls_result = execute('ls')->split("\n")
	for ls in ls_result
		const m = ls->matchlist('^ *\([0-9]\+\) \([^"]*\)"\(.*\)" [^0-9]\+ [0-9]\+')
		if m->empty()
			continue
		endif
		const nr = m[1]
		var name = m[3]
		if m[2][2] =~# '[RF?]'
			name = g:buflist_term_sign ..
				term_getline(str2nr(nr), '.')
					->substitute('\s*[%#>$]\s*$', '', '')
		endif
		const label = $"{fnamemodify(name, ':t')}\<Tab>{bufname(nr)->fnamemodify(':p')}"
		const current = m[2][0] ==# '%'
		add(bufs, { label: label, selected: current, tag: nr })
	endfor
	Popup(bufs, {
		title: 'Buffers',
		onselect: (item) => {
			execute $'buffer {item.tag}'
		}
	})
enddef

export def PopupMRU()
	var items = []
	for f in v:oldfiles
		if filereadable(expand(f))
			const label = $"{fnamemodify(f, ':t')}\<Tab>{f->fnamemodify(':p')}"
			add(items, { label: label, tag: f })
		endif
	endfor
	Popup(items, {
		title: 'MRU',
		oncomplete: (item) => {
			execute $'edit {item.tag}'
		}
	})
enddef

export def PopupTabList()
	var items = []
	const current = tabpagenr()
	for tab in range(1, tabpagenr('$'))
		var label = ''
		var bufs = tabpagebuflist(tab)
		const win = tabpagewinnr(tab) - 1
		bufs = remove(bufs, win, win) + bufs
		var names = []
		var i = -1
		for b in bufs
			i += 1
			var name = bufname(b)
			if !name
				name = '[No Name]'
			elseif getbufvar(b, '&buftype') ==# 'terminal'
				name = 'terminal ' .. term_getline(b, '.')->trim()
			else
				name = name->pathshorten()
			endif
			const l = len(name)
			if names->index(name) ==# -1
				names += [name]
			endif
		endfor
		label ..= names->join(', ')
		add(items, { label: label, tag: tab, selected: tab ==# current })
	endfor
	Popup(items, {
		title: 'Tab pages',
		onselect: (item) => {
			execute $'tabnext {item.tag}'
		}
	})
enddef
