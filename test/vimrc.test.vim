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
	# n  <C-U> default.vim
	# n  Q     default.vim
	# n  gc    vim-caw
	var default_ignore = '\C' ..
		'n  \([hjklqsQSTY;'']\|gc\|gs\|zd\|zf\|<C-[AUWX]>\|<Esc>\)\|' ..
		'v  \([*]\)'

	# わざと被らせてるやつ(ユーザー定義)
	# 以下はvimrc外でデフォルトと被ってる
	# i  { vim-lexma
	# i  [ vim-lexma
	#    <SNR>XX_(save-cursor-pos) vim-textobj
	var user_ignore = '\C' ..
		'n  S\|' ..
		'v  \([JS]\)\|' ..
		'i  \([「（\[{]\|jj\)\|' ..
		'   .*(save-cursor-pos)'

	# ユーザー定義のマッピング
	var user_map = join([execute('map'), execute('imap'), execute('cmap')], "\n")

	# デフォルトのマッピング
	var default_map = [
		# ノーマル1文字
		'n  [-!#$%&()+,./:;=>?*:^|_~abcdefhijklmnopqrstuvwxABCDEFGHIJKLMOPQRSTUVWXY]',
		# ノーマル英字スタート
		'n  g[-#$&''`*+,@~08;?DEHIJNPQRTUV^_abcdefFghijknmMopqrstuvw\]]',
		'n  g<C-[AGH\]]>',
		'n  g<\(CR\|Left\|Right\|Down\|End\|Home\|LeftMouse\|RightMouse\|Up\)>',
		'n  y[yjk0-9]', # てきとう
		'n  z[-+.=ACDEFGHLMNORWX^abcdefghijklmnopestvwxz]',
		'n  zu[wgWG]',
		'n  Z[ZQ]',
		# ノーマル記号スタート
		'n  @[0-9a-zA-Z+.:%_"#@:]',
		'n  "[0-9a-zA-Z+.:%_"#]',
		'n  `[()<>\[\]`{}]',
		'n  ''[a-z]',
		'n  [\[\]]\([''#(*/DIP[]`cdfimpsz{]\|<C-D>\|<C-I>\|<MiddleMouse>\)',
		'n  <[<jk0-9]', # てきとう
		# ノーマルCTRL
		'n  <C-[ABCDEFGHIJLMNOPQRTUVWXYZ^@\]]>',
		'n  <C-W>[-+:=>FHJKLPRSTW\^_bcdfhijklnopqrstvwxz}|\]]',
		'n  <C-W><C-[-+:=>FHJKLPRSTW\^_bcdfhijklnopqrstvwxz}|\]]>',
		'n  <C-W>\(g[FTft}\]]\|g<C-]>\|<Down>\|<Left>\|<Right>\|<Up>\)',
		'n  <C-W><[^ >]* ',
		# ノーマルその他キー
		# 	'n  <Esc>…色々') まぁやらなくていいか
		# ノーマルモード以外の確認はそのうち
		'v  [y.@"''/?:>]',
		'v  <[^ >]* ',
		'v  <Esc>',
	]

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
		var head_regex = head
			->escape('^$.*?/\[]')
			->substitute('^ ', '[ nvxso]', '')
			->substitute('^n', '[ n]', '')
			->substitute('^v', '[ vxs]', '')
			->substitute('^s', '[ s]', '')
			->substitute('^x', '[ x]', '')
			->substitute('^o', '[ o]', '')
			->substitute('^!', '[!ilc]', '')
			->substitute('^i', '[!i]', '')
			->substitute('^l', '[!il]', '')
			->substitute('^c', '[!c]', '')
			->substitute('^', '^\\C', '')
		var dups = []
		for j in user_map_lines
			if match(j, head_regex) == 0
			add(dups, j)
			endif
		endfor
		dups->uniq() # imapとcmapで「!  ...」 が重複するので
		dups->filter((k, v) => v !~ user_ignore)
		assert_equal([dups[0]], dups, 'マッピングが被ってるかも')
	endfor
enddef
TestMapping()
# }}}

g:EchoErrors()
echo 'Ran all test.'

