vim9script

# 例: `current.txt|✏sub.txt|🐙>`(3つめ以降は省略)
g:tabline_mod_sign  = get(g:, 'tabline_mod_sign',  "\uf040") # 鉛筆アイコン(Cicaの絵文字だと半角幅になってしまう)
g:tabline_git_sign  = get(g:, 'tabline_git_sign',  '🐙')
g:tabline_dir_sign  = get(g:, 'tabline_dir_sign',  '📂')
g:tabline_term_sign = get(g:, 'tabline_term_sign', "\uf489") # `>_`みたいなアイコン
g:tabline_labelsep  = get(g:, 'tabline_labelsep',  '|')
g:tabline_max_len   = get(g:, 'tabline_max_len',   20)

export def MyTablabelSign(bufs: list<number>, overflow: bool = false): string
	var mod = ''
	var git = ''
	for b in bufs
		const bt = getbufvar(b, '&buftype')
		if bt ==# ''
			if !mod && getbufvar(b, '&modified')
				mod = g:tabline_mod_sign
			endif
			if !git
				var g = false
				silent! g = len(getbufvar(b, 'gitgutter', {'hunks': []}).hunks) !=# 0
				if g
					git = g:tabline_git_sign
				endif
			endif
		endif
		if overflow
			continue
		endif
		if bt ==# 'terminal'
			return g:tabline_term_sign
		endif
		const ft = getbufvar(b, '&filetype')
		if ft ==# 'netrw' || ft ==# 'fern'
			return g:tabline_dir_sign
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
		const l = len(name)
		if g:tabline_max_len < l
			name = '<' .. name->strcharpart(l - g:tabline_max_len)
		endif
		if names->index(name) ==# -1
			names += [MyTablabelSign([b]) .. name]
		endif
	endfor
	label ..= names->join(g:tabline_labelsep)
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

# 使かうときは以下をlazyload.src.vimに書く
# gt, gTしたときだけtablineを表示する(thx:kawarimidollさん)
set showtabline=0
def ShowTab(a: string)
	set tabline=%!vimrc#tabline#MyTabline()
	set showtabline=2
	execute $'normal! g{a}'
	au SafeState * ++once au CursorMoved * ++once set showtabline=0
enddef
Each X=t,T nmap gX <SID>(tab)X | nmap <SID>(tab)X <ScriptCmd>ShowTab('X')<CR><SID>(tab)
