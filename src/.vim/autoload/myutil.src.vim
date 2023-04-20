vim9script

# 使用頻度の低い関数たち

export def VimGrep(keyword: string, ...targets: list<string>)
	var path = join(targets, ' ')
	# パスを省略した場合は、同じ拡張子のファイルから探す
	if empty(path)
		path = expand('%:e') ==# '' ? '*' : ($'*.{expand('%:e')}')
	endif
	# 適宜タブで開く(ただし明示的に「%」を指定したらカレントで開く)
	const use_tab = (&modified || !empty(bufname())) && path !=# '%'
	if use_tab
		tabnew
	endif
	# lvimgrepしてなんやかんやして終わり
	execute $'silent! lvimgrep {keyword} {path}'
	if ! empty(getloclist(0))
		lwindow
	else
		echoh ErrorMsg
		echomsg $'Not found.: {keyword}'
		echoh None
		if use_tab
			tabnext -
			tabclose +
		endif
	endif
enddef

export def MoveFile(newname: string)
	const oldpath = expand('%')
	const newpath = expand(newname)
	if ! empty(oldpath) && filereadable(oldpath)
		if filereadable(newpath)
			echoh Error
			echo $'file "{newname}" already exists.'
			echoh None
			return
		endif
		rename(oldpath, newpath)
	endif
	execute 'saveas!' newpath
	# 開き直してMRUに登録
	edit
enddef

export def ToggleNumber()
	if &number
		set nonumber
	elseif &relativenumber
		set number norelativenumber
	else
		set relativenumber
	endif
enddef

# ホールドマーカーの前にスペース、後ろに改行を入れる {{{
export def Zf()
	var [firstline, lastline] = VFirstLast()
	execute ':' firstline 's/\v(\S)?$/\1 /'
	append(lastline, IndentStr(firstline))
	cursor([firstline, 1])
	cursor([lastline + 1, 1])
	normal! zf
enddef
#}}}

# ホールドマーカーを削除したら行末をトリムする {{{
export def Zd()
	if foldclosed(line('.')) ==# -1
		normal! zc
	endif
	const head = foldclosed(line('.'))
	const tail = foldclosedend(line('.'))
	if head ==# -1
		return
	endif
	const org = getpos('.')
	normal! zd
	RemoveEmptyLine(tail)
	RemoveEmptyLine(head)
	setpos('.', org)
enddef
#}}}

