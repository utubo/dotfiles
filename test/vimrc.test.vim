let v:errors= []

function! g:EchoErrors()
	" v:errors見づらい…
	for s:e in v:errors
		let s:m = matchlist(s:e, '\(line \d\+\:.*\): Expected \(.*\) but got \(.*\)')
		echo s:m[1]
		echo '  Expected: ' . s:m[2]
		echo '    Actual: ' . s:m[3]
	endfor
endfunction

function! s:ShowProgress()
	echon '.'
endfunction

" マッピングが想定外に被ってないか確認する {{{

" わざとデフォルトと被らせてるやつ
" 以下はvimrc外でデフォルトと被ってる
" n  <C-A> vim-reformatdate
" n  <C-U> default.vim
" n  <C-W><C-H> vim-shrink
" n  <C-X> vim-reformatdate
" n  Q     default.vim
" n  gc    vim-caw
let s:default_ignore = '\C' .
			\ 'n  \([hjklqsQSTY;'']\|gc\|gs\|zd\|zf\|<C-[AUWX]>\|<Esc>\)\|' .
			\ 'v  \([*]\)'

" わざと被らせてるやつ(ユーザー定義)
" sandwitch
let s:user_ignore = '\C' .
			\ 'n  S\|' .
			\ 'v  S'

" ユーザー定義のマッピング
let s:user_map = execute('map')

" デフォルトのマッピング
let s:default_map = []
" ノーマル1文字
call add(s:default_map, 'n  [-!#$%&()+,./:;=>?*:^|_~abcdefhijklmnopqrstuvwxABCDEFGHIJKLMOPQRSTUVWXY]')
" ノーマル英字スタート
call add(s:default_map, 'n  g[-#$&''`*+,@~08;?DEHIJNPQRTUV^_abcdefFghijknmMopqrstuvw\]]')
call add(s:default_map, 'n  g<C-[AGH\]]>')
call add(s:default_map, 'n  g<\(CR\|Left\|Right\|Down\|End\|Home\|LeftMouse\|RightMouse\|Up\)>')
call add(s:default_map, 'n  y[yjk0-9]') " てきとう
call add(s:default_map, 'n  z[-+.=ACDEFGHLMNORWX^abcdefghijklmnopestvwxz]')
call add(s:default_map, 'n  zu[wgWG]')
call add(s:default_map, 'n  Z[ZQ]')
" ノーマル記号スタート
call add(s:default_map, 'n  @[0-9a-zA-Z+.:%_"#@:]')
call add(s:default_map, 'n  "[0-9a-zA-Z+.:%_"#]')
call add(s:default_map, 'n  `[()<>\[\]`{}]')
call add(s:default_map, 'n  ''[a-z]')
call add(s:default_map, 'n  [\[\]]\([''#(*/DIP[]`cdfimpsz{]\|<C-D>\|<C-I>\|<MiddleMouse>\)')
call add(s:default_map, 'n  <[<jk0-9]') " てきとう
" ノーマルCTRL
call add(s:default_map, 'n  <C-[ABCDEFGHIJLMNOPQRTUVWXYZ^@\]]>')
call add(s:default_map, 'n  <C-W>[-+:=>FHJKLPRSTW\^_bcdfhijklnopqrstvwxz}|\]]')
call add(s:default_map, 'n  <C-W><C-[-+:=>FHJKLPRSTW\^_bcdfhijklnopqrstvwxz}|\]]>')
call add(s:default_map, 'n  <C-W>\(g[FTft}\]]\|g<C-]>\|<Down>\|<Left>\|<Right>\|<Up>\)')
call add(s:default_map, 'n  <C-W><[^ >]* ')
" ノーマルその他キー
" call add(s:default_map, 'n  <Esc>…色々') まぁやらなくていいか
" ノーマルモード以外の確認はそのうち
call add(s:default_map, 'v  [y.@"''/?:>]')
call add(s:default_map, 'v  <[^ >]* ')
call add(s:default_map, 'v  <Esc>')

" デフォルトと被りがないかを確認する
for s:i in s:default_map
	call s:ShowProgress()
	let s:lst = []
	call substitute(s:user_map, '\C' . s:i . '[^\n]*', '\=add(s:lst, submatch(0))', 'g')
	call filter(s:lst, { -> v:val !~ s:default_ignore })
	call assert_equal([], s:lst, 'デフォルトと被ってるかも /' . s:i . '/')
endfor

" ユーザー定義内で被りがないかを確認する
let s:user_map = split(s:user_map, "\n")
for s:i in s:user_map
	call s:ShowProgress()
	let s:head = matchstr(s:i, '^.\s\+\S\+')
	if empty(s:head) || match(s:head, s:user_ignore) == 0
		continue
	endif
	let s:head = escape(s:head,  '^$.*?/\[]')
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
	call assert_equal([s:dups[0]], s:dups, 'マッピングが被ってるかも')
endfor

" }}}

call g:EchoErrors()
echo 'Ran all test.'

