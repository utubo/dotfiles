vim9script

silent! packadd nerdfont.vim

var winid = 0
var filter_winid = 0
var filter_text = ''
var filter_visible = false
var filter_focused = false
var has_icon = false
var src = []
var items = []
var opts = {}
var blink_timer = 0
var blink = false
var hl_cursor = []
var hl_popselect_cursor = []

var defaultSettings = {
	maxwidth: 60,
	maxheight: 9,
	colwidth: 18,
	tabstop: 2,
	icon_term: "\uf489",
	icon_unknown: "\uea7b",
	icon_diropen: "\ue5fe",
	icon_dirgit: "\ue5fb",
	icon_dirup: "\uf062",
}
g:popselect = defaultSettings->extend(get(g:, 'popselect', {}))

def Nop(item: any)
	# nop
enddef

def GetPos(): number
	return win_execute(winid, 'echon getcurpos()[1]')->str2nr()
enddef

def Item(): any
	return items[GetPos() - 1]
enddef

def Update()
	var text = []
	if filter_visible && filter_text !=# ''
		items = matchfuzzy(src, filter_text, { text_cb: (i) => i.label })
	else
		items = src->copy()
	endif
	var n = 0
	var offset = items->len() < 10 ? '' : ' '
	for item in items
		n += 1
		if 10 <= n
			offset = ''
		endif
		var icon = ''
		if has_icon
			icon = !item.icon ? g:popselect.icon_unknown : item.icon
		endif
		var label = item.label->trim()
		if label->strdisplaywidth() < g:popselect.colwidth
			label = (label .. repeat(' ', g:popselect.colwidth))
				->matchstr($'.*\%{g:popselect.colwidth}v')
		endif
		var extra = get(item, 'extra', '')->trim()
		text += [$'{offset}{n} {icon}{[label, extra]->join("\<Tab>")}']
	endfor
	popup_settext(winid, text)
	if filter_visible
		popup_setoptions(winid, {
			padding: [!text ? 0 : 1, 1, 0, 1],
			cursorline: !!items,
		})
		var cursor = ''
		if filter_focused
			hi link popselectFilter PMenu
			cursor = ' '
		else
			hi link popselectFilter PMenuExtra
		endif
		const filtertext = $'Filter:{filter_text}{cursor}'
		const p = popup_getpos(winid)
		const width = max([p.core_width, strdisplaywidth(filtertext)])
		popup_move(winid, { minwidth: width })
		popup_move(filter_winid, {
		   col: p.core_col,
		   line: p.core_line - (!text ? 0 : 1),
		   maxwidth: width,
		   minwidth: width,
			zindex: 2,
		})
		popup_show(filter_winid)
		popup_settext(filter_winid, filtertext)
	else
		popup_setoptions(winid, { padding: [0, 1, 0, 1] })
		popup_hide(filter_winid)
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
	elseif stridx("\<C-n>\<C-p>\<C-f>\<C-b>", key) !=# -1
		Move(key)
		return true
	endif
	if filter_focused
		if key ==# "\<Tab>"
			filter_focused = false
		elseif key ==# "\<BS>"
			filter_text = filter_text->substitute('.$', '', '')
		elseif match(key, '^\p$') ==# -1
			Close()
			return true
		else
			filter_text ..= key
			Select(1)
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
		Delete(Item())
		return true
	endif
	if stridx("f\<Tab>", key) !=# -1
		filter_visible = !filter_visible || key ==# "\<Tab>"
		filter_focused = filter_visible
		Update()
	elseif stridx('njbtpkBTgG', key) !=# -1
		Move(key)
	elseif stridx('0123456789', key) !=# -1
		var target = str2nr(key)
		const s = popup_getpos(winid).firstline
		while target < s
			target += 10
		endwhile
		Select(target)
		Complete()
	else
		Close()
	endif
	return true
enddef

def Delete(item: any)
	src->remove(
		(src) -> indexof((_, v) => v.label ==# item.label && v.tag ==# item.tag)
	)
	for i in range(src->len())
		src[i].index = i + 1
	endfor
	if src->len() < 1
		Close()
	else
		Update()
		OnSelect()
	endif
enddef

def Select(line: number)
	win_execute(winid, $':{line}')
	OnSelect()
enddef

def Move(key: any)
	var k = key
	if stridx('\<C-p>pBT', k) !=# -1
		k = 'k'
	elseif stridx("\<C-n>nbt", k) !=# -1
		k = 'j'
	endif
	var p = GetPos()
	if k ==# 'k' && p <= 1
		k = 'G'
	elseif k ==# 'g' || k ==# 'j' && items->len() <= p
		k = 'gg'
	endif
	win_execute(winid, $'normal! {k}')
	OnSelect()
enddef

def Complete()
	if items->len() < 1
		return
	endif
	const item = Item()
	Close()
	opts.oncomplete(item)
enddef

def OnSelect()
	if items->len() < 1
		return
	endif
	opts.onselect(Item())
enddef

def Execute(name: string)
	if opts->has_key(name)
		funcref(opts[name], [Item()])()
	endif
enddef

export def Popup(what: list<any>, options: any = {})
	if what->len() < 1
		return
	endif
	opts = {
		zindex: 1,
		tabpage: -1,
		maxheight: min([g:popselect.maxheight, &lines - 2]),
		maxwidth: min([g:popselect.maxwidth, &columns - 5]),
		mapping: false,
		filter: (id, key) => Filter(id, key),
		focusfilter: false,
		onselect: (item) => Nop(item),
		oncomplete: (item) => Nop(item),
	}
	opts->extend(options)
	# List box
	var selectedIndex = 1
	has_icon = false
	src = what->copy()
	for i in range(src->len())
		var item = src[i]
		if type(item) ==# type('')
			item = { label: item }
			src[i] = item
		endif
		if get(item, 'selected', false)
			selectedIndex = i + 1
		endif
		item.index = i + 1
		has_icon = has_icon || item->has_key('icon')
	endfor
	winid = popup_menu([], opts)
	win_execute(winid, $'syntax match PMenuKind /^\s*\d\+ {has_icon ? '.' : ''}/')
	win_execute(winid, 'syntax match PMenuExtra /\t.*$/')
	win_execute(winid, $'setlocal tabstop={g:popselect.tabstop}')
	# Filter input box
	filter_text = ''
	filter_visible = opts.focusfilter
	filter_focused = opts.focusfilter
	hi link popselectFilter PMenu
	filter_winid = popup_create('', { highlight: 'popselectFilter' })
	augroup popselect
		au!
		au VimLeavePre * RestoreCursor()
	augroup END
	set t_ve=
	hl_cursor = hlget('Cursor')
	hl_popselect_cursor = [hl_cursor[0]->copy()->extend({ name: 'popselectCursor' })]
	hlset(hl_popselect_cursor)
	hi clear Cursor
	win_execute(filter_winid, 'syntax match popselectCursor / $/')
	blink_timer = timer_start(500, vimrc#popselect#BlinkCursor, { repeat: -1 })
	# Show
	Update()
	win_gotoid(winid)
	Select(selectedIndex)
enddef

export def Close()
	RestoreCursor()
	timer_stop(blink_timer)
	popup_close(winid)
	popup_close(filter_winid)
	winid = 0
	filter_winid = 0
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
		hlset(hl_popselect_cursor)
	endif
enddef

def RestoreCursor()
	set t_ve&
	hlset(hl_cursor)
enddef

def NerdFont(path: string, isDir: bool = false): string
	if isDir
		if path ==# '..'
			return g:popselect.icon_dirup
		elseif path->fnamemodify(':t') ==# '.git'
			return g:popselect.icon_dirgit
		else
			return g:popselect.icon_diropen
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
	return g:popselect.icon_unknown
enddef

export def PopupMRU()
	var items = []
	for f in v:oldfiles
		if filereadable(expand(f))
			add(items, {
				icon: NerdFont(f),
				label: fnamemodify(f, ':t'),
				extra: f->fnamemodify(':p'),
				tag: f
			})
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
		var path = ''
		var icon = ''
		if m[2][2] =~# '[RF?]'
			icon = g:popselect.icon_term
			name = term_getline(nr, '.')
				->substitute('\s*[%#>$]\s*$', '', '')
		else
			path = bufname(nr)->fnamemodify(':p')
			icon = NerdFont(path)
			name = fnamemodify(name, ':t')
		endif
		const current = m[2][0] ==# '%'
		add(bufs, { icon: icon, label: name, extra: path, tag: nr, selected: current })
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
				name = g:popselect.icon_term .. term_getline(b, '.')->trim()
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
