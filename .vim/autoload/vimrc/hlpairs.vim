vim9script
export def LazyLoad()
packadd vim-hlpairs
nn % <ScriptCmd>hlpairs#Jump()<CR>
nn ]% <ScriptCmd>hlpairs#Jump('f')<CR>
nn [% <ScriptCmd>hlpairs#Jump('b')<CR>
nn <Leader>% <ScriptCmd>hlpairs#HighlightOuter()<CR>
nn <Space>% <ScriptCmd>hlpairs#ReturnCursor()<CR>
hlpairs#TextObjUserMap('%')
enddef
