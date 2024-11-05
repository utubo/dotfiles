vim9script

# 例: `current.txt|✏sub.txt|🐙>`(3つめ以降は省略)
const tabline_mod_sign = "\uf040" # 鉛筆アイコン(Cicaの絵文字だと半角幅になってしまう)
const tabline_git_sign = '🐙'
const tabline_dir_sign = '📂'
const tabline_term_sign = "\uf489" # `>_`みたいなアイコン
const tabline_labelsep = '|'
const tabline_right_text = '...................$'

export def MyTablabelSign(bufs: list<number>, overflow: bool = false): string
	var mod = ''
	var git = ''
	for b in bufs
		const bt = getbufvar(b, '&buftype')
		if bt ==# ''
			if !mod && getbufvar(b, '&modified')
				mod = tabline_mod_sign
			endif
			if !git
				var g = false
				silent! g = len(getbufvar(b, 'gitgutter', {'hunks': []}).hunks) !=# 0
				if g
					git = tabline_git_sign
				endif
			endif
		endif
		if overflow
			continue
		endif
		if bt ==# 'terminal'
			return tabline_term_sign
		endif
		const ft = getbufvar(b, '&filetype')
		if ft ==# 'netrw' || ft ==# 'fern'
			return tabline_dir_sign
		endif
	endfor
	return mod .. git
enddef

export def MyTablabel(tab: number = 0): string
	var label = ''
	var bufs = tabpagebuflist(tab)
	const win = tabpagewinnr(tab) - 1
	bufs = remove(bufs, win, win) + bufs
	var names = []
	var i = -1
	for b in bufs
		i += 1
		if len(names) ==# 2
			names += [(MyTablabelSign(bufs[i : ], true) .. '>')]
			break
		endif
		var name = bufname(b)
		if !name
			name = '[No Name]'
		elseif getbufvar(b, '&buftype') ==# 'terminal'
			name = term_getline(b, '.')->trim()
		endif
		name = name->pathshorten()
		if len(tabline_right_text) < len(name)
			name = '<' .. name->matchstr(tabline_right_text)
		endif
		if names->index(name) ==# -1
			names += [MyTablabelSign([b]) .. name]
		endif
	endfor
	label ..= names->join(tabline_labelsep)
	return label
enddef

export def MyTabline(): string
	# 左端をバッファの表示に合わせる(ずれてるとなんか気持ち悪いので)
	var line = '%#TabLineFill#'
	line ..= repeat(' ', getwininfo(win_getid(1))[0].textoff)
	# タブ一覧
	const curtab = tabpagenr()
	for tab in range(1, tabpagenr('$'))
		line ..= tab ==# curtab ? '%#TabLineSel#' : '%#TabLine#'
		line ..= ' '
		line ..= MyTablabel(tab)
		line ..= ' '
	endfor
	line ..= '%#TabLineFill#%T'
	return line
enddef

