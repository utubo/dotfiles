vim9script noclear

if exists("b:did_my_after_ftplugin")
	finish
endif
b:did_my_after_ftplugin = 1

augroup after_ftplugin_vim
	au!
augroup END

nnoremap <buffer> g! <Cmd>update<CR><Cmd>source %<CR>
nnoremap <buffer> <expr> ZC $"<Cmd>update<CR><Cmd>colorscheme {expand('%:r')}<CR>"
nnoremap <buffer> <expr> ZB $"<Cmd>set background={&background ==# 'dark' ? 'light' : 'dark'}<CR>"

# .vimrcを保存したらテストを実行する {{{
var test_dump = []
def g:TestOutput(ch: any, msg: string)
	test_dump += [msg->substitute('\%C', '', 'g')->trim()]
enddef

def g:TestExit(job: any, status: number)
	if status ==# 0
		echoh Statement
		echo 'Test Success'
	else
		echoe 'Test Error!'
		for d in test_dump
			echoe d
		endfor
	endif
	echoh Normal
enddef

def TestVimrc()
	if expand('%:t') ==# '.vimrc.src.vim'
		echo 'Testing ...'
		test_dump = []
		job_start(
			["vim", "-c", "let $run_with_ci=1", "-c", "source ../test/vimrc.test.vim", "dummy.vim"],
			{ exit_cb: g:TestExit, out_cb: g:TestOutput, err_cb: g:TestOutput }
		)
	endif
enddef
au after_ftplugin_vim User MinVimlMinified TestVimrc()
# }}}

