vim9script
export def CmdlineAutoSlash(c: string): string
if getcmdtype() !=# ':'
return c
endif
const a = getcmdline()
if getcmdpos() !=# a->len() + 1 || a =~# '\s'
return c
endif
const e = a[-1]
if e ==# 's'
return $"{c}{c}{c}g\<Left>\<Left>\<Left>"
endif
if e ==# 'g' && c ==# '!'
return "!//\<Left>"
endif
if e ==# 'g' || e ==# 'v'
return $"{c}{c}\<Left>"
endif
return c
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
def A(): string
return {
cs: "\<C-u>colorscheme ",
sb: "\<C-u>set background=\<Tab>",
mv: "\<C-u>MoveFile ",
}->get(getcmdline(), ' ')
enddef
export def ApplySettings()
cno <A-h> <Left>
cno <A-j> <Up>
cno <A-k> <Down>
cno <A-l> <Right>
cno <expr> <C-r><C-r> trim(@")->substitute('\n', ' \| ', 'g')
cno <expr> <C-r><C-e> escape(@", '~^$.*?/\[]')->substitute('\n', '\\n', 'g')
cno <expr> <Space> A()
Each /,#,! cnoremap <script> <expr> {} vimrc#cmdline#CmdlineAutoSlash('{}')
com! -nargs=1 -complete=file MoveFile vimrc#cmdline#MoveFile(<f-args>)
enddef
