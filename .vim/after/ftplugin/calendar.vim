vim9script noclear
if exists("b:did_my_after_ftplugin")
finish
endif
b:did_my_after_ftplugin = 1
g:calendar_first_day = 'sunday'
nn <buffer> k <Plug>(calendar_up)
nn <buffer> j <Plug>(calendar_down)
nn <buffer> h <Plug>(calendar_prev)
nn <buffer> l <Plug>(calendar_next)
nn <buffer> gh <Plug>(calendar_left)
nn <buffer> gl <Plug>(calendar_right)
nm <buffer> <CR> >
nm <buffer> <BS> <
