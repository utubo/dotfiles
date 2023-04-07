vim9script noclear

if exists("b:did_my_after_ftplugin")
	finish
endif
b:did_my_after_ftplugin = 1

augroup after_ftplugin_md
	au!
augroup END


# ----------------------------------------------------------
# チェックボックスオンオフ {{{
def ToggleCheckBox()
	for l in g:VRange()
		const a = getline(l)
		var b = substitute(a, '^\(\s*\)- \[ \]', '\1- [x]', '') # check on
		if a ==# b
			b = substitute(a, '^\(\s*\)- \[x\]', '\1- [ ]', '') # check off
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
noremap <buffer> <Space>x <ScriptCmd>ToggleCheckBox()<CR>
nnoremap <buffer> <expr> o 'o' .. matchstr(getline('.'), '\(^\s*\)\@<=- \(\[[x* ]]\)\? \?')
nnoremap <buffer> <expr> O 'O' .. matchstr(getline('.'), '\(^\s*\)\@<=- \(\[[x* ]]\)\? \?')
#}}} -------------------------------------------------------

# ----------------------------------------------------------
# チェックボックスの数をカウント {{{
def CountCheckBoxs(): string
	var [firstline, lastline] = g:VFirstLast()
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
	if firstline > lastline # TODO: なんで？
		return ''
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
		return  $'✅{chkd}/{chkd + empty}{andmore}'
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

