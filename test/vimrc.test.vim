" マッピングが想定外に被ってないか確認
let s:lines = split(execute('map'), "\n")

" ざっくりデフォルトも含めたマッピング
let s:all = copy(s:lines)
call add(s:all, 'n  a             *default*')
call add(s:all, 'n  b             *default*')
call add(s:all, 'n  c             *default*')
call add(s:all, 'n  d             *default*')
call add(s:all, 'n  e             *default*')
call add(s:all, 'n  f             *default*')
call add(s:all, 'n  gg            *default*')
" call add(s:all, 'n  h             *default*')
call add(s:all, 'n  i             *default*')
" call add(s:all, 'n  j             *default*')
" call add(s:all, 'n  k             *default*')
" call add(s:all, 'n  l             *default*')
call add(s:all, 'n  m             *default*')
call add(s:all, 'n  n             *default*')
call add(s:all, 'n  o             *default*')
call add(s:all, 'n  p             *default*')
" call add(s:all, 'n  q             *default*')
call add(s:all, 'n  r             *default*')
" call add(s:all, 'n  s             *default*') -> easy motion
" call add(s:all, 'n  t             *default*')
call add(s:all, 'n  u             *default*')
call add(s:all, 'n  v             *default*')
call add(s:all, 'n  w             *default*')
call add(s:all, 'n  x             *default*')
" call add(s:all, 'n  y             *default*')
" call add(s:all, 'n  z             *default*')
call add(s:all, 'n  A             *default*')
call add(s:all, 'n  B             *default*')
call add(s:all, 'n  C             *default*')
call add(s:all, 'n  D             *default*')
call add(s:all, 'n  E             *default*')
call add(s:all, 'n  F             *default*')
call add(s:all, 'n  G             *default*')
call add(s:all, 'n  H             *default*')
call add(s:all, 'n  I             *default*')
call add(s:all, 'n  J             *default*')
call add(s:all, 'n  K             *default*')
call add(s:all, 'n  L             *default*')
call add(s:all, 'n  M             *default*')
call add(s:all, 'n  N             *default*')
call add(s:all, 'n  O             *default*')
call add(s:all, 'n  P             *default*')
call add(s:all, 'n  Q             *default*')
call add(s:all, 'n  R             *default*')
" call add(s:all, 'n  S             *default*') -> sandwich
call add(s:all, 'n  T             *default*')
call add(s:all, 'n  U             *default*')
call add(s:all, 'n  V             *default*')
call add(s:all, 'n  W             *default*')
call add(s:all, 'n  X             *default*')
" call add(s:all, 'n  Y             *default*') -> y$
call add(s:all, 'n  Z             *default*')
call add(s:all, 'n  <C-f>         *default*')
call add(s:all, 'n  <C-g>         *default*')

" 確認
for s:line in s:lines
	let s:head = matchstr(s:line, '^\S\s\+\S\+')
	if s:head ==# ''
		continue
	endif
	let s:head = '^\C' . escape(s:head,  '^$.*?/\[]()')
	let s:dups = []
	for s:l in s:all
		if match(s:l, s:head) == 0
			call add(s:dups, s:l)
		endif
	endfor
	if len(s:dups) > 1
		echo 'マッピングが被ってるかも'
		echo join(s:dups, "\n")
	endif
endfor

