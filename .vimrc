set encoding=utf-8
scriptencoding=utf-8
set fileencodings=utf-8,sjis,euc-jp,iso-2022-jp
set tabstop=4
set shiftwidth=4
set list
set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:%
set nf=
set hlsearch
set re=1
augroup s:MyAu
	au!
augroup End

" -----------------------------------------------------------------------------
" ↓なんか初めから書いてあった
if has('vim_starting')
	set nocompatible               " be iMproved
	set runtimepath+=~/.vim/bundle/neobundle.vim
endif

if exists('*neobundle#rc')
	call neobundle#rc(expand('~/.vim/bundle/'))
endif

filetype plugin indent on     " required!
" -----------------------------------------------------------------------------

" -----------------------------------------------------------------------------
" https://github.com/joshtch/dotfiles/blob/ea0013074862b8b12d064b15d71a63471846b35b/vimrc
if !has('gui_running')
	"Terminal
	" Remove small delay between pressing Esc and entering Normal mode.
	set timeout ttimeout ttimeoutlen=-1
	augroup FastEscape
		autocmd!
		au InsertEnter * set timeoutlen=0
		au InsertLeave * set timeoutlen=1000
	augroup END
endif
" -----------------------------------------------------------------------------

" -----------------------------------------------------------------------------
" その他パクリ
au s:MyAu InsertLeave * set nopaste
nnoremap Y y$
xnoremap . :normal .<CR>
inoremap <F6> <C-r>=strftime('%Y/%m/%d(%a)')<CR>
" -----------------------------------------------------------------------------

" ↑ここまでコピペ(頭のいい人が書いたのでメンテ不要)
" ↓ここから自作(頭の悪い人が書いたので要メンテ)

" -----------------------------------------------------------------------------
" 色
function! s:MyColorScheme()
	hi ZenkakuSpace cterm=reverse ctermfg=red gui=underline guifg=red
	hi String ctermfg=blue ctermbg=lightblue
endfunction
function! s:MySyntax()
	syntax match ZenkakuSpace /\%u3000\|\%uA1A1/ containedin=ALL
	syntax region String start=/「/ end=/」/
endfunction
augroup s:MySyntaxGrp
	au!
	au VimEnter,syntax * :call <SID>MySyntax()
	au colorscheme * :call <SID>MyColorScheme()
augroup END
set t_Co=256
syntax on
colorscheme elflord
" -----------------------------------------------------------------------------

" -----------------------------------------------------------------------------
" 日付関係
function! s:Mlen(str)
	return len(substitute(a:str, '.', 'x', 'g'))
endfunction
function! s:YmdToSec(y, m, d)
	let l:y = a:m < 3 ? a:y - 1 : a:y
	let l:m = a:m < 3 ? 12 + a:m : a:m
	return (365 * l:y + l:y / 4 - l:y / 100 + l:y / 400 + 306 * (l:m + 1) / 10 + a:d - 428 - 719163) * 86400 " 1970/01/01=719163
endfunction
function! s:ReformatDate(...)
	let ymd_reg = '\<\(\d\{4}\)/\(-\{-}\d\{1,3}\)/\(-\{-}\d\{1,3}\)'
	let l:start = match(getline('.'), l:ymd_reg, col('.') - 12) + 1
	if l:start < 1 || col('.') + 12 < l:start
		return
	endif
	" 「%Y/%m/%d」を抽出して1970/01/01からの経過秒に変換
	let l:ymd = matchlist(getline('.'), l:ymd_reg, col('.') - 12)
	let l:dt = a:0 != 0 ? a:1 : s:YmdToSec(str2nr(l:ymd[1]), str2nr(l:ymd[2]), str2nr(l:ymd[3]))
	" 再フォーマットして置き換え
	let l:col_org = col('.')
	call cursor(line('.'), l:start)
	execute 'normal "_'.s:Mlen(l:ymd[0]).'xi'.strftime('%Y/%m/%d', l:dt)."\<ESC>"
	" 近くに曜日があったらそれも更新する
	for l:i in range(0,6)
		let l:a = strftime('%a', l:i * 86400)
		let l:a_pos = match(getline('.'), l:a, col('.')) + 1
		if 0 < l:a_pos && l:a_pos < col('.') + 3
			call cursor(line('.'), l:a_pos)
			execute 'normal "_'.s:Mlen(l:a).'s'.strftime('%a', l:dt)."\<ESC>"
			break
		endif
	endfor
	" カーソル位置を元に戻して終わり
	call cursor(line('.'), l:col_org)
endfunction
" 「%Y/%m/%d」の文字列を加算減算
nnoremap <silent> <C-a> <C-a>:call <SID>ReformatDate()<CR>
nnoremap <silent> <C-x> <C-x>:call <SID>ReformatDate()<CR>
" 「%Y/%m/%d」の文字列を今日の日付に置換
nnoremap <silent> <F6> :call <SID>ReformatDate(localtime())<CR>
" -----------------------------------------------------------------------------

" -----------------------------------------------------------------------------
" Android の Hacker's-Keybord用キーバインド
" ・キーちっちゃい宇宙大きい
" ・スマホでのコーディングは基本的にバグ取り
nnoremap ; :
nnoremap <Space>zz :q!<CR>
nnoremap <Space><Space> /<CR>
nnoremap <Space><Up> ?<CR>
" スタックトレースからyankしてソースの該当箇所を探す
nnoremap <Space>e <S-G>?Err\\|Exception<CR>
noremap  <Space>w eb"wyee:echo 'yanked "'.@w.'" to "w'<CR>
nnoremap <expr> <Space>g (@w =~ '^\d\+$' ? ':' : '/').@w."\<CR>"
" -----------------------------------------------------------------------------

" -----------------------------------------------------------------------------
" その他細々したの
noremap! <C-r><C-r> <C-r>"
noremap  <expr> <Space>jj search('^'.matchstr(getline('.'), '^[\t ]\+').'\zs[^\t ]').'G^'
noremap  <expr> <Space>kk search('^'.matchstr(getline('.'), '^[\t ]\+').'\zs[^\t ]', 'b').'G^'
noremap  <expr> <Space>jv '<S-v>'.search('^'.matchstr(getline('.'), '^[\t ]\+').'\zs[^\t ]').'G^'
noremap  <expr> <Space>kv '<S-v>'.search('^'.matchstr(getline('.'), '^[\t ]\+').'\zs[^\t ]', 'b').'G^'
inoremap 「 「」<Left>
inoremap <S-Tab> <Right>
" -----------------------------------------------------------------------------

