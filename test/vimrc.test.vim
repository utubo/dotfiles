" テスト結果格納場所
let s:result = []

function s:ShowProgressOK()
	echon '.'
endfunction
function s:ShowProgressNG()
	echoh Error
	echon 'x'
	echoh Normal
endfunction

" マッピングが想定外に被ってないか確認する {{{

" わざと被らせてるやつ(デフォルト)
" <C-h>はvim-move、Qと<C-u>はdefault.vim
let s:default_ignore = {
	\ 'n': split('gs h j k l q s Q S Y zd zf <C-g> <C-h> <C-u> <Esc> '''),
\ }

" わざと被らせてるやつ(ユーザー定義)
" sandwitch
let s:user_ignore = {
	\ 'n': ['S'],
	\ 'v': ['S'],
\ }

" ユーザー定義のマッピングを取得する
let s:user_map = split(execute('map'), "\n")

" デフォルトのマッピングを作成する
let s:default_map = []
function s:AddDefaultMap(mode, keys)
	for l:key in split(a:keys)
		if index(get(s:default_ignore, a:mode, []), l:key) == -1
			call add(s:default_map, printf('%s  %-13s (default)', a:mode, l:key))
		endif
	endfor
endfunction
call s:AddDefaultMap('n', 'a b c d e f')
call s:AddDefaultMap('n', 'g<C-a> g<C-g> g<C-h> g<C-]> g# g$ g& g'' g` g* g+')
call s:AddDefaultMap('n', 'g, g- g0 g8 g; g< g? gD gE gH gI')
call s:AddDefaultMap('n', 'gJ gN gP gQ gR gT gU gV g] g^ g_')
call s:AddDefaultMap('n', 'ga gd ge gf gF gg gh gi gj gk gn')
call s:AddDefaultMap('n', 'gm gM go gp gq gr gs gt gu gv gw')
call s:AddDefaultMap('n', 'g@ g~ g<Down> g<End> g<Home> g<LeftMouse> g<RightMouse> g<Up>')
call s:AddDefaultMap('n', 'h i j k l m n o p q r s t u v w x yy') " y単体は無し
call s:AddDefaultMap('n', 'z<CR> z+ z- z. z=')
call s:AddDefaultMap('n', 'zA zC zD zE zF zG zH zL zM zN zO')
call s:AddDefaultMap('n', 'zR zW zX z^ za zb zc zd ze zf zg')
call s:AddDefaultMap('n', 'zh zi zj zk zl zm zn zo zr zs zt')
call s:AddDefaultMap('n', 'zt zuw zug zuW zuG zv zw zx zz')
call s:AddDefaultMap('n', 'z<Left> z<Right>')
call s:AddDefaultMap('n', 'A B C D E F G H I J K L M N O P Q R S T U V W X Y Z')
call s:AddDefaultMap('n', '<C-f> <C-g> <C-h>')
call s:AddDefaultMap('n', '<Esc> . @ " '' / ? * # :')
" ノーマルモード以外の確認はそのうち
call s:AddDefaultMap('v', 'y')
call s:AddDefaultMap('v', '<Esc> . @ " '' / ? : < >')

" 全部のマッピング
let s:all = s:default_map + s:user_map

" 確認前にちょっと整形
let s:user_ignore_head = ['']
for s:key in keys(s:user_ignore)
	for s:value in s:user_ignore[s:key]
		call add(s:user_ignore_head, s:key . '  ' . s:value)
	endfor
endfor

" 被りがないかを確認する
for s:m in s:user_map
	let s:head = matchstr(s:m, '^.\s\+\S\+')
	if index(s:user_ignore_head, s:head) != -1
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
			call add(s:dups, s:a)
		endif
	endfor
	if len(s:dups) < 2
		call s:ShowProgressOK()
	else
		call s:ShowProgressNG()
		call add(s:result, 'マッピングが被ってるかも')
		call add(s:result, join(s:dups, "\n"))
	endif
endfor

" }}}

echo join(s:result, "\n")
echo 'Ran all test.'

