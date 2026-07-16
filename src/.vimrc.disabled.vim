vim9script

#
# ボツったけど復活させたくなるかもしれない設定たちの墓場
#

# 微妙なキーマッピング達 {{{

# 最後の選択範囲を現在行の下に移動する
nnoremap <expr> <Space>m $'<Cmd>{getpos("'<")[1]},{getpos("'>")[1]}move {getpos('.')[1]}<CR>'

# }}}

# ユーティリティ {{{
def GetVisualSelectionLines(): list<string>
	var [ay, ax] = getpos('v')[1 : 2]
	var [by, bx] = getpos('.')[1 : 2]
	if by < ay
		[ax, bx] = [bx, ax]
		[ay, by] = [by, ay]
	endif
	var lines = getline(ay, by)
	if mode() ==# 'V'
		# nop
	elseif mode() ==# 'v' && ay !=# by
		lines[-1] = lines[-1][0 : bx - 1]
		lines[0] = lines[0][ax - 1 : ]
	else
		var [s, e] = [ax - 1, bx - 1]->sort('n')
		for i in range(0, by - ay)
			lines[i] = lines[i][s : e]
		endfor
	endif
	return lines
enddef

# こんな感じ
# CmdEach nmap,xmap xxx yyy<if-nmap>NNN<if-xmap>VVV<endif>zzz
# ↓
# nmap xxx yyyNNNzzz | xmap xxx yyyVVVzzz
def CmdEach(qargs: string)
	const [cmds, args] = qargs->split('^\S*\zs')
	for cmd in cmds->split(',')
		const a = args
			->substitute($'<if-{cmd}>', '<endif>', 'g')
			->substitute('<if-[^>]\+>.\{-1,}\(<endif>\|$\)', '', 'g')
			->substitute('<endif>', '', 'g')
		execute cmd a
	endfor
enddef
command! -nargs=* CmdEach CmdEach(<q-args>)
suite.TestCmdEach = () => {
	CmdEach nmap,vmap xxx yyy<if-nmap>NNN<if-vmap>VVV<endif>zzz
	assert.equals(execute('nmap xxx'), "\n\nn  xxx           yyyNNNzzz")
	assert.equals(execute('vmap xxx'), "\n\nv  xxx           yyyVVVzzz")
	nunmap xxx
	vunmap xxx
}

#}}}

# 'itchyny/vim-cursorword'の簡易CursorHold版 {{{
def HiCursorWord()
	var cword = expand('<cword>')
	if cword !=# '' && cword !=# get(w:, 'cword_match', '')
		if exists('w:cword_match_id')
			silent! matchdelete(w:cword_match_id)
			unlet w:cword_match_id
		endif
		if cword !~ '^[[-` -/:-@{-~]'
			w:cword_match_id = matchadd('CWordMatch', cword, 0)
			w:cword_match = cword
		endif
	endif
enddef
au vimrc CursorHold * HiCursorWord()
au vimrc ColorScheme * hi CWordMatch cterm=underline gui=underline
#}}}

# Insertモードのマッピング {{{
inoremap jjh <C-o>^
inoremap jjl <C-o>$
#}}}

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

var allTest = []
def GetAllTest(A: any = 0, L: any = 0, P: any = 0): list<string>
	if !empty(allTest)
		return allTest
	endif
	for i in range(line('$'))
		var m = getline(i)->matchlist('^def \(Test.*\)()')
		if !empty(m)
			allTest->add(m[1])
		endif
	endfor
	return allTest
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
	var targets = empty(qargs) ? GetAllTest() : qargs->split(' ')
	for target in targets
		execute target .. '()'
	endfor
	g:EchoErrors()
	if empty(v:errors)
		echo 'Success!'
	endif
enddef
command! -nargs=* -complete=customlist,GetAllTest RunTest RunTest(<q-args>)
nnoremap <buffer> <Leader>T <Cmd>call <SID>RunTest()<CR>
nnoremap <buffer> <Leader>t <Cmd>call <SID>RunTestAtCursor()<CR>
#}}}

# vsnip タブで選択 {{{
# タブ区切りのテキスト(ユーザー辞書ファイル)を編集するのに煩わしかった
for cmd in ['inoremap', 'snoremap']
	execute cmd "<expr> <Tab>   vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)' : pumvisible() ? '<C-n>' : '<Tab>'"
	execute cmd "<expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : pumvisible() ? '<C-p>' : '<S-Tab>'"
endfor
#}}}

# vim-eft かなり惜しい…ハイライト好き {{{
Jetpack 'hrsh7th/vim-eft' # fとtを単語境界にするやつ

# eft {{{
nmap ; <Plug>(eft-repeat)
xmap ; <Plug>(eft-repeat)
omap ; <Plug>(eft-repeat)

nmap f <Plug>(eft-f)
xmap f <Plug>(eft-f)
omap f <Plug>(eft-f)
nmap F <Plug>(eft-F)
xmap F <Plug>(eft-F)
omap F <Plug>(eft-F)

nmap t <Plug>(eft-t)
xmap t <Plug>(eft-t)
omap t <Plug>(eft-t)
nmap T <Plug>(eft-T)
xmap T <Plug>(eft-T)
omap T <Plug>(eft-T)
#}}}

# }}}

# もしかしてcmdwinを1行にすれば同じような使い心地になるかも？ {{{
set cmdwinheight=1
def ExpandCmdwin()
	if winheight(0) ==# 1
		resize 7
		normal! ggG
	else
		normal! k
	endif
enddef
au vimrc CmdwinEnter * {
	nnoremap <buffer> k <ScriptCmd>ExpandCmdwin()<CR>
	normal! i
}
#}}}

# yankした文字をポップアップ {{{
def PopupYankText()
	const text = ('📋 ' .. @"[0 : winwidth(0)])
		->substitute('\t', '›', 'g')
		->substitute('\n', '↵', 'g')
	const truncated = text->TruncToDisplayWidth(winwidth(0) - 10)
	const winid = popup_create(truncated, {
		line: 'cursor+1',
		col: 'cursor+1',
		pos: 'topleft',
		padding: [0, 1, 0, 1],
		fixed: true,
		moved: 'any',
		time: 2000,
	})
	win_execute(winid, 'syntax match PmenuExtra /[›↵]\|.\@<=>$/')
enddef
au vimrc TextYankPost * PopupYankText()
#}}}

# TruncToDisplayWidthのテスト {{{
suite.TestTruncToDisplayWidth = () => {
	# minifyしたからテストしづらい！ちくしょう誰がこんなことを…
	#var F = function($'<SNR>{vimrc_sid}_TruncToDisplayWidth')
	const F = function($'<SNR>{vimrc_sid}_E')
	assert.equals(F('123',  3), '123')
	assert.equals(F('1234', 3), '12>')
	assert.equals(F('あいう',  6), 'あいう')
	assert.equals(F('あいう1', 6), 'あい>')
	assert.equals(F('あいう',  5), 'あい>')
	assert.equals(F('', -1), '')
	assert.equals(F('', 0), '')
	assert.equals(F('', 1), '')
	assert.equals(F('>', 1), '>')
	assert.equals(F('あ', 1), '>')
}
# }}}

# 色関係 {{{
# vim-cmdheight0の設定
hi! link CmdHeight0Horiz MoreMsg

# ポータルは水色とオレンジにしたい…
hi Portal_blue ctermbg=45 guibg=#00d7ff
hi Portal_orange ctermbg=214 guibg=#ffaf00

# defaultも悪くない
au vimrc ColorScheme default {
	hi MatchParen ctermbg=7 ctermfg=13 cterm=bold
	hi Search ctermbg=12 ctermfg=7
	hi TODO ctermbg=7 ctermfg=14
	hi String ctermbg=7
	hi SignColumn ctermbg=7
	hi FoldColumn ctermbg=7
	hi WildMenu ctermbg=7
	hi DiffText ctermbg=227
}
# }}}

# CursorHoldでnohlsearchする {{{
# nohlsearchはautocmdでは動かない(:help noh)
# 誰かがautocmd CursorHoldしてれば定期的に<CursorHold>キーがストロークされる
nnoremap <CursorHold> <Cmd>nohlsearch<CR>
# }}}

# ポップアップでメニューをだしてウインドウをクローズ {{{
def CloseMenu()
	popselect#Popup([
		{ shortcut: 'q', label: 'This' },
		{ shortcut: 'j', label: 'Upper' },
		{ shortcut: 'k', label: 'Bellow' },
		{ shortcut: 'h', label: 'Right' },
		{ shortcut: 'l', label: 'Left' },
		{ shortcut: 'o', label: 'Only' },
	], {
		oncomplete: (item) => g:QuitWin(item.shortcut)
	})
enddef
nnoremap <Leader>q <ScriptCmd>CloseMenu()<CR>
# }}}

# 行番号表示をトグルする {{{
export def ToggleNumber()
	if &number
		set nonumber
	elseif &relativenumber
		set number norelativenumber
	else
		set relativenumber
	endif
enddef
#}}}

# vim9skk {{{
g:vim9skk = {
	keymap: {
		enable:   ['<LocalLeader>j'],
		disable:  ['<LocalLeader>a'],
		midasi:   ['Q'],
		midasi_toggle: ['<LocalLeader>j'],
		# 検討中
		# 小さい文字を単独でいれることは無さそうなので「l」を潰しても大丈夫かも？
		# 「:」も悪くないかも？ちょっと打ちづらいか？
		# 「;;」は打ちづらそう
		complete: ['<CR>', '<LocalLeader><Space>', '<LocalLeader><LocalLeader>', 'l', ':'],
		select_top: '.',
	},
	run_on_midasi: true,
}
nnoremap <LocalLeader>j a<Plug>(vim9skk-enable)
nnoremap <LocalLeader><LocalLeader>j i<Plug>(vim9skk-enable)
# AZIKライクな設定とか
au vimrc User Vim9skkInitPre vimrc#vim9skk#ApplySettings()
# インサートモードが終わったらオフにする
au vimrc ModeChanged [ic]:n au SafeState * ++once vim9skk#Disable()
# 見出しの色を見易すく
au vimrc User Vim9skkEnter hi! link vim9skkMidasi PMenuSel
au vimrc User Vim9skkMidasiInput {
	const m = g:vim9skk_midasi
	if m->match('*[っッ]\?[^a-zA-Zっッ]$') !=# -1
		# 送り仮名が確定したら変換を開始
		feedkeys("\<Space>")
	elseif m->match('[^ぁ-わんァ-ヴー]$') !=# -1
		# ひらがなカタカナ以外を入力したら自動で確定
		feedkeys("\<CR>")
	endif
}
# }}}

# multi line statusline {{{
def GetDiffLocStr(): string
	if !exists('w:diffloc')
		return ''
	endif
	var ln = line('.')
	var idx = w:diffloc->indexof((_, v) => v[0] <= ln && ln <= v[1]) + 1
	return $'{!idx ? '-' : idx}/{len(w:diffloc)}'
enddef

def ClearDiffLoc()
	silent! unlet w:difflines
enddef

au vimrc WinEnter,TextChanged,InsertLeave,BufWritePost * ClearDiffLoc()

def g:MyStatusLine(): string
	var stl = '%f'
	if &diff
		if !exists('w:difflines')
			w:diffloc = []
			var start = 0
			var name_bk = ''
			var added = 0
			var changed = 0
			for lnum in range(1, line('$'))
				const name = diff_hlID(lnum, 1)->synIDattr('name')
				if name ==# 'DiffAdd'
					added += 1
				elseif name ==# 'DiffChange'
					changed += 1
				endif
				if name_bk ==# name
					continue
				endif
				name_bk = name
				if !!start
					w:diffloc->add([start, lnum - 1])
				endif
				start = name ==# 'DiffAdd' || name ==# 'DiffChange' ? lnum : 0
			endfor
			if !!start
				w:diffloc->add([start, line('$')])
			endif
			w:difflines = $'Added:{added},Changed:{changed}'
			w:difflocstr = GetDiffLocStr()
		endif
		stl = $'{w:difflines}%={w:difflocstr}%@{stl}'
		au vimrc CursorMoved * w:difflocstr = GetDiffLocStr()
	endif
	return stl
enddef
def ToggleZen()
	if zenmode#Toggle()
		# statusline表示なし
		return
	elseif !exists('g:has_mulitilinestatusline') # ←.vimrc_localで設定
		# multi line statusline表示なし
		return
	else
		# statusline表示あり
		set stlo=maxheight:2
		set stl=%{%g:MyStatusLine()%}
	endif
enddef
noremap ZZ <ScriptCmd>ToggleZen()<CR>
au vimrc WinResized * redrawstatus
# }}}

# ビジュアルモード {{{
xnoremap <script> <expr> v matchstr("vV\<C-v>\<ESC>", mode() .. '\@<=.')
xnoremap <expr> h mode() ==# 'V' ? '<Esc>h' : 'h'
xnoremap <expr> l mode() ==# 'V' ? '<Esc>l' : 'l'
# }}}
