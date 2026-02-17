vim9script
def A(): string
return {
cs: "\<C-u>colorscheme ",
sb: "\<C-u>set background=\<Tab>\<Tab>",
mv: "\<C-u>MoveFile ",
vg: "\<C-u>VimGrep ",
pd: "\<C-u>PopSelectDir ",
th: "\<C-u>tab help ",
'9': "\<C-u>vim9cmd ",
}->get(getcmdline(), ' ')
enddef
cm <expr> <Space> A()
export def MoveFile(a: string)
const b = expand('%')
const c = expand(a)
if ! empty(b) && filereadable(b)
if filereadable(c)
echoh Error
ec $'file "{a}" already exists.'
echoh None
return
endif
rename(b, c)
endif
exe 'saveas!' c
edit
enddef
com! -nargs=1 -complete=file MoveFile vimrc#cmdmode#MoveFile(<f-args>)
com! -nargs=+ -complete=dir VimGrep vimrc#myutil#VimGrep(<f-args>)
def B(
pat: string, sub: string, flags: string = '')
normal! gv
for p in getregionpos(getpos('v'), getpos('.'))
const a = p[0][0]
const b = p[0][1]
const c = getbufline(a, b)[0]
const f = charidx(c, p[0][2] - 1)
const t = charidx(c, p[1][2] - 1)
const d = c[f : t]->substitute(pat, sub, flags)
setbufline(a, b, c[0 : f - 1] .. d .. c[t + 1 :])
endfor
enddef
def D(a: string = '[=<>!~#]\+')
B(
$'\(.*\S\)\(\s*{a}\s*\)\(\S.*\)',
'\3\2\1'
)
enddef
com! -range=% -nargs=? SwapExpr D(<f-args>)
var o = {
owner: 0,
win: 0,
timer: 0,
blink: false,
blinktimer: 0,
curpos: 0,
gcr: '',
hlback: {},
offset: 0,
visual: 0,
shade: 0,
}
export def PopupMapping()
Popup()
enddef
export def Popup(a: number = 0)
if o.win !=# 0
G()
echow 'cmdlineのポップアップが変なタイミングで実行された多分設定がおかしい'
return
endif
o.owner = win_getid()
for h in ['MsgArea', 'CursorLine', 'Folded']
o.hlback[h] = h->hlget()
endfor
o.shade = matchadd('NonText', '.')
hi! link Folded NonText
E()
hi CursorLine None
const b = 'Normal'->hlget(true)[0]
var d = 'MsgArea'->hlget(true)[0]
d = d->copy()->extend({
ctermfg: get(d, 'ctermbg', get(b, 'ctermbg', 'NONE')),
guifg: get(d, 'guibg', get(b, 'guibg', 'NONE')),
cleared: false,
})
[d]->hlset()
o.win = popup_create('  ', { col: o.col, line: o.line, zindex: 2 })
setbufvar(winbufnr(o.win), '&filetype', 'vim')
win_execute(o.win, $'syntax match PMenuKind /^./')
set t_ve=
if !o.gcr
o.gcr = &guicursor
endif
set guicursor=c:CursorTransparent
['Cursor'->hlget()[0]->copy()->extend({ name: 'vimrcCmdlineCursor' })]->hlset()
o.curpos = 0
BB()
aug vimrc_cmdline_popup
au!
au ModeChanged c:[^c] G()
au VimLeavePre * BC()
aug END
o.updatetimer = timer_start(16, vimrc#cmdmode#UpdatePopup, { repeat: -1 })
BD()
g:previewcmd.popup_args = { col: o.col, line: o.line - 1 }
enddef
def E()
const m = mode()
if m ==# 'V' || m ==# 'v' || m ==# "\<C-v>"
var p = F()
o.visual = matchaddpos('Visual', p)
o.col = p->copy()->map((i, v) => screenpos(0, v[0], v[1]).col)->min()
o.line = p->copy()->map((i, v) => screenpos(0, v[0], v[1]).row)->max() + 1
else
o.visual = 0
o.col = 'cursor-1'
o.line = screenpos(0, line('.'), col('.')).row + 1
endif
enddef
def F(): list<any>
var a = []
for p in getregionpos(getpos('.'), getpos('v'), { type: mode() })
const s = p[0]
const e = p[1]
var b = 0
if s[1] !=# e[1]
b = getline(s[1])->len() - s[2]
for l in range(s[1] + 1, e[1] - 1)
b += getline(l)->len()
endfor
b += e[2]
elseif s[2] ==# e[2]
continue
else
b = e[2] - s[2] + 1
endif
a += [[s[1], s[2], b]]
endfor
return a
enddef
def G()
aug vimrc_cmdline_popup
au!
aug END
sil! matchdelete(o.visual, o.owner)
sil! matchdelete(o.shade, o.owner)
BC()
timer_stop(o.updatetimer)
o.updatetimer = 0
timer_stop(o.blinktimer)
o.blinktimer = 0
popup_close(o.win)
o.win = 0
o.owner = 0
BE()
for h in o.hlback->values()
exe $'hi {h[0].name} None'
h->hlset()
endfor
sil! cu <Tab>
g:previewcmd.popup_args = {}
redraw
enddef
export def UpdatePopup(a: number)
if o.win ==# 0 || mode() !=# 'c' || popup_list()->index(o.win) ==# -1
G()
if mode() ==# 'c'
feedkeys("\<Esc>", 'nt')
endif
return
endif
const b = getcmdtype() .. getcmdprompt() .. getcmdline() .. ' '
if J() < strdisplaywidth(b)
G()
else
popup_settext(o.win, b)
H()
endif
redraw
enddef
def H()
var c = I()
if c ==# o.curpos
return
endif
o.curpos = c
win_execute(o.win, 'call clearmatches()')
win_execute(o.win, $'call matchadd("vimrcCmdlineCursor", "\\%1l\\%{c}v.")')
o.blink = false
BB()
enddef
def I(): number
return getcmdscreenpos() - BA()
enddef
def J(): number
return &columns - BA()
enddef
def BA(): number
if !&showtabpanel
return 0
endif
if &showtabpanel ==# 1 && tabpagenr('$') ==# 1
return 0
endif
if &tabpanelopt =~ 'align:right'
return 0
endif
const c = &tabpanelopt->matchstr('\(columns:\)\@<=\d\+')->str2nr() ?? 20
return &columns < c ? 0 : c
enddef
def BB()
if !!o.blinktimer
timer_stop(o.blinktimer)
endif
o.blinktimer = timer_start(500, vimrc#cmdmode#BlinkPopupCursor, { repeat: -1 })
o.blink = true
BlinkPopupCursor(0)
enddef
export def BlinkPopupCursor(a: number)
if o.blink
hi! link vimrcCmdlineCursor Cursor
else
hi! link vimrcCmdlineCursor None
endif
o.blink = !o.blink
enddef
def BC()
if !!o.gcr
&guicursor = o.gcr
o.gcr = ''
endif
set t_ve&
enddef
var q = 0
var lk = ''
def BD()
cno <Tab> <ScriptCmd>vimrc#cmdmode#PopupPum()<CR>
enddef
export def PumKeyDown(a: number, k: string): bool
const i = getwininfo(q)[0]
const l = getcurpos(q)[1]
if k ==# "\<Tab>" || k ==# "\<C-n>"
const b = i.bufnr->getbufinfo()[0].linecount
noautocmd win_execute(q, $'normal! { l < b ? 'j' : 'gg' }')
elseif k ==# "\<S-Tab>" || k ==# "\<C-p>"
noautocmd win_execute(q, $'normal! { l <= 1 ? 'G' : 'k' }')
else
BE()
BD()
return false
endif
setcmdline(lk .. i.bufnr->getbufline(getcurpos(q)[1])[0])
redraw
return true
enddef
export def PopupPum()
cu <Tab>
BE()
const a = getcmdline()
const c = getcompletion(a, 'cmdline')
if !c
return
endif
lk = a->substitute('[^ =]*$', '', '')
var p = screenpos(0, line('.'), col('.'))
var b = &lines
var d = 'topleft'
if p.row < &lines / 2
p.row += 2
b -= p.row
else
p.row
b = p.row
d = 'botleft'
endif
q = popup_create(c, {
zindex: 3,
wrap: 0,
cursorline: 1,
padding: [0, 1, 0, 1],
mapping: 1,
filter: 'vimrc#cmdmode#PumKeyDown',
col: max([2, p.col]) + strdisplaywidth(lk) - 1,
line: p.row,
maxheight: b,
pos: d,
})
setcmdline(lk .. getbufline(winbufnr(q), 1)[0])
g:previewcmd.enable = false
enddef
def BE()
if !!q
popup_close(q)
q = 0
endif
g:previewcmd.enable = true
enddef
export def ForVim9skk(a: any): any
if o.win !=# 0
var c = popup_getpos(o.win)
a.col = c.col + I() - 1
a.line = c.line
endif
return a
enddef
g:vim9skkp = get(g:, 'vim9skkp', {})
g:vim9skkp.getcurpos = vimrc#cmdmode#ForVim9skk
au vimrc CmdlineChanged * {
const c = getcmdline()
const w = J()
const h = c->strdisplaywidth() / w + 1
&cmdheight = h
}
com! -nargs=+ Echo au SafeStateAgain * ++once echo <args>
g:previewcmd = { enable: true }
export def ApplySettings()
com! -nargs=1 -complete=dir PopSelectDir expand(<f-args>)->fnamemodify(':p')->popselect#dir#Popup()
cno <LocalLeader>(cancel) <Cmd>call feedkeys("\e", 'nt')<CR>
cno <LocalLeader>(ok) <CR>
SubMode cmdhistory cmap <LocalLeader> k <C-p>
SubMode cmdhistory cmap <LocalLeader> K <C-n>
cno <LocalLeader>r <C-r>
cno <expr> <LocalLeader>rr trim()->substitute('\n', ' \| ', 'g')
cno <expr> <LocalLeader>re escape(@", '~^$.*?/\[]')->substitute('\n', '\\n', 'g')
enddef
