vim9script
if exists("b:did_my_after_ftplugin")
finish
endif
b:did_my_after_ftplugin = 1
aug after_ftplugin_vim
au!
aug END
nn <buffer> g! <Cmd>update<CR><Cmd>source %<CR>
nn <buffer> <expr> ZC $"<Cmd>update<CR><Cmd>colorscheme {expand('%:r')}<CR>"
nn <buffer> <expr> ZB $"<Cmd>set background={&bg ==# 'dark' ? 'light' : 'dark'}<CR>"
def g:TestExit(a: any, b: number)
if b ==# 0
echoh Statement
ec 'Test Success'
else
echoh ErrorMsg
ec 'Test Error!'
endif
echoh Normal
enddef
def A()
if expand('%:t') ==# '.vimrc.src.vim'
job_start(
["vim", "-c", "let $run_with_ci=1", "-c", "source ./test/vimrc.test.vim", "dummy.vim"],
{ exit_cb: g:TestExit }
)
endif
enddef
au after_ftplugin_vim User MinVimlMinified A()
