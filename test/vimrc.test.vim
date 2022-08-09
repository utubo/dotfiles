vim9script

v:errors = []
const vimrc_lines = readfile('../.vimrc')
const vimrc_str = vimrc_lines->join("\n")

# テスト用メソッド {{{
def! g:EchoErrors()
	# v:errors見づらい…
	for msg in v:errors
		var m = matchlist(msg, '\(line \d\+\:.*\): Expected \(.*\) but got \(.*\)')
		if len(m) == 0
			echo msg
		else
			echo m[1]
			echo '  Expected: ' .. m[2]
			echo '    Actual: ' .. m[3]
		endif
	endfor
enddef

var progress = 0
const progress_char = '🕐🕑🕒🕓🕔🕕🕖🕗🕘🕙🕚🕛'
def ShowProgress()
	progress += 1
	echon progress_char[progress % 12] .. progress
	redraw
enddef

# 正規表現でマッチする文字列を全て抽出する
def Scan(expr: any, pat: string, index: number = 0): list<string>
  var scanResult = []
  substitute(expr, pat, (m) => add(scanResult, m[index])[0], 'g')
  return scanResult
enddef
#}}}

# setが重複してないこと {{{
def TestSets()
	var sets = []
	const ignore_names = 'fcs\|foldmethod' # 想定内なので無視する名前s
	for line in vimrc_lines
		ShowProgress()
		var m = matchlist(line, '\<set\s\+\(\w\+\)')
		if len(m) == 0
			m = matchlist(line, '\<&\(\w\+\)\s*=')
		endif
		if len(m) == 0
			continue
		endif
		const name = m[1]
		if name =~ ignore_names
			continue
		endif
		if index(sets, name) != -1
			assert_report('set ' .. name .. 'が複数箇所にある！')
		endif
		sets->add(name)
	endfor
enddef
#}}}

# マッピングが想定外に被ってないこと {{{
def TestMapping()
	# わざとデフォルト(`map`コマンドで取得できないやつ)と被らせてるやつ
	# n  Q  defaults.vimでgqにしてるけど.vimrcでqへ再マップ
	# n  gc vim-caw
	# n  a  _cc
	# n  i  _cc
	# n  m  '
	# n  M  m
	# n  A  _cc
	# n  S  Sandwich
	# n  T  タブ関係
	# n  Y  y$ヘルプにもそう書いてある
	# n  :  <Plug><ahc-switch>:
	# v  :  <Plug><ahc-switch>:
	# v  /  <Plug><ahc-switch>/
	# v  ?  <Plug><ahc-switch>?
	# i     <C-U> defaults.vim
	var default_ignore = '\C' ..
		'n  \([ahijklmqsAMQSTY;''/?:]\|gc\|gs\|zd\|zf\|<C-[AWX]>\|<Esc>\)\|' ..
		'v  \([*/?:]\)\|' ..
		'i  \(<C-U>\)'

	# わざと被らせてるやつ(`map`コマンドで取得できるやつ)
	# 概ねプラグイン内で被ってる
	# n  <Plug>fugitive:
	# i  {     vim-laxima
	# i  [     vim-laxima
	# i  <Esc> vim-laxima
	#    <SNR>XX_(save-cursor-pos) vim-textobj
	var user_ignore = '\C' ..
		'n  \([qS:]\|<Plug>fugitive:\)\|' ..
		'v  \([JS]\)\|' ..
		'i  \(<Esc>\|[「（\[{]\|jj\)\|' ..
		'   <SNR>\d\+_(save-cursor-pos)'

	# ユーザー定義のマッピング
	var user_map = join([execute('map'), execute('map!')], "\n")

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
		var dups = Scan(user_map, '\C' .. i .. '[^\n]*')
		dups->filter((k, v) => v !~ default_ignore)
		assert_equal([], dups, 'デフォルトと被ってるかも /' .. i .. '/')
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
			->escape('^$.*/\[]')
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
# }}}

# その他かんたんなテスト {{{
def TestAutocmd()
	assert_equal([], Scan(vimrc_str, 'au\(tocmd\)\{0,1\} \%(vimrc\)\@!'), 'autocmdはすべてvimrcグループに属すること')
enddef
#}}}

# ユーティリティのテスト {{{
def TestMultiCmd()
	MultiCmd nmap,vmap xxx yyy<if-nmap>NNN<if-vmap>VVV<>zzz
	assert_equal("\n\nn  xxx           yyyNNNzzz", execute('nmap xxx'))
	assert_equal("\n\nv  xxx           yyyVVVzzz", execute('vmap xxx'))
	nunmap xxx
	vunmap xxx
enddef

def TestEnableDisable()
	Enable g:test_vimrc_enable
	Disable g:test_vimrc_disable
	assert_equal(1, g:test_vimrc_enable)
	assert_equal(0, g:test_vimrc_disable)
	unlet g:test_vimrc_enable
	unlet g:test_vimrc_disable
enddef

def TestTruncToDisplayWidth()
	# minifyしたからテストしづらい！ちくしょう誰がこんなことを…
	# var F = function('<SNR>1_TruncToDisplayWidth')
	var F = function('<SNR>1_E')
	assert_equal('123', F('123', 3))
	assert_equal('12>', F('1234', 3))
	assert_equal('あいう', F('あいう', 6))
	assert_equal('あい>',  F('あいう1', 6))
	assert_equal('あい>',  F('あいう', 5))
enddef
#}}}

# テスト実行 {{{
var testDefs = []
def SetupTestDefs()
	for i in range(line('$'))
		var m = getline(i)->matchlist('^def \(Test.*\)()')
		if !empty(m)
			testDefs->add(m[1])
		endif
	endfor
enddef
SetupTestDefs()

def CompTestDefs(A: any, L: any, P: any): list<string>
	return testDefs
enddef

def RunTestAtCursor()
	var m = getline('.')->matchlist('^def \(Test.*\)()')
	if !empty(m)
		echo 'Run' m[1]
		RunTest(m[1])
	endif
enddef

def RunTest(qargs: string = '')
	v:errors = []
	progress = 0
	var targets = empty(qargs) ? testDefs : qargs->split(' ')
	for target in targets
		execute target .. '()'
	endfor
	g:EchoErrors()
	if empty(v:errors)
		echo 'Success!'
	endif
enddef
command! -nargs=* -complete=customlist,CompTestDefs RunTest RunTest(<q-args>)
nnoremap <buffer> <Leader>T <Cmd>call <SID>RunTest()<CR>
nnoremap <buffer> <Leader>t <Cmd>call <SID>RunTestAtCursor()<CR>
#}}}

