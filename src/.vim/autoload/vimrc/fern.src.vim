vim9script

export def LazyLoad(qargs: string)
	Enable g:fern#default_hidden
	g:fern#renderer = "nerdfont"
	au vimrc FileType fern {
		Enable b:auto_cursorline_disabled
		setlocal cursorline
		nnoremap <buffer> <F1> <Cmd>:q!<CR>
		nnoremap <buffer> p <Plug>(fern-action-leave)
	}
	packadd fern.vim
	packadd fern-git-status.vim
	packadd fern-renderer-nerdfont.vim
	packadd fern-hijack.vim
	packadd nerdfont.vim
	execute 'Fern' qargs
enddef
