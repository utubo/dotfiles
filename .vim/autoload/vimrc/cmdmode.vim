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
cno <expr> <Space> A()
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
def C(a: string = '[=<>!~#]\+')
B(
$'\(.*\S\)\(\s*{a}\s*\)\(\S.*\)',
'\3\2\1'
)
enddef
com! -range=% -nargs=? SwapExpr C(<f-args>)
var m = {
win: 0,
timer: 0,
blink: false,
blinktimer: 0,
curpos: 0,
gcr: '',
msghl: [],
offset: 0,
}
export def Popup()
if m.win !=# 0
echoerr 'cmdlineのポップアップが変なタイミングで実行された多分設定がおかしい'
return
endif
m.msghl = 'MsgArea'->hlget()
const a = 'Normal'->hlget(true)[0]
var b = 'MsgArea'->hlget(true)[0]
b = b->copy()->extend({
ctermfg: get(b, 'ctermbg', get(a, 'ctermbg', 'NONE')),
guifg: get(b, 'guibg', get(a, 'guibg', 'NONE')),
cleared: false,
})
[b]->hlset()
m.win = popup_create('  ', { col: 'cursor-1', line: 'cursor+1', zindex: 2 })
setbufvar(winbufnr(m.win), '&filetype', 'vim')
win_execute(m.win, $'syntax match PMenuKind /^./')
set t_ve=
if !m.gcr
m.gcr = &guicursor
endif
set guicursor=c:CursorTransparent
['Cursor'->hlget()[0]->copy()->extend({ name: 'vimrcCmdlineCursor' })]->hlset()
aug vimrc_cmdline_popup
au!
au ModeChanged c:[^c] D()
au VimLeavePre * I()
aug END
J()
m.blinktimer = timer_start(500, vimrc#cmdmode#BlinkPopupCursor, { repeat: -1 })
m.updatetimer = timer_start(16, vimrc#cmdmode#UpdatePopup, { repeat: -1 })
enddef
def D()
aug vimrc_cmdline_popup
au!
aug END
I()
timer_stop(m.updatetimer)
m.updatetimer = 0
timer_stop(m.blinktimer)
m.blinktimer = 0
popup_close(m.win)
m.win = 0
BA()
hi MsgArea None
m.msghl->hlset()
sil! cu <Tab>
redraw
enddef
export def UpdatePopup(a: number)
if m.win ==# 0 || mode() !=# 'c' || popup_list()->index(m.win) ==# -1
D()
if mode() ==# 'c'
feedkeys("\<Esc>", 'nt')
endif
return
endif
const b = getcmdtype() .. getcmdprompt() .. getcmdline() .. ' '
if G() < strdisplaywidth(b)
D()
else
popup_settext(m.win, b)
E()
endif
redraw
enddef
def E()
win_execute(m.win, 'call clearmatches()')
var c = F()
if c !=# m.curpos
m.blink = true
m.curpos = c
endif
if m.blink
win_execute(m.win, $'call matchadd("vimrcCmdlineCursor", "\\%1l\\%{c}v.")')
endif
enddef
def F(): number
return getcmdscreenpos() - H()
enddef
def G(): number
return &columns - H()
enddef
def H(): number
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
export def BlinkPopupCursor(a: number)
m.blink = !m.blink
enddef
def I()
if !!m.gcr
&guicursor = m.gcr
m.gcr = ''
endif
set t_ve&
enddef
var o = 0
var q = ''
def J()
cno <Tab> <ScriptCmd>vimrc#cmdmode#PopupPum()<CR>
enddef
export def PumKeyDown(a: number, k: string): bool
const i = getwininfo(o)[0]
const l = getcurpos(o)[1]
if k ==# "\<Tab>" || k ==# "\<C-n>"
const b = i.bufnr->getbufinfo()[0].linecount
noautocmd win_execute(o, $'normal! { l < b ? 'j' : 'gg' }')
elseif k ==# "\<S-Tab>" || k ==# "\<C-p>"
noautocmd win_execute(o, $'normal! { l <= 1 ? 'G' : 'k' }')
else
BA()
J()
return false
endif
setcmdline(q .. i.bufnr->getbufline(getcurpos(o)[1])[0])
redraw
return true
enddef
export def PopupPum()
cu <Tab>
BA()
q = getcmdline()
const c = getcompletion(q, 'cmdline')
if !c
return
endif
q = q->substitute('\S*$', '', '')
var p = screenpos(0, line('.'), col('.'))
var a = &lines
var b = 'topleft'
if p.row < &lines / 2
p.row += 2
a -= p.row
else
p.row
a = p.row
b = 'botleft'
endif
o = popup_create(c, {
zindex: 3,
wrap: 0,
cursorline: 1,
padding: [0, 1, 0, 1],
mapping: 1,
filter: 'vimrc#cmdmode#PumKeyDown',
col: max([2, p.col]) + strdisplaywidth(q) - 1,
line: p.row,
maxheight: a,
pos: b,
})
setcmdline(q .. getbufline(winbufnr(o), 1)[0])
enddef
def BA()
if !!o
popup_close(o)
o = 0
endif
enddef
export def ForVim9skk(a: any): any
if m.win !=# 0
var c = popup_getpos(m.win)
a.col = c.col + F() - 1
a.line = c.line
endif
return a
enddef
g:vim9skkp.getcurpos = vimrc#cmdmode#ForVim9skk
au vimrc CmdlineChanged * {
const c = getcmdline()
const w = G()
const h = c->strdisplaywidth() / w + 1
&cmdheight = h
}
com! -nargs=+ Echo au SafeStateAgain * ++once echo <args>
export def ApplySettings()
com! -nargs=1 -complete=dir PopSelectDir expand(<f-args>)->fnamemodify(':p')->popselect#dir#Popup()
cno <LocalLeader>(cancel) <Cmd>call feedkeys("\e", 'nt')<CR>
cno <LocalLeader>(ok) <CR>
RLK cmap <LocalLeader> k <C-p>
RLK cmap <LocalLeader> K <C-n>
cno <LocalLeader>r <C-r>
cno <expr> <LocalLeader>rr trim()->substitute('\n', ' \| ', 'g')
cno <expr> <LocalLeader>re escape(@", '~^$.*?/\[]')->substitute('\n', '\\n', 'g')
enddef
