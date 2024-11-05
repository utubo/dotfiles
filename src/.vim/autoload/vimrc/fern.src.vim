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
	silent! unlet g:loaded_fern # TODO: 初回cloneのときfern.vimが先行実行されちゃうので…
	packadd fern.vim
	packadd fern-git-status.vim
	packadd fern-renderer-nerdfont.vim
	packadd fern-hijack.vim
	packadd nerdfont.vim
	execute 'Fern' qargs
enddef
