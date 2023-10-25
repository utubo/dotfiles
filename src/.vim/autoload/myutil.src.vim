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
	var [firstline, lastline] = g:VFirstLast()
	execute ':' firstline 's/\v(\S)?$/\1 /'
	append(lastline, g:IndentStr(firstline))
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

# vim-sandwich {{{
# 改行で挟んだあとタブでインデントされると具合が悪くなるので…
export def FixSandwichPos()
	var c = g:operator#sandwich#object.cursor
	if g:fix_sandwich_pos[1] !=# c.inner_head[1]
		c.inner_head[2] = getline(c.inner_head[1])->match('\S') + 1
		c.inner_tail[2] = getline(c.inner_tail[1])->match('$') + 1
	endif
enddef

# 囲みを削除したら行末空白と空行も削除
def RemoveEmptyLine(line: number)
	silent! execute ':' line 's/\s\+$//'
	silent! execute ':' line 's/^\s*\n//'
enddef
export def RemoveAirBuns()
	const c = g:operator#sandwich#object.cursor
	RemoveEmptyLine(c.tail[1])
	RemoveEmptyLine(c.head[1])
enddef

# 内側に連続で挟むやつ
var big_mac_crown = []
export def BigMac(first: bool = true)
	const c = first ? [] : g:operator#sandwich#object.cursor.inner_head[1 : 2]
	if first || big_mac_crown !=# c
		big_mac_crown = c
		au vimrc User OperatorSandwichAddPost ++once BigMac(false)
		if first
			feedkeys('S')
		else
			setpos("'<", g:operator#sandwich#object.cursor.inner_head)
			setpos("'>", g:operator#sandwich#object.cursor.inner_tail)
			feedkeys('gvS')
		endif
	endif
enddef
#}}}

# `:%g!/re/d` の結果を新規ウインドウに表示 {{{
# (Buffer Regular Expression Print)
export def Brep(regex: string, mods: string)
	var res = []
	for l in getline(1, '$')
		if l =~# regex
			res += [l]
		endif
	endfor
	if empty(res)
		echoh ErrorMsg
		echo 'Pattern not found: ' .. regex
		echoh Normal
		return
	endif
	execute $'{mods} new'
	append(0, res)
	setlocal nomodified
enddef
#}}}

