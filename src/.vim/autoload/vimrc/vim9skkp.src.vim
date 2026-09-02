vim9script

g:vim9skkp = get(g:, 'vim9skkp', {})->extend({
	keymap: {
		# 候補を閉じるのはSKK的には<C-g>だが、Vim的には<C-e>
		cancel: ["\<C-g>", "\<C-e>"],
		# Vim的には<C-y>、
		# 指が近いlでも確定(;は<LocalLeader>に割り当て済み)
		commit: ["\<CR>", "\<C-y>", 'l'],
		# SKK的にはxで前候補だが、xは小文字を入力したい
		prev: ["\<S-Tab>", "\<C-p>"],
		next: ["\<Tab>", "\<C-n>"],
		predict: ["\<C-n>"],
	},
	mode_display: 'popup',
	sticky_lock: true,
	predict: false,
	cands_popup_options: {
		borderchars: ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
		border: [1, 1, 1, 1],
	},
	roman_abbrev: {
		ds: 'です',
		ms: 'ます',
		sr: 'する',
		st: 'して',
		smt: 'しました',
		ks: 'ください',
		dg: 'ですが、',
		mg: 'ますが、',
		# 頻出単語
		fx: '修正',
		dl: '削除',
		chg: '変更',
		tk: '追加', # 'a'は'あ'なので'ad'にはできない…
		skk: 'SKK',
		bg: 'バグ',
		cm: 'コメント',
		cnf: '設定',
		wn: 'ウィンドウ',
		ml: 'メール',
		# ky: 'キー', # これだと「きゅ」が入力できない
		# 記号
		'z*': '※', 'v.': '︙', 'z@': '＠',
		'z{': '【', 'z}': '】',
		'zb': '■', 'zd': '◆', 'zr': '□', 'zc': '●', 'zw': '○',
		'zs': '★',
		# Vim用語
		bf: 'バッファ',
		mp: 'マッピング',
		km: 'キーマッピング',
		vp: 'プラグイン',
	},
})

def OnVim9SkkpStatusChanged()
	if !!g:vim9skkp_status.midasi_text
		g:vim9skkp.keymap.sticky_shift = [';']
		g:vim9skkp.keymap.commit += [';']
	else
		g:vim9skkp.keymap.sticky_shift = []
		g:vim9skkp.keymap.commit = g:vim9skkp.keymap.commit->filter((_, v) => v !=# ';')
	endif
enddef

augroup vimrc-vim9skkp
	au!
	au User Vim9skkpStatusChanged OnVim9SkkpStatusChanged()
	au User Vim9skkpMidasiTextChanged OnVim9SkkpStatusChanged()
augroup END

export def LazyLoad()
enddef

