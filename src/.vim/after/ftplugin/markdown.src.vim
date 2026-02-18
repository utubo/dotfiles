vim9script noclear

if exists("b:did_my_after_ftplugin")
	finish
endif
b:did_my_after_ftplugin = 1

augroup after_ftplugin_md
	au!
augroup END

def GetRange(): list<number>
	return getregionpos(getpos('v'), getpos('.'))->map((_, v) => v[0][1])
enddef

# ----------------------------------------------------------
# チェックボックスオンオフ {{{
def ToggleCheckBox(x: string)
	for l in GetRange()
		const a = getline(l)
		var b = substitute(a, '^\(\s*\)- \[ \]', $'\1- [{x}]', '') # check on
		if a ==# b
			b = substitute(a, '^\(\s*\)- \[[-x*]\]', '\1- [ ]', '') # check off
		endif
		if a ==# b
			b = substitute(a, '^\(\s*\)\(- \)*', '\1- [ ] ', '') # a new check box
		endif
		setline(l, b)
		if l ==# line('.')
			var c = getpos('.')
			c[2] += len(b) - len(a)
			setpos('.', c)
		endif
	endfor
enddef
noremap  <buffer> <Space>c <ScriptCmd>ToggleCheckBox('x')<CR>
inoremap <buffer> <Space>c <ScriptCmd>ToggleCheckBox('x')<CR>
noremap  <buffer> <Space><Space>c <ScriptCmd>ToggleCheckBox('-')<CR>
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# リストオンオフ {{{
def ToggleListMark()
	for l in GetRange()
		const a = getline(l)
		var b = substitute(a, '^\(\s*\)-\( \[[x ]\]\)\? ', '\1', '') # remove list-mark
		if a ==# b
			b = substitute(a, '^\(\s*\)', '\1- ', '') # dd list-mark
		endif
		setline(l, b)
		if l ==# line('.')
			var c = getpos('.')
			c[2] += len(b) - len(a)
			setpos('.', c)
		endif
	endfor
enddef
nnoremap <buffer> <Space>- <ScriptCmd>ToggleListMark()<CR>
inoremap <buffer> <LocalLeader>- <ScriptCmd>ToggleListMark()<CR>
xnoremap <buffer> <Space>- <ScriptCmd>ToggleListMark()<CR>
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# チェックボックスの数をカウント {{{
def CountCheckBoxs(): string
	var [firstline, lastline] = [line('.'), line('v')]->sort('n')
	if mode() ==? 'V'
		# OK
	elseif &ft !=# 'markdown'
		return ''
	else
		const indent = indent(firstline)
		for l in range(firstline + 1, line('$'))
			if indent(l) <= indent
				break
			endif
			lastline = l
		endfor
	endif
	# 念のためmax99行
	const MAX_LINES = 99 - 1
	var andmore = ''
	if firstline + MAX_LINES < lastline
		andmore = '+'
		lastline = firstline + MAX_LINES
	endif
	var chkd = 0
	var empty = 0
	for l in range(firstline, lastline)
		const line = getline(l)
		if line->match('^\s*- \[x\]') !=# -1
			chkd += 1
		elseif line->match('^\s*- \[ \]') !=# -1
			empty += 1
		endif
	endfor
	if chkd ==# 0 && empty ==# 0
		return ''
	else
		var h = empty ==# 0 ? 'ChkCountIconOk' : 'ChkCountIcon'
		return $'%#{h}#✅%*{chkd}/{chkd + empty}{andmore}'
	endif
enddef

def CountCheckBoxsDelay()
	if mode()[0] !=# 'n'
		return
	endif
	const count = CountCheckBoxs()
	if count !=# get(w:, 'ruler_mdcb', '')
		w:ruler_mdcb = count
		silent! cmdheight0#Invalidate()
	endif
enddef

# MoveCursorは呼び出し回数が多いので、移動途中はユーザーイベントで300ミリ秒に1回だけ実行するようにする
const CM_DELAY_MSEC = 300
var cm_delay_timer = 0
var cm_delay_cueue = 0
def CursorMovedDelayExec(timer: any = 0)
	cm_delay_timer = 0
	if cm_delay_cueue !=# 0
		cm_delay_cueue = 0
		CountCheckBoxsDelay()
	endif
enddef
def CursorMovedDelay()
	if cm_delay_timer !=# 0
		cm_delay_cueue += 1
		return
	endif
	# 最初の1回は即時実行する
	CountCheckBoxsDelay()
	cm_delay_cueue = 0
	cm_delay_timer = timer_start(CM_DELAY_MSEC, CursorMovedDelayExec)
enddef
au after_ftplugin_md CursorMoved <buffer> CursorMovedDelay()
# }}}

# ----------------------------------------------------------
# リスト項目内で改行 {{{
def ElaseListMark()
	for l in GetRange()
		const a = substitute(getline(l), '^\(\s*\)-\( \[[x ]\]\)\? ', '\1' .. repeat(' ', len('\2')), '')
		setline(l, a)
	endfor
enddef
inoremap <buffer> <LocalLeader>r <CR><ScriptCmd>ElaseListMark()<CR>
nnoremap <buffer> <LocalLeader>r <ScriptCmd>ElaseListMark()<CR>
xnoremap <buffer> <LocalLeader>r <ScriptCmd>ElaseListMark()<CR>
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# その他定義 {{{
g:vim_markdown_new_list_item_indent = 2
#}}} -------------------------------------------------------
# minviml:fixed=CursorMovedDelayExec
