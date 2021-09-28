" テスト結果格納
let s:result = []

" マッピングが想定外に被ってないか確認する {{{

" わざと被らせてるやつ(デフォルト)
" <C-h>はvim-move、Qと<C-u>はdefault.vim
let s:default_ignore = {
	\ 'n': split('gs h j k l q s Q S Y zd zf <C-g> <C-h> <C-u> <Esc> '''),
	\ 'l': [], 'i': [], 'v': [], 'c': [], 'o': [], 't': [],
\ }

" わざと被らせてるやつ(ユーザー定義)
let s:user_ignore = ['n  S', 'v  S'] " sandwich

" ユーザー定義のマッピングを取得する
let s:user_map = split(execute('map'), "\n")

" ざっくりデフォルトも含めたマッピングを作る
let s:all = copy(s:user_map)
function s:AddToAll(mode, keys)
	for l:key in split(a:keys, ' ')
		if index(s:default_ignore[a:mode], l:key) == -1
			call add(s:all, printf('%s  %-13s *default*', a:mode, l:key))
		endif
	endfor
endfunction
call s:AddToAll('n', 'a b c d e f')
call s:AddToAll('n', 'g<C-a> g<C-g> g<C-h> g<C-]> g# g$ g& g'' g` g* g+')
call s:AddToAll('n', 'g, g- g0 g8 g; g< g? gD gE gH gI')
call s:AddToAll('n', 'gJ gN gP gQ gR gT gU gV g] g^ g_')
call s:AddToAll('n', 'ga gd ge gf gF gg gh gi gj gk gn')
call s:AddToAll('n', 'gm gM go gp gq gr gs gt gu gv gw')
call s:AddToAll('n', 'g@ g~ g<Down> g<End> g<Home> g<LeftMouse> g<RightMouse> g<Up>')
call s:AddToAll('n', 'h i j k l m n o p q r s t u v w x yy') " y単体は無し
call s:AddToAll('n', 'z<CR> z+ z- z. z=')
call s:AddToAll('n', 'zA zC zD zE zF zG zH zL zM zN zO')
call s:AddToAll('n', 'zR zW zX z^ za zb zc zd ze zf zg')
call s:AddToAll('n', 'zh zi zj zk zl zm zn zo zr zs zt')
call s:AddToAll('n', 'zt zuw zug zuW zuG zv zw zx zz')
call s:AddToAll('n', 'z<Left> z<Right>')
call s:AddToAll('n', 'A B C D E F G H I J K L M N O P Q R S T U V W X Y Z')
call s:AddToAll('n', '<C-f> <C-g> <C-h>')
call s:AddToAll('n', '<Esc> . @ " '' / ? * # :')
" ノーマルモード以外の確認はそのうち
call s:AddToAll('v', 'y')
call s:AddToAll('v', '<Esc> . @ " '' / ? : < >')

" 被りがないかを確認する
for s:m in s:user_map
	echon '.'
	let s:head = matchstr(s:m, '^.\s\+\S\+')
	if s:head ==# '' || index(s:user_ignore, s:head) != -1
		continue
	endif
	let s:head = escape(s:head,  '^$.*?/\[]()')
	let s:head = substitute(s:head, '^ ', '.', '')
	let s:head = substitute(s:head, '^[xv]', '[xv]', '')
	let s:head = substitute(s:head, '^[il]', '[il]', '')
	let s:head = '^\C' . s:head
	let s:dups = []
	for s:a in s:all
		if match(s:a, s:head) == 0
			call add(s:dups, s:l)
		endif
	endfor
	if len(s:dups) > 1
		call add(s:result, 'マッピングが被ってるかも')
		call add(s:result, join(s:dups, "\n"))
	endif
endfor

" }}}

echo join(s:result, "\n")
echo 'Ran all test.'

