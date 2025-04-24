vim9script
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
def A(): string
return {
cs: "\<C-u>colorscheme ",
sb: "\<C-u>set background=\<Tab>",
mv: "\<C-u>MoveFile ",
}->get(getcmdline(), ' ')
enddef
var m = {
win: 0,
timer: 0,
cover: 0,
blink: false,
blinktimer: 0,
curpos: 0,
curhl: [],
}
export def Popup()
if m.win !=# 0
echoerr 'cmdlineのポップアップが変なタイミングで実行された多分設定がおかしい'
return
endif
m.cover = popup_create('', { zindex: 1 })
setwinvar(m.cover, '&wincolor', 'Normal')
E()
m.win = popup_create('  ', { col: 'cursor-1', line: 'cursor+1', zindex: 2 })
setbufvar(winbufnr(m.win), '&filetype', 'vim')
win_execute(m.win, $'syntax match PMenuKind /^./')
set t_ve=
m.curhl = 'Cursor'->hlget()
[m.curhl[0]->copy()->extend({ name: 'vimrcCmdlineCursor' })]->hlset()
hi Cursor NONE
aug vimrc_cmdline_popup
au!
au ModeChanged c:[^c] B()
au WinScrolled * E()
au VimLeavePre * D()
aug END
m.blinktimer = timer_start(500, vimrc#cmdline#BlinkPopupCursor, { repeat: -1 })
m.updatetimer = timer_start(16, vimrc#cmdline#UpdatePopup, { repeat: -1 })
enddef
def B()
aug vimrc_cmdline_popup
au!
aug END
D()
timer_stop(m.updatetimer)
m.updatetimer = 0
timer_stop(m.blinktimer)
m.blinktimer = 0
popup_close(m.win)
m.win = 0
popup_close(m.cover)
m.cover = 0
redraw
enddef
export def UpdatePopup(a: number)
if m.win ==# 0 || mode() !=# 'c' || popup_list()->index(m.win) ==# -1
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
popup_settext(m.win, b)
C()
enddef
def C()
win_execute(m.win, 'call clearmatches()')
var c = getcmdscreenpos()
if c !=# m.curpos
m.blink = true
m.curpos = c
endif
if m.blink
win_execute(m.win, $'echo matchadd("vimrcCmdlineCursor", "\\%1l\\%{c}v.")')
endif
enddef
export def BlinkPopupCursor(a: number)
m.blink = !m.blink
enddef
def D()
hlset(m.curhl)
set t_ve&
enddef
def E()
popup_move(m.cover, { col: 1, line: &lines, zindex: 1 })
popup_settext(m.cover, repeat(' ', &columns))
enddef
export def ApplySettings()
cno jj <CR>
cno jk <C-c>
cno <A-h> <Left>
cno <A-j> <Up>
cno <A-k> <Down>
cno <A-l> <Right>
cno ;r <C-r>
cno <expr> ;rr trim(@")->substitute('\n', ' \| ', 'g')
cno <expr> ;re escape(@", '~^$.*?/\[]')->substitute('\n', '\\n', 'g')
cno <expr> <Space> A()
com! -nargs=1 -complete=file MoveFile vimrc#cmdline#MoveFile(<f-args>)
enddef
