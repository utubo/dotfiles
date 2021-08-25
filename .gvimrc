set encoding=utf-8
scriptencoding utf-8
augroup gvimrc
	au!
augroup END

" 表示設定 {{{
set cmdheight=1
set textwidth=0
set renderoptions=type:directx,renmode:6
set guifont=Cica:h13
" 絵文字テスト 🐞_🐝_
" }}}

" フォントサイズ変更 {{{
function! s:IncFontSize(d) abort
	let [name, size] = split(&guifont, ':h')
	let size = size + a:d
	let &guifont = name . ':h' . size
endfunction
nnoremap <silent> <M-k> :call <SID>IncFontSize(1)<CR>
nnoremap <silent> <M-j> :call <SID>IncFontSize(-1)<CR>
" }}}

" guioptions {{{
nnoremap <silent> <Esc> :<C-u>set go-=m<Bar>set go-=T<CR>
nnoremap <silent> <M-m> :<C-u>if &go=~#'m'<Bar>set go-=m<Bar>else<Bar>set go+=m<Bar>endif<CR>
nnoremap <silent> <M-t> :<C-u>if &go=~#'T'<Bar>set go-=T<Bar>else<Bar>set go+=T<Bar>endif<CR>
set go-=m
set go-=T
" }}}

" ウィンドウ位置記憶 {{{
" http://vim-jp.org/vim-users-jp/2010/01/28/Hack-120.html
let g:save_window_file = expand('~/.vimwinpos')
function! s:save_window()
	let s:options = [
	  \ 'set background=' . &background,
	  \ 'colorscheme ' . g:colors_name,
	  \ 'set columns=' . &columns,
	  \ 'set lines=' . &lines,
	  \ 'winpos ' . getwinposx() . ' ' . getwinposy(),
	  \ ]
	call writefile(s:options, g:save_window_file)
endfunction
au gvimrc VimLeavePre * call s:save_window()
if filereadable(g:save_window_file)
	execute 'source' g:save_window_file
endif
" }}}

" プラグイン {{{
let g:nerdtree_tabs_open_on_gui_startup = 0
let g:webdevicons_conceal_nerdtree_brackets = 1
let g:WebDevIconsNerdTreeAfterGlyphPadding = ''

au Syntax * RainbowToggleOn

function! s:MyLightline()
	let g:lightline = {
		\ 'separator': { 'left': "\ue0b0", 'right': "\ue0b2" },
		\ 'subseparator': { 'left': "\ue0b1", 'right': "\ue0b3" }
		\ }
	call lightline#init()
	call lightline#enable()
endfunction
call s:MyLightline()
au gvimrc VimEnter * ++once call <SID>MyLightline()
au gvimrc BufRead * call <SID>MyLightline()
" }}}

" Windows {{{
if has('win32')
	" Alt-Spaceでシステムメニュー(winaltkeysはメニューバーが無いと動かないので×)
	noremap <M-Space> :simalt ~<CR>
endif
" }}}

