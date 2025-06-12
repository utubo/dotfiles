vim9script

# これをvimrcとかに定義する
# yankした文字をecho {{{
set report=9999
# 他のプラグインと競合するのでタイマーで遅延させる
def g:EchoYankText(t: number)
	vimrc#echoyanktext#EchoYankText()
enddef
au vimrc TextYankPost * timer_start(1, g:EchoYankText)
# }}}

# 本体
export def EchoYankText()
	const title = get(g:, 'echo_yank_text_title', 'yanked: ')
	const chars = {
		"\<Tab>": get(g:, 'echo_yank_text_tab', '›'),
		"\<CR>": get(g:, 'echo_yank_text_cr', '↵')
	}
	const hls = {
		"\<Tab>": 'MoreMsg',
		"\<CR>": 'MoreMsg'
	}
	const width = winwidth(0) - 1
	if width <= strdisplaywidth(title)
		return
	endif
	echoh WarningMsg
	echo title
	var w = 0
	for c in @"[0 : winwidth(0)]->substitute('\n', "\<CR>", 'g')
		var cc = get(chars, c, c)
		w += strdisplaywidth(cc)
		if width <= w
			echoh MoreMsg
			echon '>'
			echoh MsgArea
			return
		endif
		execute 'echohl' get(hls, c, 'MsgArea')
		echon cc
	endfor
	echoh MsgArea
enddef
