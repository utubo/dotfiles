vim9script

#
# ボツったけど復活させたくなるかもしれない設定たちの墓場
#

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
"}}}

# Insertモードのマッピング {{{
inoremap jjh <C-o>^
inoremap jjl <C-o>$
# }}}

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
}}}
