vim9script
set encoding=utf-8
scriptencoding utf-8
augroup gvimrc
	au!
augroup END

# 表示設定 {{{
set textwidth=0
set renderoptions=type:directx,renmode:6
set guifont=Cica:h13
# 絵文字テスト 🐞_🐝_
# }}}

# フォントサイズ変更 {{{
def IncFontSize(d: number)
	var f = split(&guifont, ':h')
	&guifont = f[0] .. ':h' .. (str2nr(f[1]) + d)
enddef
nnoremap <silent> <M-C-k> <Cmd>call <SID>IncFontSize(v:count1)<CR>
nnoremap <silent> <M-C-j> <Cmd>call <SID>IncFontSize(-v:count1)<CR>
# 禁断のマウス操作 (拡大縮小はこっちのほうが馴染みがあるから…)
nnoremap <silent> <C-ScrollWheelUp> <Cmd>call <SID>IncFontSize(v:count1)<CR>
nnoremap <silent> <C-ScrollWheelDown> <Cmd>call <SID>IncFontSize(-v:count1)<CR>
# }}}

# guioptions {{{
nnoremap <silent> <Esc> <Cmd>set go-=m<Bar>set go-=T<CR>
nnoremap <silent> <M-m> <Cmd>if &go=~#'m'<Bar>set go-=m<Bar>else<Bar>set go+=m<Bar>endif<CR>
nnoremap <silent> <M-t> <Cmd>if &go=~#'T'<Bar>set go-=T<Bar>else<Bar>set go+=T<Bar>endif<CR>
set go-=m
set go-=T
# }}}

# Tabline {{{
# gvimのタブにCicaフォントが使えないので
g:tabline_mod_sign = '✏'
g:tabline_git_sign = '🐙'
g:tabline_dir_sign = '📂'
g:tabline_term_sign = '⚡'
# gvimのタブだと'|'は見づらかったので
g:tabline_labelsep = ', '
set guitablabel=%{vimrc#tabline#MyTablabel()}
# }}}

# ウィンドウ位置記憶 {{{
# http://vim-jp.org/vim-users-jp/2010/01/28/Hack-120.html
g:save_window_file = expand('~/.vimwinpos')
def SaveWindow()
	var options = [
		'set background=' .. &background,
		'colorscheme ' .. g:colors_name,
		'set columns=' .. &columns,
		'set lines=' .. &lines,
		'set guifont=' .. &guifont,
		'winpos ' .. getwinposx() .. ' ' .. getwinposy(),
	]
	writefile(options, g:save_window_file)
enddef
au gvimrc VimLeavePre * SaveWindow()
if filereadable(g:save_window_file)
	execute 'source' g:save_window_file
endif
# }}}

# プラグイン設定 {{{
SclowDisable
# }}}

# Windows {{{
if has('win32')
	# Alt-Spaceでシステムメニュー(winaltkeysはメニューバーが無いと動かないので×)
	noremap <silent> <M-Space> <Cmd>simalt ~<CR>
	# 外部ツール
	# https://github.com/utubo/winscp_upload.bat
	nnoremap <S-F2> :<C-u>!winscp_upload.bat <C-r>=expand("%:p")<CR>
endif
# }}}

