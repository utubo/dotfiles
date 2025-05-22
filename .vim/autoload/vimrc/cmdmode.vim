vim9script
def A(): string
return {
cs: "\<C-u>colorscheme ",
sb: "\<C-u>set background=\<Tab>",
mv: "\<C-u>MoveFile ",
pd: "\<C-u>PopSelectDir ",
tb: "\<C-u>tab help ",
}->get(getcmdline(), ' ')
enddef
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
au ModeChanged c:[^c] B()
au VimLeavePre * D()
aug END
l.blinktimer = timer_start(500, vimrc#cmdmode#BlinkPopupCursor, { repeat: -1 })
l.updatetimer = timer_start(16, vimrc#cmdmode#UpdatePopup, { repeat: -1 })
enddef
def B()
aug vimrc_cmdline_popup
au!
aug END
D()
timer_stop(l.updatetimer)
l.updatetimer = 0
timer_stop(l.blinktimer)
l.blinktimer = 0
popup_close(l.win)
l.win = 0
l.msghl->hlset()
redraw
enddef
export def UpdatePopup(a: number)
if l.win ==# 0 || mode() !=# 'c' || popup_list()->index(l.win) ==# -1
B()
if mode() ==# 'c'
feedkeys("\<Esc>", 'nt')
endif
return
endif
const b = getcmdtype() .. getcmdline() .. getcmdprompt() .. ' '
if &columns < strdisplaywidth(b)
B()
redraw
return
endif
popup_settext(l.win, b)
C()
enddef
def C()
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
def D()
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
cno <expr> <Space> A()
com! -nargs=1 -complete=file MoveFile vimrc#cmdmode#MoveFile(<f-args>)
com! -nargs=1 -complete=dir PopSelectDir popselect#dir#Popup(<f-args>)
cno <LocalLeader>(cancel) <Cmd>call feedkeys("\e", 'nt')<CR>
cno <LocalLeader>(ok) <CR>
RLK cmap <LocalLeader> k <C-p>
RLK cmap <LocalLeader> K <C-n>
cno <LocalLeader>r <C-r>
cno <expr> <LocalLeader>rr trim()->substitute('\n', ' \| ', 'g')
cno <expr> <LocalLeader>re escape(@", '~^$.*?/\[]')->substitute('\n', '\\n', 'g')
enddef
