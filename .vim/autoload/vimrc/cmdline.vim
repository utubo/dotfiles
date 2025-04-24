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
}
export def Popup()
m.cover = popup_create('', { zindex: 1 })
setwinvar(m.cover, '&wincolor', 'Normal')
D()
m.win = popup_create('  ', { col: 'cursor-1', line: 'cursor+1', zindex: 2 })
setbufvar(winbufnr(m.win), '&filetype', 'vim')
win_execute(m.win, $'syntax match PMenuKind /^./')
set t_ve=
aug vimrc_cmdline_popup
au!
au ModeChanged c:[^c] B()
au WinScrolled * D()
au VimLeavePre * set t_ve&
aug END
m.blinktimer = timer_start(500, vimrc#cmdline#BlinkPopupCursor, { repeat: -1 })
m.timer = timer_start(16, vimrc#cmdline#UpdatePopup, { repeat: -1 })
enddef
def B()
aug vimrc_cmdline_popup
au!
aug END
if m.timer !=# 0
timer_stop(m.timer)
m.timer = 0
endif
if m.blinktimer !=# 0
timer_stop(m.blinktimer)
m.blinktimer = 0
endif
if m.win !=# 0
popup_close(m.win)
m.win = 0
endif
if m.cover !=# 0
popup_close(m.cover)
m.cover = 0
redraw
endif
set t_ve&
enddef
export def UpdatePopup(a: number)
if m.win ==# 0
return
endif
if popup_list()->index(m.win) ==# -1
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
win_execute(m.win, $'echo matchadd("Cursor", "\\%1l\\%{c}v.")')
endif
enddef
export def BlinkPopupCursor(a: number)
m.blink = !m.blink
enddef
def D()
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
