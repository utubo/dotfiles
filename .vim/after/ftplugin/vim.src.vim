vim9script

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

# .vimrcを保存したらテストを実行する
def g:TestExit(job: any, status: number)
	if status ==# 0
		echoh Statement
		echo 'Test Success'
	else
		echoh ErrorMsg
		echo 'Test Error!'
	endif
	echoh Normal
enddef
def TestVimrc()
	if expand('%:t') ==# '.vimrc.src.vim'
		job_start(
			["vim", "-c", "let $run_with_ci=1", "-c", "source ./test/vimrc.test.vim", "dummy.vim"],
			{ exit_cb: g:TestExit }
		)
	endif
enddef
au after_ftplugin_vim User MinVimlMinified TestVimrc()

