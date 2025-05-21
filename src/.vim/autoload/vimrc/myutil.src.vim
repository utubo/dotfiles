vim9script

# 使用頻度の低い関数たち

# なんかいいかんじのgrep {{{
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
#}}}

# ホールドマーカーの前にスペース、後ろに改行を入れる {{{
export def Zf()
	const pos = getregionpos(getpos('v'), getpos('.'))
	const firstline = pos[0][0][1]
	const lastline = pos[-1][-1][1]
	execute $':{firstline}s/\v(\S)?$/\1 /'
	const indent = getline(firstline)->matchstr('^\s*')
	append(lastline, indent)
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

# packadd前のプラグインについてもヘルプを表示したい {{{
export def HelpPlugins(name: string)
	const txt = globpath(&rtp, $'**/{name}/doc/*.txt')
	g:a = txt
	if txt !=# ''
		execute 'edit' txt
	endif
	const readme = globpath(&rtp, $'**/{name}/README.md')
	if readme !=# ''
		execute 'edit' readme
	endif
enddef
#}}}

# バッファの情報を色付きで表示 {{{
export def ShowBufInfo(event: string = '')
	if &ft ==# 'qf'
		return
	endif

	var isReadPost = event ==# 'BufReadPost'
	if isReadPost && !filereadable(expand('%'))
		# プラグインとかが一時的なbufnameを付与して開いた場合は無視する
		return
	endif

	const ruler = $' {line(".")}:{col(".")}'

	var msg = []
	add(msg, ['Title', $'"{bufname()}"'])
	add(msg, ['Normal', ' '])
	if &modified
		add(msg, ['Delimiter', '[+]'])
		add(msg, ['Normal', ' '])
	endif
	if !isReadPost && !filereadable(expand('%'))
		add(msg, ['Tag', '[New]'])
		add(msg, ['Normal', ' '])
	endif
	if &readonly
		add(msg, ['WarningMsg', '[RO]'])
		add(msg, ['Normal', ' '])
	endif
	const w = wordcount()
	if isReadPost || w.bytes !=# 0
		add(msg, ['Constant', printf('%dL, %dB', w.bytes ==# 0 ? 0 : line('$'), w.bytes)])
		add(msg, ['Normal', ' '])
	endif
	add(msg, [&ff ==# 'unix' ? 'MoreMsg' : 'WarningMsg', &ff])
	add(msg, ['Normal', ' '])
	const enc = &fenc ?? &encoding
	add(msg, [enc ==# 'utf-8' ? 'MoreMsg' : 'WarningMsg', enc])
	add(msg, ['Normal', ' '])
	add(msg, ['MoreMsg', &ft])
	add(msg, ['Normal', ' '])
	const branch = g:System('git branch')->trim()->matchstr('\w\+$')
	add(msg, ['WarningMsg', branch])
	var msglen = 0
	const maxlen = &columns - len(ruler) - 2
	for i in reverse(range(0, len(msg) - 1))
		var s = msg[i][1]
		var d = strdisplaywidth(s)
		msglen += d
		if maxlen < msglen
			const l = maxlen - msglen + d
			while !empty(s) && l < strdisplaywidth(s)
				s = s[1 :]
			endwhile
			msg[i][1] = s
			msg = msg[i : ]
			insert(msg, ['SpecialKey', '<'], 0)
			break
		endif
	endfor
	add(msg, ['Normal', repeat(' ', maxlen - msglen) .. ruler])
	redraw
	echo ''
	for m in msg
		execute 'echohl' m[0]
		echon m[1]
	endfor
	echohl Normal
	popup_create(expand('%:p'), { line: &lines - 1, col: 1, minheight: 1, maxheight: 1, minwidth: &columns, pos: 'botleft', moved: 'any' })
enddef
# }}}

# カーソル位置をポップアップ {{{
export def PopupCursorPos()
	const p = getcurpos()
	# ついでにハイライト名も表示しちゃう
	const hiname = synID(line('.'), col('.'), 1)->synIDattr('name')->substitute('^$', 'Normal', '')
	popup_create([$'{p[1]}:{p[2]}', hiname], {
		pos: 'botleft',
		line: 'cursor-1',
		col: 'cursor+1',
		moved: 'any',
		padding: [1, 1, 1, 1],
	})
enddef
# }}}

# 選択中の文字数をポップアップ {{{
export def PopupVisualLength()
	var text = getregion(getpos('v'), getpos('.'))->join('')
	popup_create($'{strlen(text)}chars', {
		pos: 'botleft',
		line: 'cursor-1',
		col: 'cursor+1',
		fixed: true,
		moved: 'any',
		padding: [1, 1, 1, 1],
	})
enddef
# }}}
