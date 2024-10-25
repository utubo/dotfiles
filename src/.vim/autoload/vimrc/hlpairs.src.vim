vim9script

export def LazyLoad()
	packadd vim-hlpairs
	nnoremap % <ScriptCmd>hlpairs#Jump()<CR>
	nnoremap ]% <ScriptCmd>hlpairs#Jump('f')<CR>
	nnoremap [% <ScriptCmd>hlpairs#Jump('b')<CR>
	nnoremap <Leader>% <ScriptCmd>hlpairs#HighlightOuter()<CR>
	nnoremap <Space>% <ScriptCmd>hlpairs#ReturnCursor()<CR>
	hlpairs#TextObjUserMap('%')
enddef

