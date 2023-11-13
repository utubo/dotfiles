vim9script

# https://zenn.dev/vim_jp/articles/vim-most-recently-closed-tabs

if !exists('g:most_recently_closed')
  g:most_recently_closed = []
endif

augroup MostRecentlyClosedTabs
  autocmd!
  autocmd BufWinLeave * if expand('<amatch>') != '' | call insert(g:most_recently_closed, expand('<amatch>')) | endif
augroup END

export def ReopenRecentlyTab()
  if len(g:most_recently_closed) > 0
    execute ':tabnew ' .. remove(g:most_recently_closed, 0)
  endif
enddef

export def ShowMostRecentlyClosedTabs()
  new
  set bufhidden=hide
  append(0, g:most_recently_closed)
  :$delete
  autocmd WinClosed <buffer> bwipeout!
  nnoremap <buffer> q <Cmd>bwipeout!<CR>
  nnoremap <buffer> <ESC> <Cmd>bwipeout!<CR>
  nnoremap <buffer> dd <Cmd>call remove(g:most_recently_closed, line('.') - 1)<CR><Cmd>delete<CR>
  nnoremap <buffer> <CR> <Cmd>execute 'tabnew ' .. remove(g:most_recently_closed, line('.') - 1)<CR>
enddef

