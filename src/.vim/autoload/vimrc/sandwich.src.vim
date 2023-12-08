vim9script

# vim-sandwich拡張

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

