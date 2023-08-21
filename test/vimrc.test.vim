vim9script

# ----------------------------------------------------------
# テスト用関数

# テストフレームワーク {{{
# (諸々のプラグインを読み込んだ状態の動作を確認したいので自作)
# Github Actionsで以下の通り実行する
# cd $GITHUB_WORKSPACE/test
# vim -S vimrc.test.vim

# `:source %`で実行した場合は終了させない
var is_manually_run = expand('%:t') ==# 'vimrc.test.vim'
var suite = {}
var assert = {}
var is_faild = false

def! g:RunTests()
	is_faild = false
	for s in suite->keys()
		echom s
		suite[s]()
	endfor
	echom is_faild ? 'Tests faild.' : 'Tests success.'
	if !is_manually_run
		execute is_faild ? 'cq!' : 'q!'
	endif
enddef

assert.equals = (act: any, exp: any, msg: string = 'assert.equals') => {
	if act !=# exp
		is_faild = true
		echom $'  {msg}'
		echom $'    act: {act}'
		echom $'    exp: {exp}'
	endif
}

assert.falsy = (act: any, msg: string = 'assert.falsy') => {
	assert.equals(act, false, msg)
}
#}}}

# テスト用ユーティリティ {{{
# 正規表現でマッチする文字列を全て抽出する
def Scan(expr: any, pat: string, index: number = 0): list<string>
	var scanResult = []
	substitute(expr, pat, (m) => add(scanResult, m[index])[0], 'g')
	return scanResult
enddef

# スクリプトローカルな関数をテストするためにSIDを確保しておく
var scriptnames_output = ''
redir => scriptnames_output
silent scriptnames
redir END
const vimrc_sid = scriptnames_output
	->split("\n")
	->filter((i, v) => v =~# '/\.vimrc$')[0]
	->matchstr('\d\+')
#}}}

# ----------------------------------------------------------
# Lint

# .vimrc読み込み {{{
const vimrc_path = expand('%:p:h:h') .. '/.vimrc'
const vimrc_lines = readfile(vimrc_path)
const vimrc_str = vimrc_lines->join("\n")
#}}}

# setが重複してないこと {{{
suite.TestSets = () => {
	var sets = []
	const ignore_names = 'fcs\|foldmethod' # 想定内なので無視する名前s
	for line in vimrc_lines
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
		assert.equals(index(sets, name), -1, $'set {name}を複数箇所で定義していないこと')
		sets->add(name)
	endfor
}
#}}}

# マッピングが想定外に被ってないこと {{{
suite.TestMapping = () => {
	# わざとデフォルト(`map`コマンドで取得できないやつ)と被らせてるやつ
	# n  a  _cc
	# n  b  vim-smart-word
	# n  e  vim-smart-word
	# n  gc vim-caw
	# n  ge  vim-smart-word
	# n  g; 折り畳みを開くように修正
	# n  i  _cc
	# n  m  '
	# n  M  m
	# n  n  vim-cmdheight0
	# n  o  markdown checkbox
	# n  w  vim-smart-word
	# n  A  _cc
	# n  O  markdown checkbox
	# n  Q  defaults.vimでgqにしてるけど.vimrcでqへ再マップ
	# n  S  Sandwich
	# n  T  タブ関係
	# n  Y  y$ヘルプにもそう書いてある
	# n  ZZ Zenモード
	# n  %  hlpairsのJump
	# n  :  <Plug><ahc-switch>:
	# v  :  <Plug><ahc-switch>:
	# v  /  <Plug><ahc-switch>/
	# v  ?  <Plug><ahc-switch>?
	# i     <C-U> defaults.vim
	# i     <C-G> 色付きで表示
	var default_ignore = '\C' ..
		'n  \([abehijklmnoqswAMOQSTY;''/?:%]\|gc\|ge\|gs\|g;\|zd\|zf\|ZZ\|<C-[AWXG]>\|<Esc>\)\|' ..
		'v  \([*/?:]\)\|' ..
		'i  \(<C-U>\)'

	# わざと被らせてるやつ(`map`コマンドで取得できるやつ)
	# 概ねプラグイン内で被ってる
	# n  <Plug>fugitive:
	# i  {     vim-laxima
	# i  [     vim-laxima
	# i  <Esc> vim-laxima
	#    <SNR>XX_(save-cursor-pos) vim-textobj
	# n  \\KK  vim-yomigana
	# n  \\HH  vim-yomigana
	var user_ignore = '\C' ..
		'n  \([qS:]\|<Plug>fugitive:\)\|' ..
		'v  \([J]\)\|' ..
		'x  \([S]\)\|' ..
		'i  \(<Esc>\|[「（\[{]\|jj\)\|' ..
		'   <SNR>\d\+_(save-cursor-pos)\|' ..
		'n  <SNR>\d_ws.\|' ..
		'n  \\KK\|' ..
		'n  \\HH\|' ..
		'c  j[jk]'

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
		var dups = Scan(user_map, '\C' .. i .. '[^\n]*')
		dups->filter((k, v) => v !~ default_ignore)
		assert.equals(dups, [], 'マッピングがデフォルトと被ってないこと')
	endfor

	# ユーザー定義内で被りがないかを確認する
	var user_map_lines = split(user_map, "\n")
	for i in user_map_lines
		var head = matchstr(i, '^.\s\+\S\+')
		if empty(head) || match(head, user_ignore) == 0
			continue
		endif
		var head_regex = head
			->escape('^$.*/\[]<')
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
		if !!dups
			assert.equals(dups, [dups[0]], 'マッピングが被っていないこと')
		endif
	endfor
}
# }}}

# ----------------------------------------------------------
# 動作テスト

# マッピングの動作確認 {{{

# ウィンドウサイズ {{{
suite.TestWindowSizeChange = () => {
	# 高さ
	split
	const h = winheight(0)
	execute "normal \<C-w>++"
	assert.equals(winheight(0), h + 2, '<C-w>++でウインドウ高さ+2')
	execute "normal \<C-w>--"
	assert.equals(winheight(0), h, '<C-w>--でウインドウ高さ-2')
	quit
	# 幅
	vsplit
	const w = winwidth(0)
	execute "normal \<C-w>>>"
	assert.equals(winwidth(0), w + 2, '<C-w>>>でウインドウ幅+2')
	execute "normal \<C-w><<"
	assert.equals(winwidth(0), w, '<C-w><<でウインドウ幅-2')
	quit
}
# }}}

# cmdlineの括弧 {{{
suite.TestCmdlinePair = () => {
	g:SetupLexima(0)
	feedkeys(":#\"({'`\<CR>", 'Lx!')
	assert.equals(@:, '#"({''``''})"')

	feedkeys(":#\\(\<CR>", 'Lx!')
	assert.equals(@:, '#\(\)')

	feedkeys(":#\\{\<CR>", 'Lx!')
	assert.equals(@:, '#\{\}')

	feedkeys(":#I'm\<CR>", 'Lx!')
	assert.equals(@:, "#I'm")
}
# }}}

#}}}

# ユーティリティのテスト {{{
suite.TestCmdEach = () => {
	CmdEach nmap,vmap xxx yyy<if-nmap>NNN<if-vmap>VVV<endif>zzz
	assert.equals(execute('nmap xxx'), "\n\nn  xxx           yyyNNNzzz")
	assert.equals(execute('vmap xxx'), "\n\nv  xxx           yyyVVVzzz")
	nunmap xxx
	vunmap xxx
}

suite.TestEach = () => {
	Each nmap,vmap {} xxx yyy_{}
	assert.equals(execute('nmap xxx'), "\n\nn  xxx           yyy_nmap")
	assert.equals(execute('vmap xxx'), "\n\nv  xxx           yyy_vmap")
	nunmap xxx
	vunmap xxx
}

suite.TestEnableDisable = () => {
	Enable g:test_vimrc_enable
	Disable g:test_vimrc_disable
	assert.equals(g:test_vimrc_enable, 1)
	assert.equals(g:test_vimrc_disable, 0)
	unlet g:test_vimrc_enable
	unlet g:test_vimrc_disable
}

suite.TestTruncToDisplayWidth = () => {
	# minifyしたからテストしづらい！ちくしょう誰がこんなことを…
	#var F = function($'<SNR>{vimrc_sid}_TruncToDisplayWidth')
	const F = function($'<SNR>{vimrc_sid}_G')
	assert.equals(F('123',  3), '123')
	assert.equals(F('1234', 3), '12>')
	assert.equals(F('あいう',  6), 'あいう')
	assert.equals(F('あいう1', 6), 'あい>')
	assert.equals(F('あいう',  5), 'あい>')
	assert.equals(F('', 1), '')
	assert.equals(F('>', 1), '>')
	assert.equals(F('あ', 1), '>')
}
#}}}

# その他かんたんなテスト {{{
suite.TestAutocmd = () => {
	assert.equals(
		Scan(vimrc_str, '\<au\(tocmd\)\{0,1\} \%(vimrc\)\@!'), [],
		'autocmdはすべてvimrcグループに属すること'
	)
}

suite.TestIndent = () => {
	const has_noexpand = vimrc_str->match('\n\t') !=# -1
	const has_expand = vimrc_str->match('\n ') !=# -1
	assert.falsy(
		has_noexpand && has_expand || has_noexpand && !has_expand,
		'インデントはハードタブかスペースかどちらかであること'
	)
}
#}}}

# ----------------------------------------------------------

g:RunTests()

