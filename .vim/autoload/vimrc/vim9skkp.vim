vim9script
g:vim9skkp = get(g:, 'vim9skkp', {})->extend({
keymap: {
cancel: ["\<C-g>", "\<C-e>"],
commit: ["\<CR>", "\<C-y>", 'l'],
prev: ["\<S-Tab>"],
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
fx: '修正',
dl: '削除',
chg: '変更',
tk: '追加',
skk: 'SKK',
bg: 'バグ',
cm: 'コメント',
cnf: '設定',
wn: 'ウィンドウ',
ml: 'メール',
'z*': '※', 'v.': '︙', 'z@': '＠',
'z{': '【', 'z}': '】',
'zb': '■', 'zd': '◆', 'zr': '□', 'zc': '●', 'zw': '○',
'zs': '★',
bf: 'バッファ',
mp: 'マッピング',
km: 'キーマッピング',
vp: 'プラグイン',
},
})
def A()
if !!g:vim9skkp_status.midasi_text
g:vim9skkp.keymap.sticky_shift = [';']
g:vim9skkp.keymap.commit += [';']
else
g:vim9skkp.keymap.sticky_shift = []
g:vim9skkp.keymap.commit = g:vim9skkp.keymap.commit->filter((_, v) => v !=# ';')
endif
enddef
aug vimrc-vim9skkp
au!
au User Vim9skkpStatusChanged A()
au User Vim9skkpMidasiTextChanged A()
aug END
export def LazyLoad()
enddef
