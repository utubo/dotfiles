vim9script

v:errors = []
def! g:EchoErrors()
	# v:errors見づらい…
	for e in v:errors
		var m = matchlist(e, '\(line \d\+\:.*\): Expected \(.*\) but got \(.*\)')
		echo m[1]
		echo '  Expected: ' .. m[2]
		echo '    Actual: ' .. m[3]
	endfor
enddef

var progress = 0
var progress_char = '🕐🕑🕒🕓🕔🕕🕖🕗🕘🕙🕚🕛'
def ShowProgress()
	progress += 1
	echon progress_char[progress % 12] .. progress
	redraw
enddef

# マッピングが想定外に被ってないか確認する {{{
var lst = []
def TestMapping()
	# わざとデフォルトと被らせてるやつ
	# 以下はvimrc外でデフォルトと被ってる
	# n  <C-A> vim-reformatdate
	# n  <C-U> default.vim
	# n  <C-W><C-H> vim-shrink
	# n  <C-X> vim-reformatdate
	# n  Q     default.vim
	# n  gc    vim-caw
	var default_ignore = '\C' ..
		'n  \([hjklqsQSTY;'']\|gc\|gs\|zd\|zf\|<C-[AUWX]>\|<Esc>\)\|' ..
		'v  \([*]\)'

	# わざと被らせてるやつ(ユーザー定義)
	# sandwitch
	var user_ignore = '\C' ..
		'n  S\|' ..
		'v  S'

	# ユーザー定義のマッピング
	var user_map = execute('map')

	# デフォルトのマッピング
	var default_map = []
	# ノーマル1文字
	add(default_map, 'n  [-!#$%&()+,./:;=>?*:^|_~abcdefhijklmnopqrstuvwxABCDEFGHIJKLMOPQRSTUVWXY]')
	# ノーマル英字スタート
	add(default_map, 'n  g[-#$&''`*+,@~08;?DEHIJNPQRTUV^_abcdefFghijknmMopqrstuvw\]]')
	add(default_map, 'n  g<C-[AGH\]]>')
	add(default_map, 'n  g<\(CR\|Left\|Right\|Down\|End\|Home\|LeftMouse\|RightMouse\|Up\)>')
	add(default_map, 'n  y[yjk0-9]') # てきとう
	add(default_map, 'n  z[-+.=ACDEFGHLMNORWX^abcdefghijklmnopestvwxz]')
	add(default_map, 'n  zu[wgWG]')
	add(default_map, 'n  Z[ZQ]')
	# ノーマル記号スタート
	add(default_map, 'n  @[0-9a-zA-Z+.:%_"#@:]')
	add(default_map, 'n  "[0-9a-zA-Z+.:%_"#]')
	add(default_map, 'n  `[()<>\[\]`{}]')
	add(default_map, 'n  ''[a-z]')
	add(default_map, 'n  [\[\]]\([''#(*/DIP[]`cdfimpsz{]\|<C-D>\|<C-I>\|<MiddleMouse>\)')
	add(default_map, 'n  <[<jk0-9]') # てきとう
	# ノーマルCTRL
	add(default_map, 'n  <C-[ABCDEFGHIJLMNOPQRTUVWXYZ^@\]]>')
	add(default_map, 'n  <C-W>[-+:=>FHJKLPRSTW\^_bcdfhijklnopqrstvwxz}|\]]')
	add(default_map, 'n  <C-W><C-[-+:=>FHJKLPRSTW\^_bcdfhijklnopqrstvwxz}|\]]>')
	add(default_map, 'n  <C-W>\(g[FTft}\]]\|g<C-]>\|<Down>\|<Left>\|<Right>\|<Up>\)')
	add(default_map, 'n  <C-W><[^ >]* ')
	# ノーマルその他キー
	# add(default_map, 'n  <Esc>…色々') まぁやらなくていいか
	# ノーマルモード以外の確認はそのうち
	add(default_map, 'v  [y.@"''/?:>]')
	add(default_map, 'v  <[^ >]* ')
	add(default_map, 'v  <Esc>')

	# デフォルトと被りがないかを確認する
	for i in default_map
		ShowProgress()
		lst = []
		substitute(user_map, '\C' .. i .. '[^\n]*', '\=add(lst, submatch(0))', 'g')
		filter(lst, (k, v) => v !~ default_ignore)
		assert_equal([], lst, 'デフォルトと被ってるかも /' .. i .. '/')
	endfor

	# ユーザー定義内で被りがないかを確認する
	var user_map_lines = split(user_map, "\n")
	for i in user_map_lines
		ShowProgress()
		var head = matchstr(i, '^.\s\+\S\+')
		if empty(head) || match(head, user_ignore) == 0
			continue
		endif
		head = escape(head,  '^$.*?/\[]')
		head = substitute(head, '^ ', '.', '')
		head = substitute(head, '^[xv]', '[xv]', '')
		head = substitute(head, '^[il]', '[il]', '')
		head = '^\C' .. head
		var dups = []
		for j in user_map_lines
			if match(j, head) == 0
			add(dups, j)
			endif
		endfor
		assert_equal([dups[0]], dups, 'マッピングが被ってるかも')
	endfor
enddef
TestMapping()
# }}}

g:EchoErrors()
echo 'Ran all test.'

