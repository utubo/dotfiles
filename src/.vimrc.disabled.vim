vim9script

#
# ボツったけど復活させたくなるかもしれない設定たちの墓場
#

# 微妙なキーマッピング達 {{{

# 最後の選択範囲を現在行の下に移動する
nnoremap <expr> <Space>m $'<Cmd>{getpos("'<")[1]},{getpos("'>")[1]}move {getpos('.')[1]}<CR>'

# }}}

# ユーティリティ {{{
def GetVisualSelectionLines(): list<string>
	var [ay, ax] = getpos('v')[1 : 2]
	var [by, bx] = getpos('.')[1 : 2]
	if by < ay
		[ax, bx] = [bx, ax]
		[ay, by] = [by, ay]
	endif
	var lines = getline(ay, by)
	if mode() ==# 'V'
		# nop
	elseif mode() ==# 'v' && ay !=# by
		lines[-1] = lines[-1][0 : bx - 1]
		lines[0] = lines[0][ax - 1 : ]
	else
		var [s, e] = [ax - 1, bx - 1]->sort('n')
		echo $'{s},{e}'
		for i in range(0, by - ay)
			lines[i] = lines[i][s : e]
		endfor
	endif
	return lines
enddef
#}}}

# 'itchyny/vim-cursorword'の簡易CursorHold版 {{{
def HiCursorWord()
	var cword = expand('<cword>')
	if cword !=# '' && cword !=# get(w:, 'cword_match', '')
		if exists('w:cword_match_id')
			silent! matchdelete(w:cword_match_id)
			unlet w:cword_match_id
		endif
		if cword !~ '^[[-` -/:-@{-~]'
			w:cword_match_id = matchadd('CWordMatch', cword, 0)
			w:cword_match = cword
		endif
	endif
enddef
au vimrc CursorHold * HiCursorWord()
au vimrc ColorScheme * hi CWordMatch cterm=underline gui=underline
#}}}

# Insertモードのマッピング {{{
inoremap jjh <C-o>^
inoremap jjl <C-o>$
#}}}

# テスト用メソッド {{{
def! g:EchoErrors()
	# v:errors見づらい…
	for msg in v:errors
		var m = matchlist(msg, '\(line \d\+\:.*\): Expected \(.*\) but got \(.*\)')
		if len(m) == 0
			echo msg
		else
			echo m[1]
			echo '  Expected: ' .. m[2]
			echo '    Actual: ' .. m[3]
		endif
	endfor
enddef

var progress = 0
const progress_char = '🕐🕑🕒🕓🕔🕕🕖🕗🕘🕙🕚🕛'
def ShowProgress()
	progress += 1
	echon progress_char[progress % 12] .. progress
	redraw
enddef

var allTest = []
def GetAllTest(A: any = 0, L: any = 0, P: any = 0): list<string>
	if !empty(allTest)
		return allTest
	endif
	for i in range(line('$'))
		var m = getline(i)->matchlist('^def \(Test.*\)()')
		if !empty(m)
			allTest->add(m[1])
		endif
	endfor
	return allTest
enddef

def RunTestAtCursor()
	var m = getline('.')->matchlist('^def \(Test.*\)()')
	if !empty(m)
		echo 'Run' m[1]
		RunTest(m[1])
	endif
enddef

def RunTest(qargs: string = '')
	v:errors = []
	progress = 0
	var targets = empty(qargs) ? GetAllTest() : qargs->split(' ')
	for target in targets
		execute target .. '()'
	endfor
	g:EchoErrors()
	if empty(v:errors)
		echo 'Success!'
	endif
enddef
command! -nargs=* -complete=customlist,GetAllTest RunTest RunTest(<q-args>)
nnoremap <buffer> <Leader>T <Cmd>call <SID>RunTest()<CR>
nnoremap <buffer> <Leader>t <Cmd>call <SID>RunTestAtCursor()<CR>
#}}}

# vsnip タブで選択 {{{
# タブ区切りのテキスト(ユーザー辞書ファイル)を編集するのに煩わしかった
for cmd in ['inoremap', 'snoremap']
	execute cmd "<expr> <Tab>   vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)' : pumvisible() ? '<C-n>' : '<Tab>'"
	execute cmd "<expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : pumvisible() ? '<C-p>' : '<S-Tab>'"
endfor
#}}}

# vim-eft かなり惜しい…ハイライト好き {{{
Jetpack 'hrsh7th/vim-eft' # fとtを単語境界にするやつ

# eft {{{
nmap ; <Plug>(eft-repeat)
xmap ; <Plug>(eft-repeat)
omap ; <Plug>(eft-repeat)

nmap f <Plug>(eft-f)
xmap f <Plug>(eft-f)
omap f <Plug>(eft-f)
nmap F <Plug>(eft-F)
xmap F <Plug>(eft-F)
omap F <Plug>(eft-F)

nmap t <Plug>(eft-t)
xmap t <Plug>(eft-t)
omap t <Plug>(eft-t)
nmap T <Plug>(eft-T)
xmap T <Plug>(eft-T)
omap T <Plug>(eft-T)
#}}}

# }}}
