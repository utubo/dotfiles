vim9script

g:vim9skkp = get(g:, 'vim9skkp', {})->extend({
	keymap: {
		# 候補を閉じるのはSKK的には<C-g>だが、Vim的には<C-e>
		cancel: ["\<C-g>", "\<C-e>"],
		# <CR>は遠いのでlで確定(;は<LocalLeader>に割り当て)
		commit: ["\<CR>", 'l'],
		# SKK的にはxで前候補だが、xは小文字を入力したいので<S-Tab>だけにしておく
	   prev: ["\<S-Tab>"],
	},
	mode_display: 'none',
	sticky_lock: true,
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
		# ky: 'キー', # これだと「きゅ」が入力できない
		# 記号
		'z*': '※', 'v.': '︙',
		'z.': '…', 'z{': '【', 'z}': '】',
		zl: '→', zh: '←', zj: '↓', zk: '↑',
		'[': '「', ']': '」',
		# Vim用語
		bf: 'バッファ',
		mp: 'マッピング',
		km: 'キーマッピング',
		vp: 'プラグイン',
	},
})

export def LazyLoad()
enddef

