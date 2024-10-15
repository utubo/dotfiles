vim9script

# vim-sandwich

# `S`をprefixにしているので`nmap S`や`xmap S`をトリガーにして設定する
export def ApplySettings(prefix: string)
	execute $'nunmap {prefix}'
	execute $'xunmap {prefix}'
	g:sandwich = get(g:, 'sandwich', {})
	g:sandwich#recipes = deepcopy(get(g:sandwich, 'default_receipes', []))
	g:sandwich#recipes += [
		{ buns: ["\r", ''  ], input: ["\r"], command: ["normal! a\r"] },
		{ buns: ['',   ''  ], input: ['q'] },
		{ buns: ['「', '」'], input: ['k'] },
		{ buns: ['【', '】'], input: ['K'] },
		{ buns: ['{ ', ' }'], input: ['{'] },
		{ buns: ['${', '}' ], input: ['${'] },
		{ buns: ['%{', '}' ], input: ['%{'] },
		{ buns: ['CommentString(0)', 'CommentString(1)'], expr: 1, input: ['c'] },
	]
	nmap Sd <Plug>(operator-sandwich-delete)ab
	xmap Sd <Plug>(operator-sandwich-delete)
	nmap Sr <Plug>(operator-sandwich-replace)ab
	xmap Sr <Plug>(operator-sandwich-replace)
	nnoremap S <Plug>(operator-sandwich-add)iw
	xnoremap S <Plug>(operator-sandwich-add)
	nmap <expr> Srr (matchstr(getline('.'), '[''"]', col('.')) ==# '"') ? "Sr'" : 'Sr"'
	# `S${`と被ってしまうけどまぁいいか
	nmap S$ vg_S
	# 微調整
	au vimrc User OperatorSandwichAddPre g:fix_sandwich_pos = getpos('.')
	au vimrc User OperatorSandwichAddPost vimrc#sandwich#FixSandwichPos()
	au vimrc User OperatorSandwichDeletePost vimrc#sandwich#RemoveAirBuns()
	# 内側に連続で挟むやつ
	xnoremap Sm <ScriptCmd>vimrc#sandwich#BigMac()<CR>
	nmap Sm viwSm
	feedkeys(prefix, 'it')
enddef

# `<!-- -->`とかを返す
def! g:CommentString(index: number): string
	return &commentstring->split('%s')->get(index, '')
enddef

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
	popup_create('🍔', {
		col: 'cursor',
		line: 'cursor+1',
		moved: 'any',
	})
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

