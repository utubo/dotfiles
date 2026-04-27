vim9script
g:vim9skkp = get(g:, 'vim9skkp', {})->extend({
keymap: {
cancel: ["\<C-g>", "\<C-e>"],
commit: ["\<CR>", 'l'],
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
fx: '修正',
dl: '削除',
chg: '変更',
tk: '追加',
skk: 'SKK',
bg: 'バグ',
cm: 'コメント',
cnf: '設定',
wn: 'ウィンドウ',
'z*': '※', 'v.': '︙',
'z.': '…', 'z{': '【', 'z}': '】',
zl: '→', zh: '←', zj: '↓', zk: '↑',
'[': '「', ']': '」',
bf: 'バッファ',
mp: 'マッピング',
km: 'キーマッピング',
vp: 'プラグイン',
},
})
export def LazyLoad()
enddef
