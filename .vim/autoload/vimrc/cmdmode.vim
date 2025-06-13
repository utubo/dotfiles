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
var l = {
win: 0,
timer: 0,
blink: false,
blinktimer: 0,
curpos: 0,
curhl: [],
msghl: [],
}
export def Popup()
if l.win !=# 0
echoerr 'cmdlineのポップアップが変なタイミングで実行された多分設定がおかしい'
return
endif
l.msghl = 'MsgArea'->hlget()
const a = 'Normal'->hlget()[0]
var b = l.msghl[0]->copy()->extend({
ctermfg: get(l.msghl[0], 'ctermbg', get(a, 'ctermbg', 'NONE')),
guifg: get(l.msghl[0], 'guibg', get(a, 'guibg', 'NONE')),
cleared: false,
})
[b]->hlset()
l.win = popup_create('  ', { col: 'cursor-1', line: 'cursor+1', zindex: 2 })
setbufvar(winbufnr(l.win), '&filetype', 'vim')
win_execute(l.win, $'syntax match PMenuKind /^./')
set t_ve=
l.curhl = 'Cursor'->hlget()
[l.curhl[0]->copy()->extend({ name: 'vimrcCmdlineCursor' })]->hlset()
hi Cursor NONE
aug vimrc_cmdline_popup
au!
au ModeChanged c:[^c] D()
au VimLeavePre * F()
aug END
l.blinktimer = timer_start(500, vimrc#cmdmode#BlinkPopupCursor, { repeat: -1 })
l.updatetimer = timer_start(16, vimrc#cmdmode#UpdatePopup, { repeat: -1 })
enddef
def D()
aug vimrc_cmdline_popup
au!
aug END
F()
timer_stop(l.updatetimer)
l.updatetimer = 0
timer_stop(l.blinktimer)
l.blinktimer = 0
popup_close(l.win)
l.win = 0
hi MsgArea None
l.msghl->hlset()
redraw
enddef
export def UpdatePopup(a: number)
if l.win ==# 0 || mode() !=# 'c' || popup_list()->index(l.win) ==# -1
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
popup_settext(l.win, b)
E()
endif
redraw
enddef
def E()
win_execute(l.win, 'call clearmatches()')
var c = getcmdscreenpos()
if c !=# l.curpos
l.blink = true
l.curpos = c
endif
if l.blink
win_execute(l.win, $'echo matchadd("vimrcCmdlineCursor", "\\%1l\\%{c}v.")')
endif
enddef
export def BlinkPopupCursor(a: number)
l.blink = !l.blink
enddef
def F()
hlset(l.curhl)
set t_ve&
enddef
export def ForVim9skk(a: any): any
if l.win !=# 0
var c = popup_getpos(l.win)
a.col += c.col - 1
a.line += c.line - &lines
endif
return a
enddef
g:vim9skk.change_popuppos = vimrc#cmdmode#ForVim9skk
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
