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
export def ApplySettings()
cno jj <CR>
cno kk <C-c>
cno <A-h> <Left>
cno <A-j> <Up>
cno <A-k> <Down>
cno <A-l> <Right>
cno <expr> <C-r><C-r> trim(@")->substitute('\n', ' \| ', 'g')
cno <expr> <C-r><C-e> escape(@", '~^$.*?/\[]')->substitute('\n', '\\n', 'g')
cno <expr> <Space> A()
com! -nargs=1 -complete=file MoveFile vimrc#cmdline#MoveFile(<f-args>)
enddef
