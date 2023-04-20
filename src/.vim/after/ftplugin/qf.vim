vim9script noclear

if exists("b:did_my_after_ftplugin")
	finish
endif
b:did_my_after_ftplugin = 1
nnoremap <buffer> <silent> ; <CR>:silent! normal! zv<CR><C-W>w
nnoremap <buffer> <silent> w <C-W><CR>:silent! normal! zv<CR><C-W>w
nnoremap <buffer> <silent> t <C-W><CR>:silent! normal! zv<CR><C-W>T
nnoremap <buffer> <nowait> q <Cmd>lexpr ''<CR>:q<CR>
nnoremap <buffer> f <C-f>
nnoremap <buffer> b <C-b>
execute $'nnoremap <buffer> T <C-W><CR><C-W>T{tabpagenr()}gt'

