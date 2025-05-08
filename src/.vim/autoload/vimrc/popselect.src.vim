vim9script

silent! packadd nerdfont.vim

var winid = 0
var filterWinId = 0
var filter = ''
var filterVisible = false
var filterFocused = false
var hasIcon = false
var items = []
var filtered = []
var cursorRow = 0
var opts = {}
var blinkTimer = 0
var blink = false
const ICON_TERM = "\uf489"
const ICON_UNKNOWN = "\uea7b"
const ICON_DIR = "\ue5fe"
const ICON_GIT = "\ue5fb"
const ICON_DIRUP = "\uf062"
const ICON_NO_NERDFONT = "💠"

def Nop(item: any)
	# nop
enddef

def Update()
	var text = []
	if filterVisible
		text += [''] # for filter input box
	else
		popup_hide(filterWinId)
	endif
	if filterVisible && filter !=# ''
		filtered = matchfuzzy(items, filter, { text_cb: (i) => i.label })
	else
		filtered = items->copy()
	endif
	var n = 0
	var offset = filtered->len() < 10 ? '' : ' '
	for item in filtered
		n += 1
		if 10 <= n
			offset = ''
		endif
		var icon = ''
		if hasIcon
			icon = !item.icon ? ICON_UNKNOWN : item.icon
		endif
		text += [$'{offset}{n}:{icon}{item.label->trim()}']
	endfor
	cursorRow = min([max([1, cursorRow]), filtered->len()])
	popup_settext(winid, text)
	win_execute(winid, $"normal! :{cursorRow + (filterVisible ? 1 : 0)}\<CR>")
	if filterVisible
		var cursor = ''
		if filterFocused
			hi link popselectFilter PMenu
			cursor = ' '
		else
			hi link popselectFilter PMenuExtra
		endif
		const filtertext = $'Filter:{filter}{cursor}'
		const p = popup_getpos(winid)
		const width = max([p.core_width, strdisplaywidth(filtertext)])
		popup_move(winid, { minwidth: width })
		popup_move(filterWinId, {
		   col: p.core_col,
		   line: p.core_line,
		   maxwidth: width,
		   minwidth: width,
			zindex: 2,
		})
		popup_show(filterWinId)
		popup_settext(filterWinId, filtertext)
	endif
enddef

def Filter(id: number, key: string): bool
	if key ==# "\<CursorHold>"
		return true
	endif
	if stridx("\<ESC>\<C-x>", key) !=# -1
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
	if filterFocused
		if key ==# "\<Tab>"
			filterFocused = false
		elseif key ==# "\<BS>"
			filter = filter->substitute('.$', '', '')
		elseif match(key, '^\p$') ==# -1
			Close()
			return true
		else
			filter ..= key
			cursorRow = 1
		endif
		Update()
		return true
	endif
	if opts->has_key($'onkey_{key}')
		Execute($'onkey_{key}')
		return true
	endif
	if stridx('qd', key) !=# -1 && opts->has_key('ondelete')
		Execute('ondelete')
		Delete(filtered[cursorRow - 1])
		return true
	endif
	if stridx("f\<Tab>", key) !=# -1
		filterVisible = !filterVisible || key ==# "\<Tab>"
		filterFocused = filterVisible
		Update()
	elseif stridx('njbt', key) !=# -1
		Move(1)
	elseif stridx('pkBT', key) !=# -1
		Move(-1)
	elseif stridx('0123456789', key) !=# -1
		cursorRow = str2nr(key)
		const s = popup_getpos(winid).firstline
		while cursorRow < s
			cursorRow += 10
		endwhile
		Complete()
	else
		Close()
	endif
	return true
enddef

def Delete(item: any)
	items->remove(
		(items) -> indexof((_, v) => v.label ==# item.label && v.tag ==# item.tag)
	)
	for i in range(items->len())
		items[i].index = i + 1
	endfor
	if items->len() < 1
		Close()
	else
		Update()
		OnSelect()
	endif
enddef

def Move(d: number)
	cursorRow += d
	if cursorRow < 1
		cursorRow = filtered->len()
	elseif filtered->len() < cursorRow
		cursorRow = 1
	endif
	OnSelect()
	Update()
enddef

def Complete()
	if cursorRow < 1
		return
	endif
	OnSelect()
	Close()
	OnComplete()
enddef

def OnSelect()
	if cursorRow < 1
		return
	endif
	opts.onselect(filtered[cursorRow - 1])
enddef

def OnComplete()
	opts.oncomplete(filtered[cursorRow - 1])
enddef

def Execute(name: string)
	if opts->has_key(name)
		funcref(opts[name], [filtered[cursorRow - 1]])()
	endif
enddef

export def Popup(what: list<any>, options: any = {})
	if what->len() < 1
		return
	endif
	opts = {
		zindex: 1,
		tabpage: -1,
		maxheight: min([9, &lines - 2]),
		maxwidth: min([60, &columns - 5]),
		mapping: false,
		filter: (id, key) => Filter(id, key),
		focusfilter: false,
		onselect: (item) => Nop(item),
		oncomplete: (item) => Nop(item),
	}
	opts->extend(options)
	# List box
	cursorRow = 1
	hasIcon = false
	items = what->copy()
	for i in range(items->len())
		var item = items[i]
		if type(item) ==# type('')
			item = { label: item }
			items[i] = item
		endif
		if get(item, 'selected', false)
			cursorRow = i + 1
		endif
		item.index = i + 1
		hasIcon = hasIcon || item->has_key('icon')
	endfor
	winid = popup_menu([], opts)
	win_execute(winid, $'syntax match PMenuKind /^\s*\d\+:{hasIcon ? '.' : ''}/')
	win_execute(winid, 'syntax match PMenuExtra /\t.*$/')
	# Filter input box
	filter = ''
	filterVisible = opts.focusfilter
	filterFocused = opts.focusfilter
	hi link popselectFilter PMenu
	hi link popselectCursor Cursor
	filterWinId = popup_create('', { highlight: 'popselectFilter' })
	win_execute(filterWinId, 'syntax match popselectCursor / $/')
	augroup popselect
		au!
		au VimLeavePre * RestoreCursor()
	augroup END
	set t_ve=
	blinkTimer = timer_start(500, vimrc#popselect#BlinkCursor, { repeat: -1 })
	Update()
enddef

export def Close()
	RestoreCursor()
	timer_stop(blinkTimer)
	popup_close(winid)
	popup_close(filterWinId)
	winid = 0
	filterWinId = 0
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

def NerdFont(path: string, isDir: bool = false): string
	if isDir
		if path ==# '..'
			return ICON_DIRUP
		elseif path->fnamemodify(':t') ==# '.git'
			return ICON_GIT
		else
			return ICON_DIR
		endif
	endif
	try
		const icon = nerdfont#find(expand(path))
		if icon !=# ''
			return icon
		endif
	catch
		# nop
	endtry
	return ICON_NO_NERDFONT
enddef

export def PopupMRU()
	var items = []
	for f in v:oldfiles
		if filereadable(expand(f))
			const label = $"{fnamemodify(f, ':t')}\<Tab>{f->fnamemodify(':p')}"
			add(items, { icon: NerdFont(f), label: label, tag: f })
		endif
	endfor
	Popup(items, {
		title: 'MRU',
		oncomplete: (item) => {
			execute $'edit {item.tag}'
		},
		onkey_t: (item) => {
			execute $'tabedit {item.tag}'
			vimrc#popselect#Close()
		}
	})
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
		const nr = str2nr(m[1])
		var name = m[3]
		var icon = ''
		if m[2][2] =~# '[RF?]'
			icon = ICON_TERM
			name = term_getline(nr, '.')
				->substitute('\s*[%#>$]\s*$', '', '')
		else
			const path = bufname(nr)->fnamemodify(':p')
			icon = NerdFont(path)
			name = $"{fnamemodify(name, ':t')}\<Tab>{path}"
		endif
		const current = m[2][0] ==# '%'
		add(bufs, { icon: icon, label: name, tag: nr, selected: current })
	endfor
	Popup(bufs, {
		title: 'Buffers',
		onselect: (item) => execute($'buffer {item.tag}'),
		ondelete: (item) => execute($'bdelete! {item.tag}'),
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
				name = ICON_TERM .. term_getline(b, '.')->trim()
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
		onselect: (item) => execute($'tabnext {item.index}'),
		ondelete: (item) => execute($'tabclose! {item.index}'),
	})
enddef

export def PopupDir(path: string = '')
	var items = []
	const fullpath = path ==# '' ? expand('%:p:h') : path
	if fullpath->fnamemodify(':h') !=# fullpath
		add(items, {
			icon: NerdFont('..', true),
			label: '..',
			tag: fullpath->fnamemodify(':h'),
			isdir: true,
		})
	endif
	const files = readdirex(fullpath, '1', { sort: 'collate' })
	for f in files
		const isdir = f.type ==# 'dir' || f.type ==# 'linkd'
		add(items, {
			icon: NerdFont(f.name, isdir),
			label: f.name,
			tag: $'{fullpath}/{f.name}',
			isdir: isdir,
		})
	endfor
	Popup(items, {
		title: NerdFont(fullpath, true) .. fnamemodify(fullpath, ':t:r'),
		oncomplete: (item) => {
			if item.isdir
				PopupDir(item.tag)
			else
				execute $'edit {item.tag}'
			endif
		},
		onkey_t: (item) => {
			execute $'tabedit {item.tag}'
			vimrc#popselect#Close()
		}
	})
enddef
