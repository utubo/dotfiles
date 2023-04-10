vim9script noclear

if exists("b:did_my_after_ftplugin")
	finish
endif
b:did_my_after_ftplugin = 1

g:calendar_first_day = 'sunday'
nnoremap <buffer> k <Plug>(calendar_up)
nnoremap <buffer> j <Plug>(calendar_down)
nnoremap <buffer> h <Plug>(calendar_prev)
nnoremap <buffer> l <Plug>(calendar_next)
nnoremap <buffer> gh <Plug>(calendar_left)
nnoremap <buffer> gl <Plug>(calendar_right)
nmap <buffer> <CR> >
nmap <buffer> <BS> <

