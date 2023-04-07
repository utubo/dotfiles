vim9script noclear

if exists("b:did_my_after_ftplugin")
	finish
endif
b:did_my_after_ftplugin = 1

def BufIsSmth(): bool
	return &modified || ! empty(bufname())
enddef

# デフォルト設定(括弧内にフルパス)だとパスに括弧が含まれているファイルが開けないので、パスに使用されない">"を区切りにする
g:MRU_Filename_Format = {
	formatter: 'fnamemodify(v:val, ":t") . " > " . v:val',
	parser: '> \zs.*',
	syntax: '^.\{-}\ze >'
}
# 数字キーで開く
def MRUwithNumKey(use_tab: bool)
	b:use_tab = use_tab
	setlocal number
	redraw
	echoh Question
	echo $'[1]..[9] => open with a {use_tab ? 'tab' : 'window'}.'
	echoh None
	const key = use_tab ? 't' : '<CR>'
	for i in range(1, 9)
		execute $'nmap <buffer> <silent> {i} :<C-u>{i}<CR>{key}'
	endfor
enddef

Enable b:auto_cursorline_disabled
setlocal cursorline
nnoremap <buffer> w <ScriptCmd>MRUwithNumKey(!b:use_tab)<CR>
nnoremap <buffer> R <Cmd>MruRefresh<CR><Cmd>MRU<CR><Cmd>setlocal number<CR>
nnoremap <buffer> <Esc> <Cmd>q!<CR>
MRUwithNumKey(BufIsSmth())

hi link MruFileName Directory
au vimrc ColorScheme <buffer> hi link MruFileName Directory

