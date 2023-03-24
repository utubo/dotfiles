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
