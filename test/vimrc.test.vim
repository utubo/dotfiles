" テスト経過を表示したり、結果を最後にまとめて表示したりしたい {{{

" テスト結果格納場所
let s:result = []

function! s:ShowProgressOK()
	echon '.'
endfunction

function! s:ShowProgressNG()
	echoh Error
	echon 'x'
	echoh Normal
endfunction

function! s:Assert(expr, ...)
	if a:expr
		call s:ShowProgressOK()
	else
		call s:ShowProgressNG()
		let s:result += a:000
	endif
endfunction

function! s:AssertLessThan(expr, num, ...)
	call call('s:Assert', [a:expr < a:num, printf('expect < %d, actual = %d', a:num , a:expr)] + a:000)
endfunction

" }}}

" マッピングが想定外に被ってないか確認する {{{

" わざとデフォルトと被らせてるやつ
" n  <C-H> vim-move
" n  <C-L> vim-move
" n  <C-U> default.vim
" n  <C-W><C-H> vim-shrink
" n  Q     default.vim
" n  gc    vim-caw
" v  <C-L> vim-move
let s:default_ignore =
	\ 'n  \([hjklqsQSY'']\|gc\|gs\|zd\|zf\|<C-G>\|<C-H>\|<C-L>\|<C-U>\|<C-W>\|<Esc>\)\|' .
	\ 'v  \([*]\|<C-L>\)'

" わざと被らせてるやつ(ユーザー定義)
" sandwitch
let s:user_ignore =
	\ 'n  S\|' .
	\ 'v  S'

" ユーザー定義のマッピング
let s:user_map = execute('map')

" デフォルトのマッピング
let s:default_map = []
call add(s:default_map, 'n  [abcdefhijklmnopqrstuvwxA-Z.@"''/?*#:>]')
call add(s:default_map, 'n  g[-#$&''`*+,08;?DEHIJNPQRTUV^_abcdefFghijknmMopqrstuvw@~\]]')
call add(s:default_map, 'n  g<C-[AGH\]]>')
call add(s:default_map, 'n  g<\(Down\|End\|Home\|LeftMouse\|RightMouse\|Up\)>')
call add(s:default_map, 'n  y[yjk0-9]')
call add(s:default_map, 'n  z[-+.=ACDEFGHLMNORWX^abcdefghijklmnopestvwxz]')
call add(s:default_map, 'n  zu[wgWG]')
call add(s:default_map, 'n  <[<0-9jk]')
call add(s:default_map, 'n  g<\(CR\|Left\|Right\)>')
call add(s:default_map, 'n  <C-[ABCDEFGHIJLMNOPQRTUVWXYZ^@\]]>')
call add(s:default_map, 'n  <C-W>[-+:=>FHJKLPRSTW\^_bcdfhijklnopqrstvwxz}|\]]')
call add(s:default_map, 'n  <C-W><C-[-+:=>FHJKLPRSTW\^_bcdfhijklnopqrstvwxz}|\]]>')
call add(s:default_map, 'n  <C-W>\(g[FTft}\]]\|g<C-]>\|<Down>\|<Left>\|<Right>\|<Up>\)')
call add(s:default_map, 'n  <C-W><[^ >]* ')
call add(s:default_map, 'n  <Esc>')
call add(s:default_map, 'n  [\[\]]\([''#(*/DIP[]`cdfimpsz{]\|<C-D>\|<C-I>\|<MiddleMouse>\)')
" ノーマルモード以外の確認はそのうち
call add(s:default_map, 'v  [y.@"''/?:>]')
call add(s:default_map, 'v  <[^ >]* ')
call add(s:default_map, 'v  <Esc>')

" デフォルトと被りがないかを確認する
for s:i in s:default_map
	let s:dup = matchstr(s:user_map, '\C' . s:i . '[^\n]*')
	if match(s:dup, s:default_ignore) == 0
		continue
	endif
	call s:Assert(empty(s:dup), 'デフォルトと被ってるかも' , s:dup)
endfor

" ユーザー定義内で被りがないかを確認する
let s:user_map = split(s:user_map, "\n")
for s:i in s:user_map
	let s:head = matchstr(s:i, '^.\s\+\S\+')
	if empty(s:head) || match(s:head, s:user_ignore) == 0
		continue
	endif
	let s:head = escape(s:head,  '^$.*?/\[]()')
	let s:head = substitute(s:head, '^ ', '.', '')
	let s:head = substitute(s:head, '^[xv]', '[xv]', '')
	let s:head = substitute(s:head, '^[il]', '[il]', '')
	let s:head = '^\C' . s:head
	let s:dups = []
	for s:j in s:user_map
		if match(s:j, s:head) == 0
			call add(s:dups, s:j)
		endif
	endfor
	call s:AssertLessThan(len(s:dups), 2, 'マッピングが被ってるかも', join(s:dups, "\n"))
endfor

" }}}

echo join(s:result, "\n")
echo 'Ran all test.'

