vim9script noclear
if exists("b:did_my_after_ftplugin")
finish
endif
b:did_my_after_ftplugin = 1
aug after_ftplugin_vim
au!
aug END
nn <buffer> g! <Cmd>update<CR><Cmd>source %<CR>
nn <buffer> <expr> ZC $"<Cmd>update<CR><Cmd>colorscheme {expand('%:r')}<CR>"
if exists("g:did_my_after_ftplugin_vim")
finish
endif
g:did_my_after_ftplugin_vim = 1
var k = []
def g:TestOutput(a: any, b: string)
k += [b->substitute('\%C', '', 'g')->trim()]
enddef
def g:TestExit(a: any, b: number)
if b ==# 0
echoh Statement
ec 'Test Success'
else
echoe 'Test Error!'
for d in k
echoe d
endfor
endif
echoh Normal
enddef
def A()
if expand('%:t') ==# '.vimrc.src.vim'
ec 'Testing ...'
k = []
job_start(
['vim', '-S', '../test/vimrc.test.vim'],
{ exit_cb: g:TestExit, out_cb: g:TestOutput, err_cb: g:TestOutput }
)
endif
enddef
au after_ftplugin_vim User MinVimlMinified A()
