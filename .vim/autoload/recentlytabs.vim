vim9script
if !exists('g:most_recently_closed')
g:most_recently_closed = []
endif
aug MostRecentlyClosedTabs
au!
au BufWinLeave * if expand('<amatch>') != ''|call insert(g:most_recently_closed, expand('<amatch>'))|endif
aug END
export def ReopenRecentlyTab()
if len(g:most_recently_closed) > 0
exe ':tabnew ' .. remove(g:most_recently_closed, 0)
endif
enddef
export def ShowMostRecentlyClosedTabs()
new
set bufhidden=hide
append(0, g:most_recently_closed)
$delete
au WinClosed <buffer> bwipeout!
nn <buffer> q <Cmd>bwipeout!<CR>
nn <buffer> <ESC> <Cmd>bwipeout!<CR>
nn <buffer> dd <Cmd>call remove(g:most_recently_closed, line('.') - 1)|delete<CR>
nn <buffer> <CR> <Cmd>execute 'tabnew ' .. remove(g:most_recently_closed, line('.') - 1)<CR>
enddef
