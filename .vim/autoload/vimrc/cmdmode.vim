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
curhl: [],
msghl: [],
}
export def Popup()
if m.win !=# 0
echoerr 'cmdlineのポップアップが変なタイミングで実行された多分設定がおかしい'
return
endif
m.msghl = 'MsgArea'->hlget()
const a = 'Normal'->hlget()[0]
var b = m.msghl[0]->copy()->extend({
ctermfg: get(m.msghl[0], 'ctermbg', get(a, 'ctermbg', 'NONE')),
guifg: get(m.msghl[0], 'guibg', get(a, 'guibg', 'NONE')),
cleared: false,
})
[b]->hlset()
m.win = popup_create('  ', { col: 'cursor-1', line: 'cursor+1', zindex: 2 })
setbufvar(winbufnr(m.win), '&filetype', 'vim')
win_execute(m.win, $'syntax match PMenuKind /^./')
set t_ve=
m.curhl = 'Cursor'->hlget()
[m.curhl[0]->copy()->extend({ name: 'vimrcCmdlineCursor' })]->hlset()
hi Cursor NONE
aug vimrc_cmdline_popup
au!
au ModeChanged c:[^c] D()
au VimLeavePre * F()
aug END
G()
m.blinktimer = timer_start(500, vimrc#cmdmode#BlinkPopupCursor, { repeat: -1 })
m.updatetimer = timer_start(16, vimrc#cmdmode#UpdatePopup, { repeat: -1 })
enddef
def D()
aug vimrc_cmdline_popup
au!
aug END
F()
timer_stop(m.updatetimer)
m.updatetimer = 0
timer_stop(m.blinktimer)
m.blinktimer = 0
popup_close(m.win)
m.win = 0
H()
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
const b = getcmdtype() .. getcmdline() .. getcmdprompt() .. ' '
if &columns < strdisplaywidth(b)
D()
else
popup_settext(m.win, b)
E()
endif
redraw
enddef
def E()
win_execute(m.win, 'call clearmatches()')
var c = getcmdscreenpos()
if c !=# m.curpos
m.blink = true
m.curpos = c
endif
if m.blink
win_execute(m.win, $'call matchadd("vimrcCmdlineCursor", "\\%1l\\%{c}v.")')
endif
enddef
export def BlinkPopupCursor(a: number)
m.blink = !m.blink
enddef
def F()
hlset(m.curhl)
set t_ve&
enddef
var o = 0
var q = ''
def G()
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
H()
G()
return false
endif
setcmdline(q .. i.bufnr->getbufline(getcurpos(o)[1])[0])
redraw
return true
enddef
export def PopupPum()
cu <Tab>
H()
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
def H()
if !!o
popup_close(o)
o = 0
endif
enddef
export def ForVim9skk(a: any): any
if m.win !=# 0
var c = popup_getpos(m.win)
a.col += c.col - 1
a.line += c.line - &lines
endif
return a
enddef
g:vim9skk.getcurpos = vimrc#cmdmode#ForVim9skk
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
