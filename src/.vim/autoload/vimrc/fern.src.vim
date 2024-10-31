vim9script

export def LazyLoad(qargs: string)
	Enable g:fern#default_hidden
	g:fern#renderer = "nerdfont"
	au vimrc FileType fern {
		Enable b:auto_cursorline_disabled
		setlocal cursorline
		nnoremap <buffer> <F1> <C-o>
		# 数字キーで開く
		setlocal numberwidth=1
		setlocal number
		nnoremap <buffer> 0 <Plug>(fern-action-leave)
		for i in range(2, 19)
			execute $'nmap <buffer> <silent> {i} :<C-u>{i}<CR><CR>'
		endfor
	}
	packadd fern.vim
	packadd fern-git-status.vim
		nnoremap <buffer> 1 <Plug>(fern-action-leave)
	packadd fern-renderer-nerdfont.vim
	packadd fern-hijack.vim
	packadd nerdfont.vim
	execute 'Fern' qargs
enddef
