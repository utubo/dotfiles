vim9script

g:vim9skkp = get(g:, 'vim9skkp', {})->extend({
	keymap: {
		commit: ["\<CR>", 'l'],
		cancel: ["\<C-g>", "\<C-e>"],
	},
	mode_display: 'none',
	sticky_lock: true,
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

