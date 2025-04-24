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
var m = 0
var n = 0
export def Popup()
m = popup_create('  ', { col: 'cursor-1', line: 'cursor+1', })
setbufvar(winbufnr(m), '&filetype', 'vim')
win_execute(m, $'syntax match PMenuKind /^./')
aug vimrc_cmdline_popup
au!
au ModeChanged c:[^c] B()
aug END
n = timer_start(16, vimrc#cmdline#RedrawPopup, { repeat: -1 })
enddef
def B()
aug vimrc_cmdline_popup
au!
aug END
if n !=# 0
timer_stop(n)
n = 0
endif
if m !=# 0
popup_close(m)
m = 0
endif
enddef
export def RedrawPopup(a: number)
if m ==# 0
return
endif
if popup_list()->index(m) ==# -1
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
popup_settext(m, b)
win_execute(m, $'call clearmatches()')
const c = getcmdscreenpos()
win_execute(m, $'echo matchadd("Cursor", "\\%1l\\%{c}v.")')
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
