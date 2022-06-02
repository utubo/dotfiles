vim9script
set encoding=utf-8
scriptencoding utf-8
augroup gvimrc
	au!
augroup END

# 表示設定 {{{
set cmdheight=1
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
nnoremap <silent> <M-S-k> :call <SID>IncFontSize(1)<CR>
nnoremap <silent> <M-S-j> :call <SID>IncFontSize(-1)<CR>
# }}}

# guioptions {{{
nnoremap <silent> <Esc> :<C-u>set go-=m<Bar>set go-=T<CR>
nnoremap <silent> <M-m> :<C-u>if &go=~#'m'<Bar>set go-=m<Bar>else<Bar>set go+=m<Bar>endif<CR>
nnoremap <silent> <M-t> :<C-u>if &go=~#'T'<Bar>set go-=T<Bar>else<Bar>set go+=T<Bar>endif<CR>
set go-=m
set go-=T
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
	  'winpos ' .. getwinposx() .. ' ' .. getwinposy(),
	]
	writefile(options, g:save_window_file)
enddef
au gvimrc VimLeavePre * SaveWindow()
if filereadable(g:save_window_file)
	execute 'source' g:save_window_file
endif
# }}}

# プラグイン {{{
g:nerdtree_tabs_open_on_gui_startup = 0
g:webdevicons_conceal_nerdtree_brackets = 1
g:WebDevIconsNerdTreeAfterGlyphPadding = ''

def MyLightline()
	g:lightline.separator = { left: "\ue0b0", right: "\ue0b2" }
	g:lightline.subseparator = { left: "", right: "" }
	lightline#init()
	lightline#enable()
enddef
MyLightline()
au gvimrc VimEnter * ++once MyLightline()
au gvimrc BufRead * MyLightline()
# }}}

# Windows {{{
if has('win32')
	# Alt-Spaceでシステムメニュー(winaltkeysはメニューバーが無いと動かないので×)
	noremap <silent> <M-Space> :simalt ~<CR>
	# 外部ツール
	# https://github.com/utubo/winscp_upload.bat
	nnoremap <S-F2> :<C-u>!winscp_upload.bat <C-r>=expand("%:p")<CR>
endif
# }}}

